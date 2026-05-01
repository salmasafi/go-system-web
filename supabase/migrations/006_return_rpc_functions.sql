-- Supabase Migration: RPC Functions for Returns (Phase 5.3)

-- ============================================
-- SALE RETURN RPC FUNCTIONS
-- ============================================

-- Function to validate return quantities
CREATE OR REPLACE FUNCTION validate_return_quantities(
    p_sale_id UUID,
    p_items JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_item JSONB;
    v_sale_item RECORD;
    v_already_returned INTEGER;
    v_requested_quantity INTEGER;
    v_available_quantity INTEGER;
BEGIN
    -- Loop through each item to validate
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        -- Get the sale item details
        SELECT si.quantity, si.product_id
        INTO v_sale_item
        FROM sale_items si
        WHERE si.id = (v_item->>'sale_item_id')::UUID
        AND si.sale_id = p_sale_id;

        IF NOT FOUND THEN
            RETURN jsonb_build_object(
                'valid', false,
                'error', 'Sale item not found'
            );
        END IF;

        -- Calculate already returned quantity
        SELECT COALESCE(SUM(sri.returned_quantity), 0)
        INTO v_already_returned
        FROM sale_return_items sri
        JOIN sale_returns sr ON sr.id = sri.return_id
        WHERE sri.sale_item_id = (v_item->>'sale_item_id')::UUID
        AND sr.status != 'cancelled';

        -- Get requested return quantity
        v_requested_quantity := (v_item->>'returned_quantity')::INTEGER;

        -- Calculate available quantity
        v_available_quantity := v_sale_item.quantity - v_already_returned;

        -- Validate
        IF v_requested_quantity > v_available_quantity THEN
            RETURN jsonb_build_object(
                'valid', false,
                'error', 'Return quantity exceeds available quantity',
                'available', v_available_quantity,
                'requested', v_requested_quantity
            );
        END IF;
    END LOOP;

    RETURN jsonb_build_object('valid', true);
END;
$$;

-- Function to create a sale return with transaction
CREATE OR REPLACE FUNCTION create_sale_return(
    p_sale_id UUID,
    p_items JSONB,
    p_total_amount DECIMAL,
    p_refund_method VARCHAR,
    p_note TEXT,
    p_attachment_url TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_return_id UUID;
    v_reference VARCHAR;
    v_sale RECORD;
    v_item JSONB;
    v_sale_item RECORD;
    v_return_item_id UUID;
BEGIN
    -- Get sale details
    SELECT s.*, c.id as customer_id, w.id as warehouse_id
    INTO v_sale
    FROM sales s
    LEFT JOIN customers c ON c.id = s.customer_id
    LEFT JOIN warehouses w ON w.id = s.warehouse_id
    WHERE s.id = p_sale_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale not found';
    END IF;

    -- Generate reference
    v_reference := 'SR-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');

    -- Create sale return
    INSERT INTO sale_returns (
        reference,
        sale_id,
        customer_id,
        warehouse_id,
        total_amount,
        refund_method,
        note,
        attachment_url,
        status,
        created_by
    ) VALUES (
        v_reference,
        p_sale_id,
        v_sale.customer_id,
        v_sale.warehouse_id,
        p_total_amount,
        p_refund_method,
        p_note,
        p_attachment_url,
        'completed',
        auth.uid()
    ) RETURNING id INTO v_return_id;

    -- Create return items and restore quantities
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        -- Get sale item details
        SELECT si.*, p.id as product_id
        INTO v_sale_item
        FROM sale_items si
        JOIN products p ON p.id = si.product_id
        WHERE si.id = (v_item->>'sale_item_id')::UUID;

        -- Insert return item
        INSERT INTO sale_return_items (
            return_id,
            product_id,
            sale_item_id,
            original_quantity,
            returned_quantity,
            price,
            subtotal,
            reason
        ) VALUES (
            v_return_id,
            v_sale_item.product_id,
            v_sale_item.id,
            v_sale_item.quantity,
            (v_item->>'returned_quantity')::INTEGER,
            v_sale_item.price,
            (v_item->>'returned_quantity')::DECIMAL * v_sale_item.price,
            v_item->>'reason'
        ) RETURNING id INTO v_return_item_id;

        -- Restore product quantity in warehouse
        UPDATE warehouse_products
        SET quantity = quantity + (v_item->>'returned_quantity')::INTEGER,
            updated_at = NOW()
        WHERE warehouse_id = v_sale.warehouse_id
        AND product_id = v_sale_item.product_id;

        -- If product doesn't exist in warehouse, insert it
        IF NOT FOUND THEN
            INSERT INTO warehouse_products (
                warehouse_id,
                product_id,
                quantity,
                low_stock
            ) VALUES (
                v_sale.warehouse_id,
                v_sale_item.product_id,
                (v_item->>'returned_quantity')::INTEGER,
                false
            );
        END IF;
    END LOOP;

    -- Update customer balance if applicable
    IF v_sale.customer_id IS NOT NULL AND p_refund_method = 'credit' THEN
        UPDATE customers
        SET balance = balance + p_total_amount,
            updated_at = NOW()
        WHERE id = v_sale.customer_id;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'return_id', v_return_id,
        'reference', v_reference
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating sale return: %', SQLERRM;
END;
$$;

-- Function to restore product quantities from a return
CREATE OR REPLACE FUNCTION restore_return_quantities(
    p_return_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_return RECORD;
    v_item RECORD;
BEGIN
    -- Get return details
    SELECT sr.*, s.warehouse_id
    INTO v_return
    FROM sale_returns sr
    JOIN sales s ON s.id = sr.sale_id
    WHERE sr.id = p_return_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Return not found';
    END IF;

    -- Restore quantities for each item
    FOR v_item IN
        SELECT sri.product_id, sri.returned_quantity
        FROM sale_return_items sri
        WHERE sri.return_id = p_return_id
    LOOP
        UPDATE warehouse_products
        SET quantity = quantity + v_item.returned_quantity,
            updated_at = NOW()
        WHERE warehouse_id = v_return.warehouse_id
        AND product_id = v_item.product_id;
    END LOOP;

    RETURN jsonb_build_object('success', true);
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error restoring quantities: %', SQLERRM;
END;
$$;

-- Function to update customer balance for return
CREATE OR REPLACE FUNCTION update_customer_balance_for_return(
    p_customer_id UUID,
    p_amount DECIMAL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE customers
    SET balance = balance + p_amount,
        updated_at = NOW()
    WHERE id = p_customer_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer not found';
    END IF;

    RETURN jsonb_build_object('success', true);
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error updating customer balance: %', SQLERRM;
END;
$$;

-- ============================================
-- PURCHASE RETURN RPC FUNCTIONS
-- ============================================

-- Function to create a purchase return with transaction
CREATE OR REPLACE FUNCTION create_purchase_return(
    p_purchase_id UUID,
    p_items JSONB,
    p_total_amount DECIMAL,
    p_refund_method VARCHAR,
    p_note TEXT,
    p_attachment_url TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_return_id UUID;
    v_reference VARCHAR;
    v_purchase RECORD;
    v_item JSONB;
    v_purchase_item RECORD;
BEGIN
    -- Get purchase details
    SELECT p.*, s.id as supplier_id, w.id as warehouse_id
    INTO v_purchase
    FROM purchases p
    LEFT JOIN suppliers s ON s.id = p.supplier_id
    LEFT JOIN warehouses w ON w.id = p.warehouse_id
    WHERE p.id = p_purchase_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Purchase not found';
    END IF;

    -- Generate reference
    v_reference := 'PR-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');

    -- Create purchase return
    INSERT INTO purchase_returns (
        reference,
        purchase_id,
        supplier_id,
        warehouse_id,
        total_amount,
        refund_method,
        note,
        attachment_url,
        status,
        created_by
    ) VALUES (
        v_reference,
        p_purchase_id,
        v_purchase.supplier_id,
        v_purchase.warehouse_id,
        p_total_amount,
        p_refund_method,
        p_note,
        p_attachment_url,
        'completed',
        auth.uid()
    ) RETURNING id INTO v_return_id;

    -- Create return items and reduce quantities
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        -- Get purchase item details
        SELECT pi.*, p.id as product_id
        INTO v_purchase_item
        FROM purchase_items pi
        JOIN products p ON p.id = pi.product_id
        WHERE pi.id = (v_item->>'purchase_item_id')::UUID;

        -- Insert return item
        INSERT INTO purchase_return_items (
            return_id,
            product_id,
            purchase_item_id,
            original_quantity,
            returned_quantity,
            price,
            subtotal,
            reason
        ) VALUES (
            v_return_id,
            v_purchase_item.product_id,
            v_purchase_item.id,
            v_purchase_item.quantity,
            (v_item->>'returned_quantity')::INTEGER,
            v_purchase_item.price,
            (v_item->>'returned_quantity')::DECIMAL * v_purchase_item.price,
            v_item->>'reason'
        );

        -- Reduce product quantity in warehouse
        UPDATE warehouse_products
        SET quantity = quantity - (v_item->>'returned_quantity')::INTEGER,
            updated_at = NOW()
        WHERE warehouse_id = v_purchase.warehouse_id
        AND product_id = v_purchase_item.product_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Product not found in warehouse';
        END IF;
    END LOOP;

    -- Update supplier balance if applicable
    IF v_purchase.supplier_id IS NOT NULL THEN
        UPDATE suppliers
        SET balance = balance - p_total_amount,
            updated_at = NOW()
        WHERE id = v_purchase.supplier_id;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'return_id', v_return_id,
        'reference', v_reference
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating purchase return: %', SQLERRM;
END;
$$;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

GRANT EXECUTE ON FUNCTION validate_return_quantities TO authenticated;
GRANT EXECUTE ON FUNCTION create_sale_return TO authenticated;
GRANT EXECUTE ON FUNCTION restore_return_quantities TO authenticated;
GRANT EXECUTE ON FUNCTION update_customer_balance_for_return TO authenticated;
GRANT EXECUTE ON FUNCTION create_purchase_return TO authenticated;
