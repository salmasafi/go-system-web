-- Migration 040: Fix create_sale_return RPC
--
-- Problems fixed:
--   1. Referenced sale_returns.attachment_url which was dropped in migration 013
--   2. Referenced customers.balance which does not exist (no such column)
--   3. Dart client sent 'quantity' key but function expected 'returned_quantity'
--      → standardized to 'returned_quantity' (matches validate_return_quantities)

CREATE OR REPLACE FUNCTION create_sale_return(
    p_sale_id        UUID,
    p_items          JSONB,
    p_total_amount   DECIMAL,
    p_refund_method  VARCHAR,
    p_note           TEXT,
    p_attachment_url TEXT  -- kept in signature for backwards compat, value is ignored
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_return_id  UUID;
    v_reference  VARCHAR;
    v_sale       RECORD;
    v_item       JSONB;
    v_sale_item  RECORD;
BEGIN
    -- Get sale details
    SELECT s.id, s.customer_id, s.warehouse_id
    INTO v_sale
    FROM sales s
    WHERE s.id = p_sale_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale not found: %', p_sale_id;
    END IF;

    -- Generate unique reference
    v_reference := 'SR-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-'
                || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');

    -- Insert sale_returns record (no attachment_url column since migration 013 dropped it)
    INSERT INTO sale_returns (
        reference,
        sale_id,
        customer_id,
        warehouse_id,
        total_amount,
        refund_method,
        note,
        status,
        date,
        created_by
    ) VALUES (
        v_reference,
        p_sale_id,
        v_sale.customer_id,
        v_sale.warehouse_id,
        p_total_amount,
        p_refund_method,
        p_note,
        'completed',
        CURRENT_DATE,
        auth.uid()
    ) RETURNING id INTO v_return_id;

    -- Process each return item
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        -- Get the original sale item (price, product_id, quantity)
        SELECT si.id, si.product_id, si.quantity, si.price
        INTO v_sale_item
        FROM sale_items si
        WHERE si.id = (v_item->>'sale_item_id')::UUID;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Sale item not found: %', v_item->>'sale_item_id';
        END IF;

        -- Insert sale_return_items
        INSERT INTO sale_return_items (
            return_id,
            sale_item_id,
            product_id,
            original_quantity,
            returned_quantity,
            reason,
            price,
            subtotal
        ) VALUES (
            v_return_id,
            v_sale_item.id,
            v_sale_item.product_id,
            v_sale_item.quantity,
            (v_item->>'returned_quantity')::INTEGER,
            COALESCE(v_item->>'reason', ''),
            v_sale_item.price,
            (v_item->>'returned_quantity')::DECIMAL * v_sale_item.price
        );

        -- Restore stock in warehouse_products
        UPDATE warehouse_products
        SET    quantity   = quantity + (v_item->>'returned_quantity')::INTEGER,
               updated_at = NOW()
        WHERE  warehouse_id = v_sale.warehouse_id
          AND  product_id   = v_sale_item.product_id;

        -- If the row doesn't exist yet, create it
        IF NOT FOUND THEN
            INSERT INTO warehouse_products (warehouse_id, product_id, quantity)
            VALUES (v_sale.warehouse_id, v_sale_item.product_id,
                    (v_item->>'returned_quantity')::INTEGER)
            ON CONFLICT (warehouse_id, product_id)
            DO UPDATE SET quantity = warehouse_products.quantity
                        + EXCLUDED.quantity,
                          updated_at = NOW();
        END IF;
    END LOOP;

    -- Update warehouse aggregate stats
    PERFORM update_warehouse_stats(v_sale.warehouse_id);

    RETURN jsonb_build_object(
        'success',   true,
        'return_id', v_return_id,
        'reference', v_reference
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating sale return: %', SQLERRM;
END;
$$;

GRANT EXECUTE ON FUNCTION create_sale_return TO authenticated;
