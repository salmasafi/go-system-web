-- Supabase Migration: Online Orders
-- Creates tables and policies for Online Orders

CREATE TABLE IF NOT EXISTS online_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    branch_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'ready', 'completed', 'cancelled')),
    type VARCHAR(50) DEFAULT 'delivery' CHECK (type IN ('delivery', 'pickup')),
    shipping_address TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    version INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS online_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES online_orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price DECIMAL(12,2) NOT NULL,
    whole_price DECIMAL(12,2),
    start_quantity INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_online_orders_updated_at ON online_orders;
CREATE TRIGGER update_online_orders_updated_at BEFORE UPDATE ON online_orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE online_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE online_order_items ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Authenticated users can view online orders" ON online_orders
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins and Managers can manage online orders" ON online_orders
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

CREATE POLICY "Authenticated users can view online order items" ON online_order_items
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins and Managers can manage online order items" ON online_order_items
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

-- Add RPC to update order status (could also include logic to deduct inventory or create a sale record)
CREATE OR REPLACE FUNCTION update_online_order_status(
    p_order_id UUID,
    p_status VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE online_orders
    SET status = p_status,
        updated_at = NOW()
    WHERE id = p_order_id;
    
    RETURN jsonb_build_object('success', true);
END;
$$;
