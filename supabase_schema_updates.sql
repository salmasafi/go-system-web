-- ============================================
-- SQL Commands to Make Image Columns Optional
-- ============================================
-- Run these commands in your Supabase SQL Editor
-- to make all image columns nullable (optional)
-- ============================================

-- Make products.image column optional
ALTER TABLE products 
ALTER COLUMN image DROP NOT NULL;

-- Make categories.image column optional
ALTER TABLE categories 
ALTER COLUMN image DROP NOT NULL;

-- Make brands.logo column optional
ALTER TABLE brands 
ALTER COLUMN logo DROP NOT NULL;

-- Make bundles.images column optional (if exists)
-- Note: Check your actual table name - it might be 'pandels' or 'bundles'
ALTER TABLE bundles 
ALTER COLUMN images DROP NOT NULL;

-- Alternative if table is named 'pandels'
-- ALTER TABLE pandels 
-- ALTER COLUMN images DROP NOT NULL;

-- Make popups.image column optional
ALTER TABLE popups 
ALTER COLUMN image DROP NOT NULL;

-- Make suppliers.image column optional (if exists)
-- ALTER TABLE suppliers 
-- ALTER COLUMN image DROP NOT NULL;

-- Make bank_accounts.image column optional (if exists)
-- ALTER TABLE bank_accounts 
-- ALTER COLUMN image DROP NOT NULL;

-- Make adjustments.image column optional (if exists)
-- ALTER TABLE adjustments 
-- ALTER COLUMN image DROP NOT NULL;

-- ============================================
-- Verification Queries
-- ============================================
-- Run these to verify the changes were applied:

-- Check products table
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'products' AND column_name = 'image';

-- Check categories table
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'categories' AND column_name = 'image';

-- Check brands table
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'brands' AND column_name = 'logo';

-- Check bundles/pandels table
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'bundles' AND column_name = 'images';

-- Check popups table
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'popups' AND column_name = 'image';

-- ============================================
-- Expected Result: is_nullable should be 'YES'
-- ============================================
