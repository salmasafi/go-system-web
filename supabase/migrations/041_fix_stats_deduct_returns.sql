-- Migration 041: Deduct sale returns from daily statistics
--
-- Problem: get_cashier_daily_total and get_cashier_daily_revenue reported
--          gross sales without subtracting returned amounts.

-- ── Fix get_cashier_daily_total ──────────────────────────────────────────────
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
        c.id                                                       AS cashier_id,
        c.name                                                     AS cashier_name,
        COALESCE(SUM(sp.amount), 0)
            - COALESCE((
                SELECT SUM(sr.total_amount)
                FROM   sale_returns sr
                JOIN   sales s2 ON s2.id = sr.sale_id
                WHERE  s2.cashier_id = c.id
                  AND  sr.date       = p_date
                  AND  sr.status    != 'cancelled'
              ), 0)                                                AS total_amount,
        COUNT(DISTINCT s.id)                                       AS sale_count
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

-- ── Fix get_cashier_daily_revenue ────────────────────────────────────────────
-- Returns per-payment-method breakdown PLUS a synthetic "RETURNS" line
-- showing total returned amount so the screen displays correctly.
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
    -- Gross sales by payment method
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

    UNION ALL

    -- Returns as a negative "RETURNS" line per cashier
    SELECT
        c.id                                   AS cashier_id,
        c.name                                 AS cashier_name,
        'مرتجعات'::VARCHAR                     AS payment_type,
        -COALESCE(SUM(sr.total_amount), 0)     AS total_amount
    FROM cashiers c
    JOIN sales s2
        ON  s2.cashier_id  = c.id
        AND s2.sale_status = 'completed'
    JOIN sale_returns sr
        ON  sr.sale_id = s2.id
        AND sr.date    = p_date
        AND sr.status != 'cancelled'
    GROUP BY c.id, c.name
    HAVING COALESCE(SUM(sr.total_amount), 0) > 0

    ORDER BY cashier_name, payment_type;
END;
$$;

GRANT EXECUTE ON FUNCTION get_cashier_daily_total    TO authenticated;
GRANT EXECUTE ON FUNCTION get_cashier_daily_revenue  TO authenticated;
