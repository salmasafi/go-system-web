-- Supabase Migration: Stored Procedures (RPC Functions)
-- These functions handle complex transactions atomically

-- ============================================
-- WAREHOUSE FUNCTIONS
-- ============================================

-- Transfer product between warehouses
CREATE OR REPLACE FUNCTION transfer_product_between_warehouses(
    p_from_warehouse_id UUID,
    p_to_warehouse_id UUID,
    p_product_id UUID,
    p_quantity INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_source_quantity INTEGER;
    v_transfer_id UUID;
BEGIN
    -- Check source warehouse has enough quantity
    SELECT quantity INTO v_source_quantity
    FROM warehouse_products
    WHERE warehouse_id = p_from_warehouse_id AND product_id = p_product_id
    FOR UPDATE;

    IF v_source_quantity IS NULL OR v_source_quantity < p_quantity THEN
        RAISE EXCEPTION 'Insufficient quantity in source warehouse';
    END IF;

    -- Deduct from source
    UPDATE warehouse_products
    SET quantity = quantity - p_quantity,
        updated_at = NOW()
    WHERE warehouse_id = p_from_warehouse_id AND product_id = p_product_id;

    -- Add to destination (or insert if not exists)
    INSERT INTO warehouse_products (warehouse_id, product_id, quantity)
    VALUES (p_to_warehouse_id, p_product_id, p_quantity)
    ON CONFLICT (warehouse_id, product_id)
    DO UPDATE SET 
        quantity = warehouse_products.quantity + EXCLUDED.quantity,
        updated_at = NOW();

    -- Create transfer record
    INSERT INTO transfers (from_warehouse_id, to_warehouse_id, product_id, quantity, status, created_at)
    VALUES (p_from_warehouse_id, p_to_warehouse_id, p_product_id, p_quantity, 'completed', NOW())
    RETURNING id INTO v_transfer_id;

    -- Update warehouse stats
    PERFORM update_warehouse_stats(p_from_warehouse_id);
    PERFORM update_warehouse_stats(p_to_warehouse_id);

    RETURN jsonb_build_object(
        'success', true,
        'transfer_id', v_transfer_id
    );
END;
$$;

-- Update warehouse statistics
CREATE OR REPLACE FUNCTION update_warehouse_stats(p_warehouse_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE warehouses
    SET 
        number_of_products = (SELECT COUNT(*) FROM warehouse_products WHERE warehouse_id = p_warehouse_id),
        stock_quantity = (SELECT COALESCE(SUM(quantity), 0) FROM warehouse_products WHERE warehouse_id = p_warehouse_id),
        updated_at = NOW()
    WHERE id = p_warehouse_id;
END;
$$;

-- ============================================
-- SALE FUNCTIONS
-- ============================================

-- Create sale with items and payments atomically
CREATE OR REPLACE FUNCTION create_sale_with_items(
    p_customer_id UUID,
    p_warehouse_id UUID,
    p_items JSONB,
    p_grand_total DECIMAL,
    p_tax_amount DECIMAL DEFAULT 0,
    p_discount DECIMAL DEFAULT 0,
    p_note TEXT DEFAULT '',
    p_coupon_code VARCHAR DEFAULT NULL,
    p_payments JSONB DEFAULT '[]'
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
BEGIN
    -- Generate reference
    v_reference := 'SALE-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || substr(md5(random()::text), 1, 6);

    -- Create sale
    INSERT INTO sales (
        reference, customer_id, warehouse_id, grand_total, tax_amount, 
        discount, note, coupon_code, sale_status, payment_status, created_at
    ) VALUES (
        v_reference, p_customer_id, p_warehouse_id, p_grand_total, p_tax_amount,
        p_discount, p_note, p_coupon_code, 'completed', 
        CASE WHEN jsonb_array_length(p_payments) > 0 THEN 'paid' ELSE 'unpaid' END,
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

        -- Create sale item
        INSERT INTO sale_items (
            sale_id, product_id, product_price_id, quantity, 
            price, subtotal, discount, tax
        ) VALUES (
            v_sale_id, v_product_id, (v_item->>'product_price_id')::UUID, v_quantity,
            (v_item->>'price')::DECIMAL, (v_item->>'subtotal')::DECIMAL,
            (v_item->>'discount')::DECIMAL, (v_item->>'tax')::DECIMAL
        );
    END LOOP;

    -- Process payments
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
        INSERT INTO sale_payments (sale_id, payment_method_id, amount, reference)
        VALUES (
            v_sale_id, (v_payment->>'payment_method_id')::UUID,
            (v_payment->>'amount')::DECIMAL, v_payment->>'reference'
        );
    END LOOP;

    -- Update customer due amount if not fully paid
    IF p_customer_id IS NOT NULL AND jsonb_array_length(p_payments) = 0 THEN
        UPDATE customers
        SET is_due = true,
            amount_due = amount_due + p_grand_total,
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

-- Cancel sale and restore inventory
CREATE OR REPLACE FUNCTION cancel_sale(p_sale_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_warehouse_id UUID;
    v_customer_id UUID;
    v_grand_total DECIMAL;
    v_item RECORD;
BEGIN
    -- Get sale details
    SELECT warehouse_id, customer_id, grand_total 
    INTO v_warehouse_id, v_customer_id, v_grand_total
    FROM sales WHERE id = p_sale_id;

    IF v_warehouse_id IS NULL THEN
        RAISE EXCEPTION 'Sale not found';
    END IF;

    -- Restore inventory for each item
    FOR v_item IN 
        SELECT product_id, quantity 
        FROM sale_items 
        WHERE sale_id = p_sale_id
    LOOP
        UPDATE warehouse_products
        SET quantity = quantity + v_item.quantity,
            updated_at = NOW()
        WHERE warehouse_id = v_warehouse_id AND product_id = v_item.product_id;
    END LOOP;

    -- Update customer due amount
    IF v_customer_id IS NOT NULL THEN
        UPDATE customers
        SET amount_due = GREATEST(0, amount_due - v_grand_total),
            is_due = CASE WHEN amount_due - v_grand_total > 0 THEN true ELSE false END,
            updated_at = NOW()
        WHERE id = v_customer_id;
    END IF;

    -- Update sale status
    UPDATE sales
    SET sale_status = 'cancelled',
        updated_at = NOW()
    WHERE id = p_sale_id;

    -- Update warehouse stats
    PERFORM update_warehouse_stats(v_warehouse_id);

    RETURN jsonb_build_object('success', true);
END;
$$;

-- Apply coupon to sale
CREATE OR REPLACE FUNCTION apply_sale_coupon(
    p_sale_id UUID,
    p_coupon_code VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_coupon_discount DECIMAL;
    v_grand_total DECIMAL;
BEGIN
    -- Get coupon discount (simplified - you might have a coupons table)
    -- This is a placeholder implementation
    v_coupon_discount := 0; -- Calculate based on your coupon logic

    -- Update sale
    UPDATE sales
    SET coupon_code = p_coupon_code,
        coupon_discount = v_coupon_discount,
        grand_total = grand_total - v_coupon_discount,
        updated_at = NOW()
    WHERE id = p_sale_id;

    RETURN jsonb_build_object(
        'success', true,
        'discount', v_coupon_discount
    );
END;
$$;

-- ============================================
-- PURCHASE FUNCTIONS
-- ============================================

-- Create purchase with items atomically
CREATE OR REPLACE FUNCTION create_purchase_with_items(
    p_warehouse_id UUID,
    p_supplier_id UUID,
    p_items JSONB,
    p_grand_total DECIMAL,
    p_tax_amount DECIMAL DEFAULT 0,
    p_discount DECIMAL DEFAULT 0,
    p_shipping_cost DECIMAL DEFAULT 0,
    p_note TEXT DEFAULT '',
    p_receipt_img TEXT DEFAULT '',
    p_payments JSONB DEFAULT '[]'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_purchase_id UUID;
    v_reference VARCHAR;
    v_item JSONB;
BEGIN
    -- Generate reference
    v_reference := 'PUR-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || substr(md5(random()::text), 1, 6);

    -- Create purchase
    INSERT INTO purchases (
        reference, warehouse_id, supplier_id, grand_total, tax_amount,
        discount, shipping_cost, note, receipt_img, payment_status, created_at
    ) VALUES (
        v_reference, p_warehouse_id, p_supplier_id, p_grand_total, p_tax_amount,
        p_discount, p_shipping_cost, p_note, p_receipt_img,
        CASE WHEN jsonb_array_length(p_payments) > 0 THEN 'full' ELSE 'later' END,
        NOW()
    ) RETURNING id INTO v_purchase_id;

    -- Process items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        -- Create purchase item
        INSERT INTO purchase_items (
            purchase_id, product_id, quantity, unit_cost, subtotal,
            discount, tax, date_of_expiry, patch_number
        ) VALUES (
            v_purchase_id, (v_item->>'product_id')::UUID,
            (v_item->>'quantity')::INTEGER, (v_item->>'unit_cost')::DECIMAL,
            (v_item->>'subtotal')::DECIMAL, (v_item->>'discount')::DECIMAL,
            (v_item->>'tax')::DECIMAL, (v_item->>'date_of_expiry')::DATE,
            v_item->>'patch_number'
        );

        -- Add to warehouse inventory
        INSERT INTO warehouse_products (warehouse_id, product_id, quantity)
        VALUES (p_warehouse_id, (v_item->>'product_id')::UUID, (v_item->>'quantity')::INTEGER)
        ON CONFLICT (warehouse_id, product_id)
        DO UPDATE SET 
            quantity = warehouse_products.quantity + EXCLUDED.quantity,
            updated_at = NOW();
    END LOOP;

    -- Update warehouse stats
    PERFORM update_warehouse_stats(p_warehouse_id);

    RETURN jsonb_build_object(
        'success', true,
        'purchase_id', v_purchase_id,
        'reference', v_reference
    );
END;
$$;

-- Delete purchase and restore inventory
CREATE OR REPLACE FUNCTION delete_purchase(p_purchase_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_warehouse_id UUID;
    v_item RECORD;
BEGIN
    -- Get warehouse
    SELECT warehouse_id INTO v_warehouse_id
    FROM purchases WHERE id = p_purchase_id;

    IF v_warehouse_id IS NULL THEN
        RAISE EXCEPTION 'Purchase not found';
    END IF;

    -- Deduct inventory for each item
    FOR v_item IN 
        SELECT product_id, quantity 
        FROM purchase_items 
        WHERE purchase_id = p_purchase_id
    LOOP
        UPDATE warehouse_products
        SET quantity = GREATEST(0, quantity - v_item.quantity),
            updated_at = NOW()
        WHERE warehouse_id = v_warehouse_id AND product_id = v_item.product_id;
    END LOOP;

    -- Delete purchase items
    DELETE FROM purchase_items WHERE purchase_id = p_purchase_id;

    -- Delete purchase
    DELETE FROM purchases WHERE id = p_purchase_id;

    -- Update warehouse stats
    PERFORM update_warehouse_stats(v_warehouse_id);

    RETURN jsonb_build_object('success', true);
END;
$$;

-- Process purchase payment
CREATE OR REPLACE FUNCTION process_purchase_payment(
    p_purchase_id UUID,
    p_amount DECIMAL,
    p_financial_account_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_remaining DECIMAL;
    v_new_status VARCHAR;
BEGIN
    -- Get current remaining
    SELECT remaining_amount INTO v_remaining
    FROM purchases WHERE id = p_purchase_id;

    IF v_remaining IS NULL THEN
        RAISE EXCEPTION 'Purchase not found';
    END IF;

    IF p_amount > v_remaining THEN
        RAISE EXCEPTION 'Payment amount exceeds remaining balance';
    END IF;

    -- Update purchase
    v_new_status := CASE 
        WHEN v_remaining - p_amount <= 0 THEN 'full'
        WHEN v_remaining - p_amount < (SELECT grand_total FROM purchases WHERE id = p_purchase_id) THEN 'partial'
        ELSE 'later'
    END;

    UPDATE purchases
    SET paid_amount = paid_amount + p_amount,
        remaining_amount = remaining_amount - p_amount,
        payment_status = v_new_status,
        updated_at = NOW()
    WHERE id = p_purchase_id;

    -- Create due payment record
    INSERT INTO due_payments (purchase_id, amount, date, financial_account_id)
    VALUES (p_purchase_id, p_amount, CURRENT_DATE, p_financial_account_id);

    RETURN jsonb_build_object(
        'success', true,
        'remaining', v_remaining - p_amount,
        'status', v_new_status
    );
END;
$$;

-- ============================================
-- CUSTOMER FUNCTIONS
-- ============================================

-- Calculate customer due amount
CREATE OR REPLACE FUNCTION calculate_customer_due(p_customer_id UUID)
RETURNS DECIMAL
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_due DECIMAL;
BEGIN
    SELECT COALESCE(SUM(remaining_amount), 0)
    INTO v_total_due
    FROM sales
    WHERE customer_id = p_customer_id AND sale_status = 'completed';

    -- Update customer
    UPDATE customers
    SET amount_due = v_total_due,
        is_due = v_total_due > 0,
        updated_at = NOW()
    WHERE id = p_customer_id;

    RETURN v_total_due;
END;
$$;

-- ============================================
-- TRANSFERS TABLE (if not exists)
-- ============================================

CREATE TABLE IF NOT EXISTS transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_warehouse_id UUID REFERENCES warehouses(id) ON DELETE RESTRICT,
    to_warehouse_id UUID REFERENCES warehouses(id) ON DELETE RESTRICT,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
    reference VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES user_profiles(id)
);

ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view transfers" ON transfers
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

CREATE POLICY "Managers can create transfers" ON transfers
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );
