-- Migration 042: Wire financial flows
--
-- Problems fixed:
--   1. create_sale_with_items never updated bank_accounts.balance or shifts.total_sale_amount
--   2. create_sale_return never updated bank_accounts.balance or shifts.total_sale_amount
--   3. process_sale_payment never updated bank_accounts.balance
--
-- After this migration:
--   • Every completed sale  → bank_accounts.balance += payment amounts
--                           → shifts.total_sale_amount += grand_total
--   • Every sale return     → bank_accounts.balance -= return amount
--                           → shifts.total_sale_amount -= return amount
--   • Every due-payment     → bank_accounts.balance += paid amount

-- ── Helper: safely update bank account balance ────────────────────────────────
CREATE OR REPLACE FUNCTION _add_to_bank_balance(p_bank_account_id UUID, p_amount DECIMAL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_bank_account_id IS NULL THEN RETURN; END IF;
    UPDATE bank_accounts
    SET    balance     = balance + p_amount,
           updated_at  = NOW()
    WHERE  id = p_bank_account_id;
END;
$$;

-- ── 1. Fix create_sale_with_items ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION create_sale_with_items(
    p_customer_id    UUID,
    p_warehouse_id   UUID,
    p_items          JSONB,
    p_grand_total    DECIMAL,
    p_shift_id       UUID    DEFAULT NULL,
    p_cashier_id     UUID    DEFAULT NULL,
    p_tax_amount     DECIMAL DEFAULT 0,
    p_discount       DECIMAL DEFAULT 0,
    p_note           TEXT    DEFAULT '',
    p_coupon_code    VARCHAR DEFAULT NULL,
    p_payments       JSONB   DEFAULT '[]',
    p_is_pending     BOOLEAN DEFAULT false
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_sale_id              UUID;
    v_reference            VARCHAR;
    v_item                 JSONB;
    v_payment              JSONB;
    v_product_id           UUID;
    v_quantity             INTEGER;
    v_warehouse_product_id UUID;
    v_current_quantity     INTEGER;
    v_coupon_id            UUID;
    v_paid_amount          DECIMAL;
    v_remaining_amount     DECIMAL;
    v_bank_account_id      UUID;
    v_payment_amount       DECIMAL;
BEGIN
    -- Generate reference
    v_reference := 'SALE-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-'
                || substr(md5(random()::text), 1, 6);

    -- Look up coupon
    IF p_coupon_code IS NOT NULL THEN
        SELECT id INTO v_coupon_id
        FROM   coupons
        WHERE  code = p_coupon_code
        LIMIT  1;
    END IF;

    -- Sum payments
    v_paid_amount := 0;
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
        v_paid_amount := v_paid_amount + (v_payment->>'amount')::DECIMAL;
    END LOOP;

    v_remaining_amount := p_grand_total - v_paid_amount;

    -- Create sale record
    INSERT INTO sales (
        reference, date, customer_id, warehouse_id, shift_id, cashier_id,
        grand_total, tax_amount, discount_amount, paid_amount, remaining_amount,
        notes, coupon_id, sale_status, is_pending, is_due, created_at
    ) VALUES (
        v_reference, CURRENT_DATE,
        p_customer_id, p_warehouse_id, p_shift_id, p_cashier_id,
        p_grand_total, p_tax_amount, p_discount, v_paid_amount, v_remaining_amount,
        p_note, v_coupon_id,
        CASE WHEN p_is_pending THEN 'pending' ELSE 'completed' END,
        p_is_pending,
        v_remaining_amount > 0,
        NOW()
    ) RETURNING id INTO v_sale_id;

    -- Process each item
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity   := (v_item->>'quantity')::INTEGER;

        SELECT id, quantity
        INTO   v_warehouse_product_id, v_current_quantity
        FROM   warehouse_products
        WHERE  warehouse_id = p_warehouse_id
          AND  product_id   = v_product_id
        FOR UPDATE;

        IF v_warehouse_product_id IS NULL THEN
            RAISE EXCEPTION 'Product % not registered in this warehouse.', v_product_id;
        END IF;

        IF v_current_quantity < v_quantity THEN
            RAISE EXCEPTION 'Insufficient inventory for product %. Available: %, Requested: %',
                v_product_id, v_current_quantity, v_quantity;
        END IF;

        UPDATE warehouse_products
        SET    quantity    = quantity - v_quantity,
               updated_at = NOW()
        WHERE  id = v_warehouse_product_id;

        INSERT INTO sale_items (
            sale_id, product_id, quantity, price, subtotal, is_bundle, bundle_id
        ) VALUES (
            v_sale_id, v_product_id, v_quantity,
            (v_item->>'price')::DECIMAL,
            (v_item->>'subtotal')::DECIMAL,
            COALESCE((v_item->>'is_bundle')::BOOLEAN, false),
            CASE
                WHEN COALESCE((v_item->>'is_bundle')::BOOLEAN, false)
                     AND v_item->>'bundle_id' IS NOT NULL
                THEN (v_item->>'bundle_id')::UUID
                ELSE NULL
            END
        );
    END LOOP;

    -- Process payments
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
        v_bank_account_id := (v_payment->>'bank_account_id')::UUID;
        v_payment_amount  := (v_payment->>'amount')::DECIMAL;

        INSERT INTO sale_payments (sale_id, payment_method_id, bank_account_id, amount)
        VALUES (
            v_sale_id,
            (v_payment->>'payment_method_id')::UUID,
            v_bank_account_id,
            v_payment_amount
        );

        -- ► Wire: update bank account balance (only for completed sales)
        IF NOT p_is_pending THEN
            PERFORM _add_to_bank_balance(v_bank_account_id, v_payment_amount);
        END IF;
    END LOOP;

    -- Update customer due if needed
    IF p_customer_id IS NOT NULL AND v_remaining_amount > 0 THEN
        UPDATE customers
        SET    is_due      = true,
               amount_due  = amount_due + v_remaining_amount,
               updated_at  = NOW()
        WHERE  id = p_customer_id;
    END IF;

    -- ► Wire: update shift total (only for completed sales)
    IF p_shift_id IS NOT NULL AND NOT p_is_pending THEN
        UPDATE shifts
        SET    total_sale_amount = total_sale_amount + p_grand_total,
               updated_at       = NOW()
        WHERE  id = p_shift_id;
    END IF;

    PERFORM update_warehouse_stats(p_warehouse_id);

    RETURN jsonb_build_object(
        'success',   true,
        'sale_id',   v_sale_id,
        'reference', v_reference
    );
END;
$$;

-- ── 2. Fix create_sale_return ─────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION create_sale_return(
    p_sale_id        UUID,
    p_items          JSONB,
    p_total_amount   DECIMAL,
    p_refund_method  VARCHAR,   -- may be a bank_account UUID or 'cash'
    p_note           TEXT,
    p_attachment_url TEXT
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
    v_refund_id  UUID;
BEGIN
    SELECT s.id, s.customer_id, s.warehouse_id, s.shift_id
    INTO   v_sale
    FROM   sales s
    WHERE  s.id = p_sale_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale not found: %', p_sale_id;
    END IF;

    v_reference := 'SR-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-'
                || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');

    INSERT INTO sale_returns (
        reference, sale_id, customer_id, warehouse_id,
        total_amount, refund_method, note, status, date, created_by
    ) VALUES (
        v_reference, p_sale_id, v_sale.customer_id, v_sale.warehouse_id,
        p_total_amount, p_refund_method, p_note,
        'completed', CURRENT_DATE, auth.uid()
    ) RETURNING id INTO v_return_id;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        SELECT si.id, si.product_id, si.quantity, si.price
        INTO   v_sale_item
        FROM   sale_items si
        WHERE  si.id = (v_item->>'sale_item_id')::UUID;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Sale item not found: %', v_item->>'sale_item_id';
        END IF;

        INSERT INTO sale_return_items (
            return_id, sale_item_id, product_id,
            original_quantity, returned_quantity,
            reason, price, subtotal
        ) VALUES (
            v_return_id, v_sale_item.id, v_sale_item.product_id,
            v_sale_item.quantity,
            (v_item->>'returned_quantity')::INTEGER,
            COALESCE(v_item->>'reason', ''),
            v_sale_item.price,
            (v_item->>'returned_quantity')::DECIMAL * v_sale_item.price
        );

        UPDATE warehouse_products
        SET    quantity    = quantity + (v_item->>'returned_quantity')::INTEGER,
               updated_at = NOW()
        WHERE  warehouse_id = v_sale.warehouse_id
          AND  product_id   = v_sale_item.product_id;

        IF NOT FOUND THEN
            INSERT INTO warehouse_products (warehouse_id, product_id, quantity)
            VALUES (v_sale.warehouse_id, v_sale_item.product_id,
                    (v_item->>'returned_quantity')::INTEGER)
            ON CONFLICT (warehouse_id, product_id)
            DO UPDATE SET quantity   = warehouse_products.quantity + EXCLUDED.quantity,
                          updated_at = NOW();
        END IF;
    END LOOP;

    -- ► Wire: deduct from bank account if p_refund_method is a valid UUID
    BEGIN
        v_refund_id := p_refund_method::UUID;
        PERFORM _add_to_bank_balance(v_refund_id, -p_total_amount);
    EXCEPTION WHEN invalid_text_representation THEN
        NULL; -- 'cash' or other non-UUID string → skip balance update
    END;

    -- ► Wire: reduce shift total
    IF v_sale.shift_id IS NOT NULL THEN
        UPDATE shifts
        SET    total_sale_amount = GREATEST(0, total_sale_amount - p_total_amount),
               updated_at       = NOW()
        WHERE  id = v_sale.shift_id;
    END IF;

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

-- ── 3. Fix process_sale_payment (due payment) ─────────────────────────────────
CREATE OR REPLACE FUNCTION process_sale_payment(
    p_sale_id            UUID,
    p_customer_id        UUID,
    p_amount             DECIMAL,
    p_financial_account_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_paid_amount   DECIMAL;
    v_remaining     DECIMAL;
    v_new_paid      DECIMAL;
    v_new_remaining DECIMAL;
    v_is_due        BOOLEAN;
    v_other_dues    INT;
BEGIN
    SELECT paid_amount, remaining_amount
    INTO   v_paid_amount, v_remaining
    FROM   sales
    WHERE  id = p_sale_id;

    IF v_remaining IS NULL THEN
        RAISE EXCEPTION 'Sale not found';
    END IF;

    IF p_amount > v_remaining THEN
        RAISE EXCEPTION 'Payment amount exceeds remaining due';
    END IF;

    v_new_paid      := v_paid_amount + p_amount;
    v_new_remaining := v_remaining   - p_amount;
    v_is_due        := v_new_remaining > 0;

    INSERT INTO due_payments (sale_id, amount, date, financial_account_id)
    VALUES (p_sale_id, p_amount, CURRENT_DATE, p_financial_account_id);

    UPDATE sales
    SET    paid_amount      = v_new_paid,
           remaining_amount = v_new_remaining,
           is_due           = v_is_due,
           updated_at       = NOW()
    WHERE  id = p_sale_id;

    IF NOT v_is_due THEN
        SELECT COUNT(*) INTO v_other_dues
        FROM   sales
        WHERE  customer_id     = p_customer_id
          AND  remaining_amount > 0
          AND  id              <> p_sale_id;

        IF v_other_dues = 0 THEN
            UPDATE customers
            SET    is_due     = false,
                   amount_due = 0,
                   updated_at = NOW()
            WHERE  id = p_customer_id;
        END IF;
    END IF;

    -- ► Wire: add payment to bank account balance
    PERFORM _add_to_bank_balance(p_financial_account_id, p_amount);

    RETURN jsonb_build_object(
        'success',   true,
        'remaining', v_new_remaining,
        'is_due',    v_is_due
    );
END;
$$;

-- ── Grants ────────────────────────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION _add_to_bank_balance        TO authenticated;
GRANT EXECUTE ON FUNCTION create_sale_with_items      TO authenticated;
GRANT EXECUTE ON FUNCTION create_sale_return          TO authenticated;
GRANT EXECUTE ON FUNCTION process_sale_payment        TO authenticated;
