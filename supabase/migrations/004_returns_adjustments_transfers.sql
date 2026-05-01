-- Supabase Migration: Returns, Adjustments, and Transfers Tables

-- ============================================
-- SALE RETURNS TABLES (Phase 5.3)
-- ============================================

-- Sale Returns
CREATE TABLE IF NOT EXISTS sale_returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE,
    sale_id UUID REFERENCES sales(id) ON DELETE RESTRICT,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    
    -- Financial
    total_amount DECIMAL(12,2) NOT NULL,
    refund_method VARCHAR(50) DEFAULT 'cash', -- cash, bank_transfer, credit
    
    -- Status and notes
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled')),
    note TEXT,
    attachment_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- Sale Return Items
CREATE TABLE IF NOT EXISTS sale_return_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID REFERENCES sale_returns(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    sale_item_id UUID REFERENCES sale_items(id) ON DELETE SET NULL,
    
    -- Quantities
    original_quantity INTEGER NOT NULL,
    returned_quantity INTEGER NOT NULL CHECK (returned_quantity > 0),
    
    -- Pricing
    price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    
    -- Reason
    reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Returns
CREATE TABLE IF NOT EXISTS purchase_returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE,
    purchase_id UUID REFERENCES purchases(id) ON DELETE RESTRICT,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    
    -- Financial
    total_amount DECIMAL(12,2) NOT NULL,
    refund_method VARCHAR(50) DEFAULT 'cash',
    
    -- Status and notes
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled')),
    note TEXT,
    attachment_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- Purchase Return Items
CREATE TABLE IF NOT EXISTS purchase_return_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID REFERENCES purchase_returns(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    purchase_item_id UUID REFERENCES purchase_items(id) ON DELETE SET NULL,
    
    -- Quantities
    original_quantity INTEGER NOT NULL,
    returned_quantity INTEGER NOT NULL CHECK (returned_quantity > 0),
    
    -- Pricing
    price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    
    -- Reason
    reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ADJUSTMENTS TABLES (Phase 5.4)
-- ============================================

-- Adjustments (Stock adjustments)
CREATE TABLE IF NOT EXISTS adjustments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE,
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE RESTRICT,
    
    -- Adjustment details
    type VARCHAR(20) NOT NULL CHECK (type IN ('increase', 'decrease')),
    reason TEXT NOT NULL,
    total_amount DECIMAL(12,2) DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled')),
    
    -- Notes and attachments
    note TEXT,
    attachment_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- Adjustment Items
CREATE TABLE IF NOT EXISTS adjustment_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    adjustment_id UUID REFERENCES adjustments(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    
    -- Quantity adjustment
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    
    -- Current stock at time of adjustment (for audit)
    current_stock INTEGER NOT NULL,
    new_stock INTEGER NOT NULL,
    
    -- Unit cost for valuation
    unit_cost DECIMAL(12,2) DEFAULT 0,
    total_cost DECIMAL(12,2) DEFAULT 0,
    
    -- Reason for this specific item
    reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TRANSFERS TABLE (Enhanced from 003 migration)
-- ============================================

-- Transfer Items (detailed)
CREATE TABLE IF NOT EXISTS transfer_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transfer_id UUID REFERENCES transfers(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    
    -- Quantities
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    received_quantity INTEGER DEFAULT 0,
    
    -- Status for individual items
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'received', 'partial', 'rejected')),
    
    -- Notes
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- RLS POLICIES FOR NEW TABLES
-- ============================================

ALTER TABLE sale_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE adjustment_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfer_items ENABLE ROW LEVEL SECURITY;

-- Sale Returns policies
CREATE POLICY "Authenticated users can view sale returns" ON sale_returns
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

CREATE POLICY "Cashiers can create sale returns" ON sale_returns
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

CREATE POLICY "Managers can update sale returns" ON sale_returns
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Sale Return Items policies
CREATE POLICY "Authenticated users can view sale return items" ON sale_return_items
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Cashiers can create sale return items" ON sale_return_items
    FOR INSERT TO authenticated WITH CHECK (true);

-- Purchase Returns policies
CREATE POLICY "Authenticated users can view purchase returns" ON purchase_returns
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

CREATE POLICY "Managers can create purchase returns" ON purchase_returns
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Purchase Return Items policies
CREATE POLICY "Authenticated users can view purchase return items" ON purchase_return_items
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

-- Adjustments policies
CREATE POLICY "Authenticated users can view adjustments" ON adjustments
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

CREATE POLICY "Warehouse managers can create adjustments" ON adjustments
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

CREATE POLICY "Managers can update adjustments" ON adjustments
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Adjustment Items policies
CREATE POLICY "Authenticated users can view adjustment items" ON adjustment_items
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

-- Transfer Items policies
CREATE POLICY "Authenticated users can view transfer items" ON transfer_items
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

CREATE POLICY "Warehouse staff can manage transfer items" ON transfer_items
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

CREATE TRIGGER update_sale_returns_updated_at BEFORE UPDATE ON sale_returns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_purchase_returns_updated_at BEFORE UPDATE ON purchase_returns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_adjustments_updated_at BEFORE UPDATE ON adjustments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transfer_items_updated_at BEFORE UPDATE ON transfer_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
