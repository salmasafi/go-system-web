-- Migration 034: Cashier daily revenue report function
-- Returns per-cashier breakdown of today's collected amounts by payment method.
-- Covers cash, card, wallet, or any other payment type.

CREATE OR REPLACE FUNCTION get_cashier_daily_revenue(
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    cashier_id   UUID,
    cashier_name VARCHAR,
    payment_type VARCHAR,
    total_amount DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id                          AS cashier_id,
        c.name                        AS cashier_name,
        COALESCE(pm.name, 'غير محدد') AS payment_type,
        COALESCE(SUM(sp.amount), 0)   AS total_amount
    FROM cashiers c
    JOIN sales s
        ON  s.cashier_id  = c.id
        AND s.date        = p_date
        AND s.sale_status = 'completed'
    JOIN sale_payments sp ON sp.sale_id = s.id
    LEFT JOIN payment_methods pm ON pm.id = sp.payment_method_id
    GROUP BY c.id, c.name, pm.name
    ORDER BY c.name, pm.name;
END;
$$;

-- Helper: total per cashier (all payment types combined)
CREATE OR REPLACE FUNCTION get_cashier_daily_total(
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    cashier_id   UUID,
    cashier_name VARCHAR,
    total_amount DECIMAL,
    sale_count   BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id                        AS cashier_id,
        c.name                      AS cashier_name,
        COALESCE(SUM(sp.amount), 0) AS total_amount,
        COUNT(DISTINCT s.id)        AS sale_count
    FROM cashiers c
    JOIN sales s
        ON  s.cashier_id  = c.id
        AND s.date        = p_date
        AND s.sale_status = 'completed'
    JOIN sale_payments sp ON sp.sale_id = s.id
    GROUP BY c.id, c.name
    ORDER BY total_amount DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_cashier_daily_revenue TO authenticated;
GRANT EXECUTE ON FUNCTION get_cashier_daily_total    TO authenticated;
