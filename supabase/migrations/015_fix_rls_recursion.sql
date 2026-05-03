-- Supabase Migration: Fix RLS Infinite Recursion
-- This migration fixes the infinite recursion caused by policies that query user_profiles
-- within their USING/WITH CHECK clauses

-- ============================================
-- Create Security Definer Functions to Check User Role
-- These functions bypass RLS (SECURITY DEFINER) to avoid recursion
-- ============================================

-- Function to check if a user is an admin
CREATE OR REPLACE FUNCTION is_admin(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE id = user_uuid AND role = 'admin'
    );
END;
$$;

-- Function to check if a user has a specific role
CREATE OR REPLACE FUNCTION has_role(user_uuid UUID, role_name TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE id = user_uuid AND role = role_name
    );
END;
$$;

-- Function to check if a user has any of the specified roles
CREATE OR REPLACE FUNCTION has_any_role(user_uuid UUID, role_names TEXT[])
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE id = user_uuid AND role = ANY(role_names)
    );
END;
$$;

-- ============================================
-- Fix user_profiles Policies
-- ============================================

-- Drop the recursive policy
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;

-- Recreate using the security definer function
CREATE POLICY "Admins can view all profiles" ON user_profiles
    FOR SELECT USING (
        is_admin(auth.uid())
    );

-- ============================================
-- Fix roles table Policies
-- ============================================

DROP POLICY IF EXISTS "Admins can manage roles" ON roles;

CREATE POLICY "Admins can manage roles" ON roles
    FOR ALL TO authenticated USING (
        is_admin(auth.uid())
    );

-- ============================================
-- Fix permissions table Policies
-- ============================================

DROP POLICY IF EXISTS "Admins can manage permissions" ON permissions;

CREATE POLICY "Admins can manage permissions" ON permissions
    FOR ALL TO authenticated USING (
        is_admin(auth.uid())
    );

-- ============================================
-- Fix role_permissions table Policies
-- ============================================

DROP POLICY IF EXISTS "Admins can manage role_permissions" ON role_permissions;

CREATE POLICY "Admins can manage role_permissions" ON role_permissions
    FOR ALL TO authenticated USING (
        is_admin(auth.uid())
    );

-- ============================================
-- Fix categories Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can insert categories" ON categories;
DROP POLICY IF EXISTS "Only admins can update categories" ON categories;
DROP POLICY IF EXISTS "Only admins can delete categories" ON categories;

CREATE POLICY "Only admins can insert categories" ON categories
    FOR INSERT TO authenticated WITH CHECK (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

CREATE POLICY "Only admins can update categories" ON categories
    FOR UPDATE TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

CREATE POLICY "Only admins can delete categories" ON categories
    FOR DELETE TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix brands Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can modify brands" ON brands;

CREATE POLICY "Only admins can modify brands" ON brands
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix units Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can modify units" ON units;

CREATE POLICY "Only admins can modify units" ON units
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix countries & cities Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can modify locations" ON countries;
DROP POLICY IF EXISTS "Only admins can modify cities" ON cities;

CREATE POLICY "Only admins can modify locations" ON countries
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

CREATE POLICY "Only admins can modify cities" ON cities
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix payment_methods Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can modify payment methods" ON payment_methods;

CREATE POLICY "Only admins can modify payment methods" ON payment_methods
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix products Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins and managers can modify products" ON products;

CREATE POLICY "Only admins and managers can modify products" ON products
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix product_categories Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins and managers can modify product categories" ON product_categories;

CREATE POLICY "Only admins and managers can modify product categories" ON product_categories
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix customers Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins and managers can update customers" ON customers;
DROP POLICY IF EXISTS "Only admins can delete customers" ON customers;

CREATE POLICY "Only admins and managers can update customers" ON customers
    FOR UPDATE TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'cashier'])
    );

CREATE POLICY "Only admins can delete customers" ON customers
    FOR DELETE TO authenticated USING (
        is_admin(auth.uid())
    );

-- ============================================
-- Fix customer_groups Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can modify customer groups" ON customer_groups;

CREATE POLICY "Only admins can modify customer groups" ON customer_groups
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix suppliers Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins and managers can modify suppliers" ON suppliers;

CREATE POLICY "Only admins and managers can modify suppliers" ON suppliers
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix warehouses Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins and managers can modify warehouses" ON warehouses;

CREATE POLICY "Only admins and managers can modify warehouses" ON warehouses
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix warehouse_products Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins and managers can modify inventory" ON warehouse_products;

CREATE POLICY "Only admins and managers can modify inventory" ON warehouse_products
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'warehouse'])
    );

-- ============================================
-- Fix sales Policies
-- ============================================

DROP POLICY IF EXISTS "Users can view sales in their warehouse" ON sales;
DROP POLICY IF EXISTS "Cashiers can create sales" ON sales;
DROP POLICY IF EXISTS "Cashiers can update their own sales" ON sales;

CREATE POLICY "Users can view sales in their warehouse" ON sales
    FOR SELECT TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager']) OR
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() 
            AND role = 'cashier' 
            AND warehouse_id IN (
                SELECT warehouse_id FROM user_profiles WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY "Cashiers can create sales" ON sales
    FOR INSERT TO authenticated WITH CHECK (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'cashier'])
    );

