-- Migration 037: Seed 10 due customers with sales records that have remaining amounts
-- The "Due Users" screen reads from sales table where remaining_amount > 0
-- So we need both: customers with is_due=true AND sales with remaining_amount > 0

-- ============================================
-- Step 1: Insert 10 due customers
-- ============================================
INSERT INTO public.customers (id, name, email, phone_number, address, is_due, amount_due, status, created_at, updated_at)
VALUES
    ('a1111111-1111-1111-1111-111111111101', 'أحمد محمد العلي', 'ahmed.ali@example.com', '0501234567', 'الرياض - حي النزهة', true, 3500.00, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111102', 'خالد عبدالله السعيد', 'khaled.saeed@example.com', '0559876543', 'جدة - حي الروضة', true, 7200.50, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111103', 'فهد ناصر الدوسري', 'fahd.dosari@example.com', '0541112233', 'الدمام - حي الفيصلية', true, 1500.00, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111104', 'سعود محمد الحربي', 'saud.harbi@example.com', '0567778899', 'مكة - حي العزيزية', true, 4800.75, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111105', 'يوسف إبراهيم القحطاني', 'yousef.qahtani@example.com', '0533334444', 'الخبر - حي العليا', true, 9100.00, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111106', 'عمر سليمان الشمري', 'omar.shamri@example.com', '0522223333', 'المدينة - حي السلام', true, 2250.25, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111107', 'ماجد رشد العتيبي', 'majed.otaibi@example.com', '0511119999', 'تبوك - حي الورود', true, 6350.00, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111108', 'بدر عادل المطيري', 'bader.mutairi@example.com', '0544445555', 'أبها - حي المنهل', true, 560.50, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111109', 'تركي صالح الزهراني', 'turki.zahrani@example.com', '0577776666', 'الطائف - حي النسيم', true, 11800.00, true, NOW(), NOW()),
    ('a1111111-1111-1111-1111-111111111110', 'نايف حسن الغامدي', 'naif.ghamdi@example.com', '0588887777', 'نجران - حي الفيحاء', true, 3420.75, true, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- Step 2: Insert sales records with remaining amounts for each due customer
-- The Due Users screen queries: sales WHERE remaining_amount > 0
-- sales.warehouse_id is NOT NULL, so we use the first existing warehouse
-- ============================================

INSERT INTO public.sales (id, reference, date, customer_id, warehouse_id, grand_total, paid_amount, remaining_amount, sale_status, is_pending, is_due, notes, created_at, updated_at)
VALUES
    ('b2222222-2222-2222-2222-222222222201', 'DUE-001', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111101', (SELECT id FROM public.warehouses LIMIT 1), 5000.00, 1500.00, 3500.00, 'completed', false, true, 'فاتورة مستحقة', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222202', 'DUE-002', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111102', (SELECT id FROM public.warehouses LIMIT 1), 10000.00, 2799.50, 7200.50, 'completed', false, true, 'فاتورة مستحقة', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222203', 'DUE-003', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111103', (SELECT id FROM public.warehouses LIMIT 1), 1500.00, 0.00, 1500.00, 'completed', false, true, 'فاتورة مستحقة - غير مدفوعة', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222204', 'DUE-004', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111104', (SELECT id FROM public.warehouses LIMIT 1), 8000.00, 3199.25, 4800.75, 'completed', false, true, 'فاتورة مستحقة', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222205', 'DUE-005', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111105', (SELECT id FROM public.warehouses LIMIT 1), 12000.00, 2900.00, 9100.00, 'completed', false, true, 'فاتورة مستحقة - مبلغ كبير', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222206', 'DUE-006', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111106', (SELECT id FROM public.warehouses LIMIT 1), 3000.00, 749.75, 2250.25, 'completed', false, true, 'فاتورة مستحقة', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222207', 'DUE-007', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111107', (SELECT id FROM public.warehouses LIMIT 1), 8500.00, 2150.00, 6350.00, 'completed', false, true, 'فاتورة مستحقة', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222208', 'DUE-008', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111108', (SELECT id FROM public.warehouses LIMIT 1), 560.50, 0.00, 560.50, 'completed', false, true, 'فاتورة مستحقة - مبلغ صغير', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222209', 'DUE-009', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111109', (SELECT id FROM public.warehouses LIMIT 1), 15000.00, 3200.00, 11800.00, 'completed', false, true, 'فاتورة مستحقة - أكبر مبلغ', NOW(), NOW()),
    ('b2222222-2222-2222-2222-222222222210', 'DUE-010', CURRENT_DATE, 'a1111111-1111-1111-1111-111111111110', (SELECT id FROM public.warehouses LIMIT 1), 4500.00, 1079.25, 3420.75, 'completed', false, true, 'فاتورة مستحقة', NOW(), NOW())
ON CONFLICT DO NOTHING;
