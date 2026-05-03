-- Supabase Migration: Row Level Security (RLS) Policies
-- This script enables RLS and creates policies for all tables

-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE units ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouse_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE due_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE migration_logs ENABLE ROW LEVEL SECURITY;

-- Product Attributes Tables (New)
ALTER TABLE attribute_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE attribute_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_item_attributes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USER PROFILES POLICIES
-- ============================================

CREATE POLICY "Users can view their own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON user_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- REFERENCE DATA POLICIES (Categories, Brands, Units, etc.)
-- ============================================

-- Categories: All authenticated users can read, only admins can modify
CREATE POLICY "Authenticated users can view categories" ON categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can insert categories" ON categories
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Only admins can update categories" ON categories
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Only admins can delete categories" ON categories
    FOR DELETE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Brands: Same as categories
CREATE POLICY "Authenticated users can view brands" ON brands
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify brands" ON brands
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Units: Same as categories
CREATE POLICY "Authenticated users can view units" ON units
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify units" ON units
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Countries & Cities: Read-only for all authenticated users
CREATE POLICY "Authenticated users can view countries" ON countries
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can view cities" ON cities
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify locations" ON countries
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Only admins can modify cities" ON cities
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Payment Methods
CREATE POLICY "Authenticated users can view payment methods" ON payment_methods
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify payment methods" ON payment_methods
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- ============================================
-- PRODUCTS POLICIES
-- ============================================

CREATE POLICY "Authenticated users can view products" ON products
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins and managers can modify products" ON products
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Product Categories (Join Table)
CREATE POLICY "Authenticated users can view product categories" ON product_categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins and managers can modify product categories" ON product_categories
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- ============================================
-- CUSTOMERS POLICIES
-- ============================================

CREATE POLICY "Authenticated users can view customers" ON customers
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can create customers" ON customers
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Only admins and managers can update customers" ON customers
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

CREATE POLICY "Only admins can delete customers" ON customers
    FOR DELETE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Customer Groups
CREATE POLICY "Authenticated users can view customer groups" ON customer_groups
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify customer groups" ON customer_groups
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- ============================================
-- SUPPLIERS POLICIES
-- ============================================

CREATE POLICY "Authenticated users can view suppliers" ON suppliers
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins and managers can modify suppliers" ON suppliers
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- ============================================
-- WAREHOUSES POLICIES
-- ============================================

CREATE POLICY "Authenticated users can view warehouses" ON warehouses
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins and managers can modify warehouses" ON warehouses
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Warehouse Products
CREATE POLICY "Authenticated users can view warehouse inventory" ON warehouse_products
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins and managers can modify inventory" ON warehouse_products
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

-- ============================================
-- SALES POLICIES
-- ============================================

CREATE POLICY "Users can view sales in their warehouse" ON sales
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() 
            AND (role IN ('admin', 'manager') OR 
                 (role = 'cashier' AND warehouse_id IN (
                     SELECT warehouse_id FROM user_profiles WHERE id = auth.uid()
                 )))
        )
    );

CREATE POLICY "Cashiers can create sales" ON sales
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

CREATE POLICY "Cashiers can update their own sales" ON sales
    FOR UPDATE TO authenticated USING (
        cashier_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Sale Items
CREATE POLICY "Authenticated users can view sale items" ON sale_items
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM sales s WHERE s.id = sale_id AND (
            s.cashier_id = auth.uid() OR
            EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
        ))
    );

CREATE POLICY "Cashiers can create sale items" ON sale_items
    FOR INSERT TO authenticated WITH CHECK (true);

-- Sale Payments
CREATE POLICY "Authenticated users can view sale payments" ON sale_payments
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Cashiers can create sale payments" ON sale_payments
    FOR INSERT TO authenticated WITH CHECK (true);

-- ============================================
-- PURCHASES POLICIES
-- ============================================

CREATE POLICY "Authenticated users can view purchases" ON purchases
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

CREATE POLICY "Only admins and managers can create purchases" ON purchases
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Only admins and managers can update purchases" ON purchases
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Purchase Items
CREATE POLICY "Authenticated users can view purchase items" ON purchase_items
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );

CREATE POLICY "Managers can create purchase items" ON purchase_items
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- ============================================
-- FINANCIAL POLICIES
-- ============================================

-- Invoices
CREATE POLICY "Authenticated users can view invoices" ON invoices
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Due Payments
CREATE POLICY "Authenticated users can view due payments" ON due_payments
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Managers can create due payments" ON due_payments
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- ============================================
-- MIGRATION LOGS POLICIES (Admin only)
-- ============================================

CREATE POLICY "Only admins can view migration logs" ON migration_logs
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "Only admins can modify migration logs" ON migration_logs
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- ============================================
-- PRODUCT ATTRIBUTES POLICIES (New)
-- ============================================

-- Attribute Types: All authenticated users can read, only admins can modify
CREATE POLICY "Authenticated users can view attribute types" ON attribute_types
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify attribute types" ON attribute_types
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Attribute Values: Same as attribute types
CREATE POLICY "Authenticated users can view attribute values" ON attribute_values
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify attribute values" ON attribute_values
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Product Attributes: All authenticated users can read, only admins can modify
CREATE POLICY "Authenticated users can view product attributes" ON product_attributes
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Only admins can modify product attributes" ON product_attributes
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Sale Item Attributes: Users can view sale items in their context
CREATE POLICY "Authenticated users can view sale item attributes" ON sale_item_attributes
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM sale_items si
            JOIN sales s ON s.id = si.sale_id
            WHERE si.id = sale_item_id AND (
                s.cashier_id = auth.uid() OR
                EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
            )
        )
    );

CREATE POLICY "Cashiers can create sale item attributes" ON sale_item_attributes
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );
