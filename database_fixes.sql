-- ============================================
-- Database Foreign Key Fixes
-- Run this on your backend database (MongoDB/PostgreSQL/MySQL)
-- ============================================
-- This fixes foreign key constraint violations when deleting:
-- - Categories (linked to products/purchases)
-- - Brands (linked to products)
-- - Products (linked to sales/purchases/transfers)
-- ============================================

-- If using PostgreSQL/MySQL with foreign keys:
-- ============================================

-- 1. TRANSFER_PRODUCTS: product_id -> SET NULL on product delete
ALTER TABLE transfer_products
  DROP CONSTRAINT IF EXISTS transfer_products_product_id_fkey;

ALTER TABLE transfer_products
  ADD CONSTRAINT transfer_products_product_id_fkey
  FOREIGN KEY (product_id) REFERENCES products(id)
  ON DELETE SET NULL;

-- 2. PURCHASE_ITEMS: product_id -> SET NULL on product delete
ALTER TABLE purchase_items
  DROP CONSTRAINT IF EXISTS purchase_items_product_id_fkey;

ALTER TABLE purchase_items
  ADD CONSTRAINT purchase_items_product_id_fkey
  FOREIGN KEY (product_id) REFERENCES products(id)
  ON DELETE SET NULL;

-- 3. SALE_ITEMS: product_id -> SET NULL on product delete
ALTER TABLE sale_items
  DROP CONSTRAINT IF EXISTS sale_items_product_id_fkey;

ALTER TABLE sale_items
  ADD CONSTRAINT sale_items_product_id_fkey
  FOREIGN KEY (product_id) REFERENCES products(id)
  ON DELETE SET NULL;

-- 4. ADJUSTMENTS: product_id -> SET NULL on product delete
ALTER TABLE adjustments
  DROP CONSTRAINT IF EXISTS adjustments_product_id_fkey;

ALTER TABLE adjustments
  ADD CONSTRAINT adjustments_product_id_fkey
  FOREIGN KEY (product_id) REFERENCES products(id)
  ON DELETE SET NULL;

-- 5. CATEGORIES: parent_id -> SET NULL on parent category delete
ALTER TABLE categories
  DROP CONSTRAINT IF EXISTS categories_parent_id_fkey;

ALTER TABLE categories
  ADD CONSTRAINT categories_parent_id_fkey
  FOREIGN KEY (parent_id) REFERENCES categories(id)
  ON DELETE SET NULL;

-- 6. PRODUCTS: brand_id -> SET NULL on brand delete
ALTER TABLE products
  DROP CONSTRAINT IF EXISTS products_brand_id_fkey;

ALTER TABLE products
  ADD CONSTRAINT products_brand_id_fkey
  FOREIGN KEY (brand_id) REFERENCES brands(id)
  ON DELETE SET NULL;

-- 7. PURCHASE_ITEMS: category_id -> SET NULL on category delete
ALTER TABLE purchase_items
  DROP CONSTRAINT IF EXISTS purchase_items_category_id_fkey;

ALTER TABLE purchase_items
  ADD CONSTRAINT purchase_items_category_id_fkey
  FOREIGN KEY (category_id) REFERENCES categories(id)
  ON DELETE SET NULL;

-- 8. PRODUCT_CATEGORIES: CASCADE on both sides
ALTER TABLE product_categories
  DROP CONSTRAINT IF EXISTS product_categories_product_id_fkey;

ALTER TABLE product_categories
  ADD CONSTRAINT product_categories_product_id_fkey
  FOREIGN KEY (product_id) REFERENCES products(id)
  ON DELETE CASCADE;

ALTER TABLE product_categories
  DROP CONSTRAINT IF EXISTS product_categories_category_id_fkey;

ALTER TABLE product_categories
  ADD CONSTRAINT product_categories_category_id_fkey
  FOREIGN KEY (category_id) REFERENCES categories(id)
  ON DELETE CASCADE;

-- ============================================
-- If using MongoDB (no foreign keys):
-- ============================================
-- The backend API should handle these checks:
-- 1. Before deleting a category, check if any products reference it
-- 2. Before deleting a brand, check if any products reference it
-- 3. Before deleting a product, check if any sales/purchases/transfers reference it
-- 4. Return appropriate error messages to the frontend
-- ============================================
