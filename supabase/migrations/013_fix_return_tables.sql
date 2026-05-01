-- Migration: Fix return tables to match updated schema
-- Date: 2024-05-02

-- ============================================
-- FIX SALE RETURN TABLES
-- ============================================

-- Fix sale_return_items table
ALTER TABLE sale_return_items RENAME COLUMN sale_return_id TO return_id;

-- Rename quantity to original_quantity if exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sale_return_items' AND column_name = 'quantity') THEN
        ALTER TABLE sale_return_items RENAME COLUMN quantity TO original_quantity;
    END IF;
END $$;

-- Rename return_quantity to returned_quantity if exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sale_return_items' AND column_name = 'return_quantity') THEN
        ALTER TABLE sale_return_items RENAME COLUMN return_quantity TO returned_quantity;
    END IF;
END $$;

-- Add missing columns (only if not exist)
ALTER TABLE sale_return_items 
    ADD COLUMN IF NOT EXISTS price NUMERIC NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS subtotal NUMERIC NOT NULL DEFAULT 0;

-- Fix sale_returns table
ALTER TABLE sale_returns 
    ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS refund_method VARCHAR(50) DEFAULT 'cash';

-- Drop attachment columns from sale_returns
ALTER TABLE sale_returns DROP COLUMN IF EXISTS attachment_url;
ALTER TABLE sale_returns DROP COLUMN IF EXISTS attachment;

-- Update status constraint
ALTER TABLE sale_returns 
    DROP CONSTRAINT IF EXISTS sale_returns_status_check,
    ADD CONSTRAINT sale_returns_status_check 
    CHECK (status IN ('pending', 'completed', 'cancelled'));

-- Keep created_by referencing admins (actual data references admins, not user_profiles)
-- No change needed for sale_returns.created_by FK

-- ============================================
-- FIX PURCHASE RETURN TABLES
-- ============================================

-- Fix purchase_return_items table
ALTER TABLE purchase_return_items RENAME COLUMN purchase_return_id TO return_id;

-- Rename quantity to returned_quantity if exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'purchase_return_items' AND column_name = 'quantity') THEN
        ALTER TABLE purchase_return_items RENAME COLUMN quantity TO returned_quantity;
    END IF;
END $$;

-- Add missing columns to purchase_return_items
ALTER TABLE purchase_return_items 
    ADD COLUMN IF NOT EXISTS original_quantity INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS price NUMERIC NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS subtotal NUMERIC NOT NULL DEFAULT 0;

-- Fix purchase_returns table
ALTER TABLE purchase_returns 
    ADD COLUMN IF NOT EXISTS supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS total_amount NUMERIC NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS refund_method VARCHAR(50) DEFAULT 'cash';

-- Drop attachment columns from purchase_returns
ALTER TABLE purchase_returns DROP COLUMN IF EXISTS attachment_url;
ALTER TABLE purchase_returns DROP COLUMN IF EXISTS attachment;

-- Update status constraint
ALTER TABLE purchase_returns 
    DROP CONSTRAINT IF EXISTS purchase_returns_status_check,
    ADD CONSTRAINT purchase_returns_status_check 
    CHECK (status IN ('pending', 'completed', 'cancelled'));

-- Keep created_by referencing admins (actual data references admins, not user_profiles)
-- No change needed for purchase_returns.created_by FK

-- ============================================
-- UPDATE RLS POLICIES (if needed)
-- ============================================

-- Ensure RLS is enabled
ALTER TABLE sale_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_return_items ENABLE ROW LEVEL SECURITY;

-- Recreate policies with correct references
DROP POLICY IF EXISTS "Authenticated users can view sale return items" ON sale_return_items;
CREATE POLICY "Authenticated users can view sale return items" ON sale_return_items
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Cashiers can create sale return items" ON sale_return_items;
CREATE POLICY "Cashiers can create sale return items" ON sale_return_items
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated users can view purchase return items" ON purchase_return_items;
CREATE POLICY "Authenticated users can view purchase return items" ON purchase_return_items
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'warehouse'))
    );
