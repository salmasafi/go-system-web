-- Supabase Migration: RPC Functions for Adjustments (Phase 5.4)

-- ============================================
-- ADJUSTMENT RPC FUNCTIONS
-- ============================================

-- Function to create an adjustment with transaction
CREATE OR REPLACE FUNCTION create_adjustment(
    p_warehouse_id UUID,
    p_type VARCHAR,
    p_reason TEXT,
    p_items JSONB,
    p_note TEXT,
    p_attachment_url TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_adjustment_id UUID;
    v_reference VARCHAR;
    v_item JSONB;
    v_current_stock INTEGER;
    v_new_stock INTEGER;
    v_total_amount DECIMAL := 0;
BEGIN
    -- Validate type
    IF p_type NOT IN ('increase', 'decrease') THEN
        RAISE EXCEPTION 'Invalid adjustment type. Must be increase or decrease';
    END IF;

    -- Generate reference
    v_reference := 'ADJ-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');

    -- Create adjustment
    INSERT INTO adjustments (
        reference,
        warehouse_id,
        type,
        reason,
        total_amount,
        status,
        note,
        attachment_url,
        created_by
    ) VALUES (
        v_reference,
        p_warehouse_id,
        p_type,
        p_reason,
        0, -- Will be updated after items
        'completed',
        p_note,
        p_attachment_url,
        auth.uid()
    ) RETURNING id INTO v_adjustment_id;

    -- Process each item
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        -- Get current stock
        SELECT COALESCE(quantity, 0)
        INTO v_current_stock
        FROM warehouse_products
        WHERE warehouse_id = p_warehouse_id
        AND product_id = (v_item->>'product_id')::UUID;

        -- If product doesn't exist in warehouse, set current stock to 0
        IF NOT FOUND THEN
            v_current_stock := 0;
        END IF;

        -- Calculate new stock based on adjustment type
        IF p_type = 'increase' THEN
            v_new_stock := v_current_stock + (v_item->>'quantity')::INTEGER;
        ELSE
            v_new_stock := v_current_stock - (v_item->>'quantity')::INTEGER;
            
            -- Validate that we don't go negative
            IF v_new_stock < 0 THEN
                RAISE EXCEPTION 'Insufficient stock for product. Current: %, Requested: %', 
                    v_current_stock, (v_item->>'quantity')::INTEGER;
            END IF;
        END IF;

        -- Insert adjustment item
        INSERT INTO adjustment_items (
            adjustment_id,
            product_id,
            quantity,
            current_stock,
            new_stock,
            unit_cost,
            total_cost,
            reason
        ) VALUES (
            v_adjustment_id,
            (v_item->>'product_id')::UUID,
            (v_item->>'quantity')::INTEGER,
            v_current_stock,
            v_new_stock,
            COALESCE((v_item->>'unit_cost')::DECIMAL, 0),
            COALESCE((v_item->>'quantity')::DECIMAL * (v_item->>'unit_cost')::DECIMAL, 0),
            v_item->>'reason'
        );

        -- Update total amount
        v_total_amount := v_total_amount + COALESCE((v_item->>'quantity')::DECIMAL * (v_item->>'unit_cost')::DECIMAL, 0);

        -- Update warehouse product quantity
        IF EXISTS (
            SELECT 1 FROM warehouse_products 
            WHERE warehouse_id = p_warehouse_id 
            AND product_id = (v_item->>'product_id')::UUID
        ) THEN
            UPDATE warehouse_products
            SET quantity = v_new_stock,
                updated_at = NOW()
            WHERE warehouse_id = p_warehouse_id
            AND product_id = (v_item->>'product_id')::UUID;
        ELSE
            -- Insert new warehouse product if it doesn't exist
            INSERT INTO warehouse_products (
                warehouse_id,
                product_id,
                quantity,
                low_stock
            ) VALUES (
                p_warehouse_id,
                (v_item->>'product_id')::UUID,
                v_new_stock,
                false
            );
        END IF;
    END LOOP;

    -- Update adjustment total amount
    UPDATE adjustments
    SET total_amount = v_total_amount
    WHERE id = v_adjustment_id;

    RETURN jsonb_build_object(
        'success', true,
        'adjustment_id', v_adjustment_id,
        'reference', v_reference
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating adjustment: %', SQLERRM;
END;
$$;

-- Function to reverse an adjustment (for cancellation)
CREATE OR REPLACE FUNCTION reverse_adjustment(
    p_adjustment_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_adjustment RECORD;
    v_item RECORD;
BEGIN
    -- Get adjustment details
    SELECT *
    INTO v_adjustment
    FROM adjustments
    WHERE id = p_adjustment_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Adjustment not found';
    END IF;

    IF v_adjustment.status = 'cancelled' THEN
        RAISE EXCEPTION 'Adjustment already cancelled';
    END IF;

    -- Reverse each item
    FOR v_item IN
        SELECT *
        FROM adjustment_items
        WHERE adjustment_id = p_adjustment_id
    LOOP
        -- Reverse the quantity change
        IF v_adjustment.type = 'increase' THEN
            -- Decrease the quantity back
            UPDATE warehouse_products
            SET quantity = quantity - v_item.quantity,
                updated_at = NOW()
            WHERE warehouse_id = v_adjustment.warehouse_id
            AND product_id = v_item.product_id;
        ELSE
            -- Increase the quantity back
            UPDATE warehouse_products
            SET quantity = quantity + v_item.quantity,
                updated_at = NOW()
            WHERE warehouse_id = v_adjustment.warehouse_id
            AND product_id = v_item.product_id;
        END IF;
    END LOOP;

    -- Mark adjustment as cancelled
    UPDATE adjustments
    SET status = 'cancelled',
        updated_at = NOW()
    WHERE id = p_adjustment_id;

    RETURN jsonb_build_object('success', true);
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error reversing adjustment: %', SQLERRM;
END;
$$;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

GRANT EXECUTE ON FUNCTION create_adjustment TO authenticated;
GRANT EXECUTE ON FUNCTION reverse_adjustment TO authenticated;
