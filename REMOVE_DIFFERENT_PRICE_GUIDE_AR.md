# دليل إزالة الأسعار المختلفة للمنتج الواحد

## نظرة عامة
تم إلغاء فكرة الأسعار المختلفة للمنتج الواحد. الآن كل منتج له سعر واحد فقط، مع إمكانية إضافة attributes و options للعرض والاختيار فقط (بدون تأثير على السعر).

## التغييرات في قاعدة البيانات (Supabase)

### 1. الجداول المحذوفة
- ✅ `product_prices` - جدول الأسعار المختلفة للمنتج
- ✅ `product_price_options` - جدول ربط الأسعار بالخيارات

### 2. الأعمدة المحذوفة
- ✅ `products.different_price` - علم الأسعار المختلفة
- ✅ `sale_items.product_price_id` - مرجع السعر المحدد
- ✅ `purchase_item_options.product_price_id`
- ✅ `online_order_items.product_price_id`
- ✅ `bundle_products.product_price_id`
- ✅ `sale_return_items.product_price_id`
- ✅ `purchase_return_items.product_price_id`

### 3. التحديثات
- ✅ تحديث دالة `check_product_attributes_eligibility()` - الآن تسمح بالـ attributes دائماً
- ✅ إضافة تعليقات توضيحية للجداول

## التغييرات المطلوبة في Flutter

### 1. النماذج (Models)

#### ✅ نماذج لا تحتاج تعديل (تم التحقق)
- `lib/features/admin/product/models/product_model.dart` - لا يحتوي على differentPrice أو prices
- `lib/features/pos/home/model/pos_models.dart` - لا يحتوي على differentPrice أو prices

#### ⚠️ نماذج تحتاج تعديل
1. **lib/features/admin/purchase/model/purchase_model.dart**
   - حذف `final bool differentPrice` من class Product
   - حذف `final String? productPriceId` من class PurchaseItemModel
   - حذف class VariationModel
   - حذف class ProductPrice

2. **lib/features/pos/return/models/return_item_model.dart**
   - حذف `final String productPriceId`
   - تحديث fromJson و constructor

3. **lib/features/pos/history/model/pending_sale_details_model.dart**
   - حذف `final String? productPriceId` من PendingSaleProductItem

4. **lib/features/admin/pandel/model/pandel_model.dart**
   - حذف `final String? productPriceId` من PandelProduct

### 2. الواجهات (UI)

#### ⚠️ ملفات تحتاج تعديل
1. **lib/features/admin/product/presentation/screens/edit_product_screen.dart**
   - حذف `bool _differentPrice`
   - حذف قسم Price Variations
   - حذف الـ Switch الخاص بـ Different Prices

2. **lib/features/admin/product/presentation/screens/product_details_screen.dart**
   - حذف عرض Different Prices

3. **lib/features/admin/product/presentation/widgets/product_attribute_assignment_widget.dart**
   - حذف `final bool differentPrice`
   - حذف التحقق من differentPrice

4. **lib/features/pos/home/presentation/view/pos_home_screen.dart**
   - حذف التحقق من `product.differentPrice`
   - حذف عرض Price Variations

5. **lib/features/pos/home/presentation/widgets/product_details_dialog.dart**
   - حذف عرض "From" في السعر

6. **lib/features/pos/home/presentation/widgets/product_grid.dart**
   - حذف التحقق من `product.differentPrice`

7. **lib/features/pos/home/presentation/widgets/product_card.dart**
   - حذف عرض "From" في السعر

8. **lib/features/pos/history/presentation/views/pending_sale_details_screen.dart**
   - حذف التحقق من `productPriceId`

9. **lib/features/admin/purchase/presentation/view/create_purchase_screen.dart**
   - حذف `_showVariationSelectionDialog`
   - حذف التحقق من `product.differentPrice`

10. **lib/features/admin/print_labels/presentation/view/print_labels_screen.dart**
    - حذف التحقق من `product.differentPrice`

11. **lib/features/admin/print_labels/presentation/widgets/product_card.dart**
    - حذف عرض "From" في السعر

### 3. المستودعات (Repositories)

#### ⚠️ ملفات تحتاج تعديل
1. **lib/features/pos/return/data/repositories/return_repository.dart**
   - تحديث إنشاء ReturnItemModel (حذف productPriceId)

2. **lib/features/pos/return/cubit/return_cubit.dart**
   - تحديث إرسال البيانات (حذف product_price_id)

### 4. الاختبارات (Tests)

#### ⚠️ ملفات تحتاج تعديل
1. **test/features/pos/return/models/return_sale_model_test.dart**
   - تحديث الاختبارات (حذف productPriceId)

2. **test/features/pos/return/cubit/return_cubit_test.dart**
   - تحديث الاختبارات (حذف productPriceId)

## خطوات التطبيق

### 1. تطبيق Migration في Supabase
```bash
# تشغيل الـ migration
supabase db push
```

### 2. تحديث الكود في Flutter
1. تحديث النماذج (Models)
2. تحديث الواجهات (UI)
3. تحديث المستودعات (Repositories)
4. تحديث الاختبارات (Tests)

### 3. الاختبار
1. اختبار إضافة منتج جديد
2. اختبار تعديل منتج موجود
3. اختبار إضافة attributes للمنتج
4. اختبار البيع مع attributes
5. اختبار المرتجعات
6. اختبار المشتريات

## ملاحظات مهمة

### الـ Attributes
- الآن يمكن إضافة attributes لأي منتج
- الـ attributes للعرض والاختيار فقط
- الـ attributes لا تؤثر على السعر
- السعر الوحيد للمنتج موجود في `products.price`

### البيانات الموجودة
- البيانات الموجودة في `product_prices` ستُحذف
- يجب التأكد من نسخ احتياطي قبل التطبيق
- المبيعات السابقة ستبقى كما هي (لأن السعر مخزن في sale_items.price)

### التوافق مع الإصدارات السابقة
- الكود القديم الذي يستخدم `differentPrice` سيحتاج تحديث
- الكود القديم الذي يستخدم `product_price_id` سيحتاج تحديث
- يُنصح بتحديث جميع الملفات دفعة واحدة

## الخطوات التالية
1. ✅ إنشاء migration في Supabase
2. ⏳ تحديث النماذج في Flutter
3. ⏳ تحديث الواجهات في Flutter
4. ⏳ تحديث المستودعات في Flutter
5. ⏳ تحديث الاختبارات
6. ⏳ اختبار شامل
7. ⏳ نشر التحديث