CREATE POLICY "Cashiers can update their own sales" ON sales
    FOR UPDATE TO authenticated USING (
        cashier_id = auth.uid() OR 
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix sale_items Policies
-- ============================================

DROP POLICY IF EXISTS "Authenticated users can view sale items" ON sale_items;

CREATE POLICY "Authenticated users can view sale items" ON sale_items
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM sales s WHERE s.id = sale_id AND (
            s.cashier_id = auth.uid() OR
            has_any_role(auth.uid(), ARRAY['admin', 'manager'])
        ))
    );

-- ============================================
-- Fix purchases Policies
-- ============================================

DROP POLICY IF EXISTS "Authenticated users can view purchases" ON purchases;
DROP POLICY IF EXISTS "Only admins and managers can create purchases" ON purchases;
DROP POLICY IF EXISTS "Only admins and managers can update purchases" ON purchases;

CREATE POLICY "Authenticated users can view purchases" ON purchases
    FOR SELECT TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'warehouse'])
    );

CREATE POLICY "Only admins and managers can create purchases" ON purchases
    FOR INSERT TO authenticated WITH CHECK (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

CREATE POLICY "Only admins and managers can update purchases" ON purchases
    FOR UPDATE TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix purchase_items Policies
-- ============================================

DROP POLICY IF EXISTS "Authenticated users can view purchase items" ON purchase_items;
DROP POLICY IF EXISTS "Managers can create purchase items" ON purchase_items;

CREATE POLICY "Authenticated users can view purchase items" ON purchase_items
    FOR SELECT TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'warehouse'])
    );

CREATE POLICY "Managers can create purchase items" ON purchase_items
    FOR INSERT TO authenticated WITH CHECK (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix invoices Policies
-- ============================================

DROP POLICY IF EXISTS "Authenticated users can view invoices" ON invoices;

CREATE POLICY "Authenticated users can view invoices" ON invoices
    FOR SELECT TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix due_payments Policies
-- ============================================

DROP POLICY IF EXISTS "Authenticated users can view due payments" ON due_payments;
DROP POLICY IF EXISTS "Managers can create due payments" ON due_payments;

CREATE POLICY "Authenticated users can view due payments" ON due_payments
    FOR SELECT TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

CREATE POLICY "Managers can create due payments" ON due_payments
    FOR INSERT TO authenticated WITH CHECK (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix migration_logs Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can view migration logs" ON migration_logs;
DROP POLICY IF EXISTS "Only admins can modify migration logs" ON migration_logs;

CREATE POLICY "Only admins can view migration logs" ON migration_logs
    FOR SELECT TO authenticated USING (
        is_admin(auth.uid())
    );

CREATE POLICY "Only admins can modify migration logs" ON migration_logs
    FOR ALL TO authenticated USING (
        is_admin(auth.uid())
    );

-- ============================================
-- Fix product attributes Policies
-- ============================================

DROP POLICY IF EXISTS "Only admins can modify attribute types" ON attribute_types;
DROP POLICY IF EXISTS "Only admins can modify attribute values" ON attribute_values;
DROP POLICY IF EXISTS "Only admins can modify product attributes" ON product_attributes;

CREATE POLICY "Only admins can modify attribute types" ON attribute_types
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

CREATE POLICY "Only admins can modify attribute values" ON attribute_values
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

CREATE POLICY "Only admins can modify product attributes" ON product_attributes
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager'])
    );

-- ============================================
-- Fix sale_item_attributes Policies
-- ============================================

DROP POLICY IF EXISTS "Authenticated users can view sale item attributes" ON sale_item_attributes;
DROP POLICY IF EXISTS "Cashiers can create sale item attributes" ON sale_item_attributes;

CREATE POLICY "Authenticated users can view sale item attributes" ON sale_item_attributes
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM sale_items si
            JOIN sales s ON s.id = si.sale_id
            WHERE si.id = sale_item_id AND (
                s.cashier_id = auth.uid() OR
                has_any_role(auth.uid(), ARRAY['admin', 'manager'])
            )
        )
    );

CREATE POLICY "Cashiers can create sale item attributes" ON sale_item_attributes
    FOR INSERT TO authenticated WITH CHECK (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'cashier'])
    );

-- ============================================
-- Fix notifications Policies
-- ============================================

DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;
DROP POLICY IF EXISTS "Admins can create notifications" ON notifications;

CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT TO authenticated USING (
        user_id = auth.uid() OR is_admin(auth.uid())
    );

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE TO authenticated USING (
        user_id = auth.uid() OR is_admin(auth.uid())
    );

CREATE POLICY "Admins can create notifications" ON notifications
    FOR INSERT TO authenticated WITH CHECK (
        is_admin(auth.uid())
    );

-- ============================================
-- Fix online_orders Policies
-- ============================================

DROP POLICY IF EXISTS "Admins and Managers can manage online orders" ON online_orders;
DROP POLICY IF EXISTS "Admins and Managers can manage online order items" ON online_order_items;

CREATE POLICY "Admins and Managers can manage online orders" ON online_orders
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'cashier'])
    );

CREATE POLICY "Admins and Managers can manage online order items" ON online_order_items
    FOR ALL TO authenticated USING (
        has_any_role(auth.uid(), ARRAY['admin', 'manager', 'cashier'])
    );

-- ============================================
-- Grant execute permissions on functions to authenticated users
-- ============================================

GRANT EXECUTE ON FUNCTION is_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION has_role(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION has_any_role(UUID, TEXT[]) TO authenticated;
