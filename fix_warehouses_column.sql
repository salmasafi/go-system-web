-- إضافة عمود number_of_products إلى جدول warehouses
ALTER TABLE warehouses
ADD COLUMN IF NOT EXISTS number_of_products INTEGER DEFAULT 0;

-- تحديث القيم الموجودة بناءً على عدد المنتجات الفعلي
UPDATE warehouses w
SET number_of_products = (
    SELECT COUNT(*) 
    FROM warehouse_products 
    WHERE warehouse_id = w.id
);

-- التحقق من النتيجة
SELECT id, name, number_of_products, stock_quantity 
FROM warehouses;
