-- Supabase Migration: Loyalty and Points
-- Creates tables and policies for customer points and rewards

CREATE TABLE IF NOT EXISTS points_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    amount DECIMAL(12,2) NOT NULL, -- Spend amount
    points INTEGER NOT NULL,       -- Earned points
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS redeem_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    points INTEGER NOT NULL,       -- Points to redeem
    amount DECIMAL(12,2) NOT NULL, -- Discount amount received
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS points_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    type VARCHAR(20) CHECK (type IN ('earned', 'redeemed')),
    points INTEGER NOT NULL,
    reference_type VARCHAR(50), -- 'sale', 'refund', 'adjustment'
    reference_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Function to calculate points based on amount
CREATE OR REPLACE FUNCTION calculate_earned_points(p_amount DECIMAL)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_points INTEGER := 0;
    v_rule RECORD;
BEGIN
    -- Simplified: Find the rule with the highest amount less than or equal to p_amount
    -- Or use a tiered approach if needed.
    SELECT * INTO v_rule FROM points_rules 
    WHERE amount <= p_amount AND status = TRUE 
    ORDER BY amount DESC LIMIT 1;
    
    IF v_rule IS NOT NULL THEN
        v_points := (p_amount / v_rule.amount)::INTEGER * v_rule.points;
    END IF;
    
    RETURN v_points;
END;
$$;

-- Function to update customer points and log transaction
CREATE OR REPLACE FUNCTION update_customer_points(
    p_customer_id UUID,
    p_points INTEGER,
    p_type VARCHAR,
    p_ref_type VARCHAR,
    p_ref_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- 1. Insert transaction
    INSERT INTO points_transactions (customer_id, type, points, reference_type, reference_id)
    VALUES (p_customer_id, p_type, p_points, p_ref_type, p_ref_id);
    
    -- 2. Update customer total
    IF p_type = 'earned' THEN
        UPDATE customers 
        SET total_points_earned = total_points_earned + p_points 
        WHERE id = p_customer_id;
    ELSE
        UPDATE customers 
        SET total_points_earned = total_points_earned - p_points 
        WHERE id = p_customer_id;
    END IF;
END;
$$;

-- Enable RLS
ALTER TABLE points_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE redeem_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_transactions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public rules are viewable by everyone" ON points_rules
    FOR SELECT TO authenticated USING (status = TRUE);

CREATE POLICY "Public redeem rules are viewable by everyone" ON redeem_rules
    FOR SELECT TO authenticated USING (status = TRUE);

CREATE POLICY "Only admins can manage rules" ON points_rules
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Only admins can manage redeem rules" ON redeem_rules
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Users can view their customers' points transactions" ON points_transactions
    FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Only admins can manage transactions" ON points_transactions
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );
