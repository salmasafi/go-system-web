-- Migration: Taxes, Discounts, and Coupons Tables with RLS Policies
-- Created: May 2026

-- =====================================================
-- TAXES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS taxes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    type VARCHAR(20) NOT NULL DEFAULT 'percentage', -- percentage, fixed
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    applies_to VARCHAR(20) DEFAULT 'all', -- all, products, services
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    version INTEGER DEFAULT 1,
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- Enable RLS on taxes
ALTER TABLE taxes ENABLE ROW LEVEL SECURITY;

-- Taxes RLS Policies
CREATE POLICY "Taxes read access for authenticated users" ON taxes
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Taxes write access for admins and managers" ON taxes
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

CREATE POLICY "Taxes update access for admins and managers" ON taxes
    FOR UPDATE TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

CREATE POLICY "Taxes delete access for admins only" ON taxes
    FOR DELETE TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin')
        )
    );

-- =====================================================
-- DISCOUNTS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS discounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'percentage', -- percentage, fixed_amount
    value DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    applies_to VARCHAR(20) DEFAULT 'all', -- all, products, categories, customers
    min_purchase_amount DECIMAL(12,2),
    max_discount_amount DECIMAL(12,2),
    start_date DATE,
    end_date DATE,
    priority INTEGER DEFAULT 0, -- For ordering multiple discounts
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    version INTEGER DEFAULT 1,
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- Enable RLS on discounts
ALTER TABLE discounts ENABLE ROW LEVEL SECURITY;

-- Discounts RLS Policies
CREATE POLICY "Discounts read access for authenticated users" ON discounts
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Discounts write access for admins and managers" ON discounts
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

CREATE POLICY "Discounts update access for admins and managers" ON discounts
    FOR UPDATE TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

CREATE POLICY "Discounts delete access for admins only" ON discounts
    FOR DELETE TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin')
        )
    );

-- =====================================================
-- COUPONS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'percentage', -- percentage, fixed_amount
    value DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    usage_limit INTEGER, -- Maximum number of times this coupon can be used
    usage_count INTEGER DEFAULT 0, -- Current usage count
    usage_limit_per_customer INTEGER DEFAULT 1, -- How many times a single customer can use it
    min_purchase_amount DECIMAL(12,2),
    max_discount_amount DECIMAL(12,2),
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    applies_to VARCHAR(20) DEFAULT 'all', -- all, products, categories, customers
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    version INTEGER DEFAULT 1,
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- Enable RLS on coupons
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;

-- Coupons RLS Policies
CREATE POLICY "Coupons read access for authenticated users" ON coupons
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Coupons write access for admins and managers" ON coupons
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

CREATE POLICY "Coupons update access for admins and managers" ON coupons
    FOR UPDATE TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

CREATE POLICY "Coupons delete access for admins only" ON coupons
    FOR DELETE TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin')
        )
    );

-- =====================================================
-- JUNCTION TABLES FOR RELATIONSHIPS
-- =====================================================

-- Discount Products (which products a discount applies to)
CREATE TABLE IF NOT EXISTS discount_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    discount_id UUID NOT NULL REFERENCES discounts(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(discount_id, product_id)
);

ALTER TABLE discount_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Discount products read access" ON discount_products
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Discount products write access" ON discount_products
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

-- Discount Categories (which categories a discount applies to)
CREATE TABLE IF NOT EXISTS discount_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    discount_id UUID NOT NULL REFERENCES discounts(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(discount_id, category_id)
);

ALTER TABLE discount_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Discount categories read access" ON discount_categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Discount categories write access" ON discount_categories
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

-- Coupon Products (which products a coupon applies to)
CREATE TABLE IF NOT EXISTS coupon_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(coupon_id, product_id)
);

ALTER TABLE coupon_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Coupon products read access" ON coupon_products
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Coupon products write access" ON coupon_products
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

-- Coupon Categories (which categories a coupon applies to)
CREATE TABLE IF NOT EXISTS coupon_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(coupon_id, category_id)
);

ALTER TABLE coupon_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Coupon categories read access" ON coupon_categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Coupon categories write access" ON coupon_categories
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name IN ('super_admin', 'admin', 'manager')
        )
    );

-- =====================================================
-- SUPER_ADMIN BYPASS POLICIES
-- =====================================================

-- Super admin bypass for taxes
CREATE POLICY "Taxes super_admin bypass" ON taxes
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name = 'super_admin'
        )
    );

-- Super admin bypass for discounts
CREATE POLICY "Discounts super_admin bypass" ON discounts
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name = 'super_admin'
        )
    );

-- Super admin bypass for coupons
CREATE POLICY "Coupons super_admin bypass" ON coupons
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name = 'super_admin'
        )
    );

-- Super admin bypass for junction tables
CREATE POLICY "Discount products super_admin bypass" ON discount_products
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name = 'super_admin'
        )
    );

CREATE POLICY "Discount categories super_admin bypass" ON discount_categories
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name = 'super_admin'
        )
    );

CREATE POLICY "Coupon products super_admin bypass" ON coupon_products
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name = 'super_admin'
        )
    );

CREATE POLICY "Coupon categories super_admin bypass" ON coupon_categories
    FOR ALL TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles up
            JOIN roles r ON r.id = up.role_id
            WHERE up.id = auth.uid() AND r.name = 'super_admin'
        )
    );

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to validate and apply coupon
CREATE OR REPLACE FUNCTION validate_coupon(p_coupon_code VARCHAR, p_customer_id UUID, p_cart_total DECIMAL)
RETURNS TABLE (
    is_valid BOOLEAN,
    discount_value DECIMAL,
    discount_type VARCHAR,
    message VARCHAR
) AS $$
DECLARE
    v_coupon RECORD;
    v_customer_usage INTEGER;
BEGIN
    -- Get coupon details
    SELECT * INTO v_coupon FROM coupons
    WHERE code = p_coupon_code AND is_active = true;

    -- Check if coupon exists
    IF v_coupon IS NULL THEN
        RETURN QUERY SELECT false, 0.00::DECIMAL, ''::VARCHAR, 'Invalid coupon code'::VARCHAR;
        RETURN;
    END IF;

    -- Check date validity
    IF v_coupon.start_date IS NOT NULL AND v_coupon.start_date > NOW() THEN
        RETURN QUERY SELECT false, 0.00::DECIMAL, ''::VARCHAR, 'Coupon not yet active'::VARCHAR;
        RETURN;
    END IF;

    IF v_coupon.end_date IS NOT NULL AND v_coupon.end_date < NOW() THEN
        RETURN QUERY SELECT false, 0.00::DECIMAL, ''::VARCHAR, 'Coupon has expired'::VARCHAR;
        RETURN;
    END IF;

    -- Check usage limit
    IF v_coupon.usage_limit IS NOT NULL AND v_coupon.usage_count >= v_coupon.usage_limit THEN
        RETURN QUERY SELECT false, 0.00::DECIMAL, ''::VARCHAR, 'Coupon usage limit reached'::VARCHAR;
        RETURN;
    END IF;

    -- Check minimum purchase
    IF v_coupon.min_purchase_amount IS NOT NULL AND p_cart_total < v_coupon.min_purchase_amount THEN
        RETURN QUERY SELECT false, 0.00::DECIMAL, ''::VARCHAR,
            format('Minimum purchase amount of %s required', v_coupon.min_purchase_amount)::VARCHAR;
        RETURN;
    END IF;

    -- Check customer usage limit
    IF p_customer_id IS NOT NULL AND v_coupon.usage_limit_per_customer IS NOT NULL THEN
        SELECT COUNT(*) INTO v_customer_usage FROM sales
        WHERE customer_id = p_customer_id AND coupon_code = p_coupon_code;

        IF v_customer_usage >= v_coupon.usage_limit_per_customer THEN
            RETURN QUERY SELECT false, 0.00::DECIMAL, ''::VARCHAR, 'Customer usage limit reached'::VARCHAR;
            RETURN;
        END IF;
    END IF;

    -- Calculate discount value
    DECLARE
        v_discount DECIMAL;
    BEGIN
        IF v_coupon.type = 'percentage' THEN
            v_discount := (p_cart_total * v_coupon.value / 100);
            -- Apply max discount cap if set
            IF v_coupon.max_discount_amount IS NOT NULL AND v_discount > v_coupon.max_discount_amount THEN
                v_discount := v_coupon.max_discount_amount;
            END IF;
        ELSE
            v_discount := v_coupon.value;
        END IF;

        RETURN QUERY SELECT true, v_discount::DECIMAL, v_coupon.type::VARCHAR, 'Coupon applied successfully'::VARCHAR;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate tax for a sale
CREATE OR REPLACE FUNCTION calculate_sale_tax(p_sale_items JSONB, p_tax_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_tax_rate DECIMAL;
    v_tax_type VARCHAR;
    v_subtotal DECIMAL := 0;
    v_item RECORD;
    v_tax_amount DECIMAL := 0;
BEGIN
    -- Get tax details
    SELECT rate, type INTO v_tax_rate, v_tax_type FROM taxes
    WHERE id = p_tax_id AND is_active = true;

    IF v_tax_rate IS NULL THEN
        RETURN 0;
    END IF;

    -- Calculate subtotal from items
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_sale_items) AS x(quantity INTEGER, price DECIMAL)
    LOOP
        v_subtotal := v_subtotal + (v_item.quantity * v_item.price);
    END LOOP;

    -- Calculate tax
    IF v_tax_type = 'percentage' THEN
        v_tax_amount := (v_subtotal * v_tax_rate / 100);
    ELSE
        v_tax_amount := v_tax_rate;
    END IF;

    RETURN v_tax_amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION validate_coupon(VARCHAR, UUID, DECIMAL) TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_sale_tax(JSONB, UUID) TO authenticated;
