ALTER TABLE sales ALTER COLUMN date DROP NOT NULL;
ALTER TABLE sales ALTER COLUMN reference DROP NOT NULL;
ALTER TABLE sale_payments ALTER COLUMN payment_method_id DROP NOT NULL;
ALTER TABLE sale_payments ALTER COLUMN bank_account_id DROP NOT NULL;

DROP FUNCTION IF EXISTS create_sale_with_items(UUID, UUID, JSONB, DECIMAL, DECIMAL, DECIMAL, TEXT, VARCHAR, JSONB);

CREATE OR REPLACE FUNCTION create_sale_with_items(
    p_customer_id UUID,
    p_warehouse_id UUID,
    p_items JSONB,
    p_grand_total DECIMAL,
    p_shift_id UUID DEFAULT NULL,
    p_cashier_id UUID DEFAULT NULL,
    p_tax_amount DECIMAL DEFAULT 0,
    p_discount DECIMAL DEFAULT 0,
    p_note TEXT DEFAULT '',
    p_coupon_code VARCHAR DEFAULT NULL,
    p_payments JSONB DEFAULT '[]',
    p_is_pending BOOLEAN DEFAULT false
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_sale_id UUID;
    v_reference VARCHAR;
    v_item JSONB;
    v_payment JSONB;
    v_product_id UUID;
    v_quantity INTEGER;
    v_warehouse_product_id UUID;
    v_current_quantity INTEGER;
    v_coupon_id UUID;
    v_paid_amount DECIMAL;
    v_remaining_amount DECIMAL;
BEGIN
    -- Generate reference
    v_reference := 'SALE-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || substr(md5(random()::text), 1, 6);

    -- Look up coupon ID if code provided
    IF p_coupon_code IS NOT NULL THEN
        SELECT id INTO v_coupon_id FROM coupons WHERE code = p_coupon_code LIMIT 1;
    END IF;

    -- Calculate paid amount from payments
    v_paid_amount := 0;
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
        v_paid_amount := v_paid_amount + (v_payment->>'amount')::DECIMAL;
    END LOOP;

    v_remaining_amount := p_grand_total - v_paid_amount;

    -- Create sale
    INSERT INTO sales (
        reference, date, customer_id, warehouse_id, shift_id, cashier_id,
        grand_total, tax_amount, discount_amount, paid_amount, remaining_amount,
        notes, coupon_id, sale_status, is_pending, is_due, created_at
    ) VALUES (
        v_reference, CURRENT_DATE, p_customer_id, p_warehouse_id, p_shift_id, p_cashier_id,
        p_grand_total, p_tax_amount, p_discount, v_paid_amount, v_remaining_amount,
        p_note, v_coupon_id,
        CASE WHEN p_is_pending THEN 'pending' ELSE 'completed' END,
        p_is_pending,
        v_remaining_amount > 0,
        NOW()
    ) RETURNING id INTO v_sale_id;

    -- Process items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity := (v_item->>'quantity')::INTEGER;

        -- Check warehouse inventory
        SELECT id, quantity INTO v_warehouse_product_id, v_current_quantity
        FROM warehouse_products
        WHERE warehouse_id = p_warehouse_id AND product_id = v_product_id
        FOR UPDATE;

        IF v_warehouse_product_id IS NULL OR v_current_quantity < v_quantity THEN
            RAISE EXCEPTION 'Insufficient inventory for product %', v_product_id;
        END IF;

        -- Deduct inventory
        UPDATE warehouse_products
        SET quantity = quantity - v_quantity,
            updated_at = NOW()
        WHERE id = v_warehouse_product_id;

        -- Create sale item (using actual table columns)
        INSERT INTO sale_items (
            sale_id, product_id, quantity, price, subtotal, is_bundle, bundle_id
        ) VALUES (
            v_sale_id, v_product_id, v_quantity,
            (v_item->>'price')::DECIMAL,
            (v_item->>'subtotal')::DECIMAL,
            COALESCE((v_item->>'is_bundle')::BOOLEAN, false),
            CASE
                WHEN COALESCE((v_item->>'is_bundle')::BOOLEAN, false) = true
                     AND v_item->>'bundle_id' IS NOT NULL
                THEN (v_item->>'bundle_id')::UUID
                ELSE NULL
            END
        );
    END LOOP;

    -- Process payments (using actual table columns including bank_account_id)
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
        INSERT INTO sale_payments (sale_id, payment_method_id, bank_account_id, amount)
        VALUES (
            v_sale_id,
            (v_payment->>'payment_method_id')::UUID,
            (v_payment->>'bank_account_id')::UUID,
            (v_payment->>'amount')::DECIMAL
        );
    END LOOP;

    -- Update customer due amount if not fully paid
    IF p_customer_id IS NOT NULL AND v_remaining_amount > 0 THEN
        UPDATE customers
        SET is_due = true,
            amount_due = amount_due + v_remaining_amount,
            updated_at = NOW()
        WHERE id = p_customer_id;
    END IF;

    -- Update warehouse stats
    PERFORM update_warehouse_stats(p_warehouse_id);

    RETURN jsonb_build_object(
        'success', true,
        'sale_id', v_sale_id,
        'reference', v_reference
    );
END;
$$;
