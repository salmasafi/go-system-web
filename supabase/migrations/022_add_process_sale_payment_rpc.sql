-- Process sale due payment as SECURITY DEFINER to bypass RLS for due_payments INSERT
CREATE OR REPLACE FUNCTION process_sale_payment(
    p_sale_id UUID,
    p_customer_id UUID,
    p_amount DECIMAL,
    p_financial_account_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_paid_amount     DECIMAL;
    v_remaining       DECIMAL;
    v_new_paid        DECIMAL;
    v_new_remaining   DECIMAL;
    v_is_due          BOOLEAN;
    v_other_dues      INT;
BEGIN
    -- Get current sale data
    SELECT paid_amount, remaining_amount
    INTO v_paid_amount, v_remaining
    FROM sales
    WHERE id = p_sale_id;

    IF v_remaining IS NULL THEN
        RAISE EXCEPTION 'Sale not found';
    END IF;

    IF p_amount > v_remaining THEN
        RAISE EXCEPTION 'Payment amount exceeds remaining due';
    END IF;

    v_new_paid      := v_paid_amount + p_amount;
    v_new_remaining := v_remaining   - p_amount;
    v_is_due        := v_new_remaining > 0;

    -- Record payment in due_payments (bypasses RLS via SECURITY DEFINER)
    INSERT INTO due_payments (sale_id, amount, date, financial_account_id)
    VALUES (p_sale_id, p_amount, CURRENT_DATE, p_financial_account_id);

    -- Update sale record
    UPDATE sales
    SET paid_amount      = v_new_paid,
        remaining_amount = v_new_remaining,
        is_due           = v_is_due,
        updated_at       = NOW()
    WHERE id = p_sale_id;

    -- If fully paid, check if customer has any other open dues
    IF NOT v_is_due THEN
        SELECT COUNT(*) INTO v_other_dues
        FROM sales
        WHERE customer_id     = p_customer_id
          AND remaining_amount > 0
          AND id              <> p_sale_id;

        IF v_other_dues = 0 THEN
            UPDATE customers
            SET is_due     = false,
                amount_due = 0,
                updated_at = NOW()
            WHERE id = p_customer_id;
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'success',   true,
        'remaining', v_new_remaining,
        'is_due',    v_is_due
    );
END;
$$;
