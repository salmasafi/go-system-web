# دليل شامل: جعل الصور اختيارية في التطبيق

## 📋 نظرة عامة

تم تعديل التطبيق بالكامل لجعل الصور **اختيارية** في جميع الأقسام. يمكنك الآن إضافة أو تعديل العناصر بدون رفع صور.

---

## ✅ التعديلات المطبقة

### 1️⃣ **المنتجات (Products)**

#### الملفات المعدلة:
- ✅ `lib/features/admin/product/presentation/screens/add_product_screen.dart`
- ✅ `lib/features/admin/product/presentation/screens/edit_product_screen.dart`
- ✅ `lib/features/admin/product/cubit/get_products_cubit/product_cubit.dart`

#### التغييرات:
- ❌ **تم إزالة**: التحقق من وجود الصورة الرئيسية قبل الحفظ
- ✅ **تم إضافة**: معامل `image` أصبح اختياري (`String?`)
- ✅ **تم إضافة**: إرسال الصورة فقط إذا كانت موجودة: `if (image != null && image.isNotEmpty) 'image': image`

---

### 2️⃣ **الفئات (Categories)**

#### الملفات المعدلة:
- ✅ `lib/features/admin/categories/view/create_category_screen.dart`
- ✅ `lib/features/admin/categories/cubit/categories_cubit.dart`

#### التغييرات:
- ❌ **تم إزالة**: التحقق من وجود الصورة قبل الحفظ
- ✅ **تم إضافة**: معامل `imageFile` أصبح اختياري (`File?`)
- ✅ **تم إضافة**: إرسال الصورة فقط إذا كانت موجودة: `if (base64Image != null) 'image': base64Image`

---

### 3️⃣ **العلامات التجارية (Brands)**

#### الملفات المعدلة:
- ✅ `lib/features/admin/brands/view/create_brand_screen.dart`
- ✅ `lib/features/admin/brands/cubit/brand_cubit.dart`

#### التغييرات:
- ❌ **تم إزالة**: التحقق من وجود الشعار قبل الحفظ
- ✅ **تم إضافة**: معامل `logoFile` أصبح اختياري (`File?`)
- ✅ **تم إضافة**: إرسال الشعار فقط إذا كان موجود: `if (base64Logo != null) 'logo': base64Logo`

---

### 4️⃣ **الحزم (Bundles/Pandel)**

#### الملفات المعدلة:
- ✅ `lib/features/admin/pandel/presentation/view/create_pandel_screen.dart`
- ✅ `lib/features/admin/pandel/cubit/pandel_cubit.dart`

#### التغييرات:
- ❌ **تم إزالة**: التحقق من وجود صورة واحدة على الأقل
- ✅ **تم إضافة**: معامل `images` أصبح اختياري (`List<File>?`)
- ✅ **تم إضافة**: إرسال الصور فقط إذا كانت موجودة: `if (base64Images.isNotEmpty) "images": base64Images`

---

### 5️⃣ **النوافذ المنبثقة (Popups)**

#### الملفات المعدلة:
- ✅ `lib/features/admin/popup/presentation/view/create_popup_screen.dart`
- ✅ `lib/features/admin/popup/cubit/popup_cubit.dart`

#### التغييرات:
- ❌ **تم إزالة**: التحقق من وجود الصورة الإنجليزية والعربية
- ✅ **تم إضافة**: معامل `image` أصبح اختياري (`File?`)
- ✅ **تم إضافة**: إرسال الصورة فقط إذا كانت موجودة: `if (base64Image != null) "image": base64Image`

---

## 🗄️ تحديثات قاعدة البيانات (Supabase)

### ⚠️ **مهم جداً**: يجب تشغيل أوامر SQL التالية

افتح **Supabase SQL Editor** وقم بتشغيل الأوامر التالية:

```sql
-- جعل عمود الصورة في جدول المنتجات اختياري
ALTER TABLE products 
ALTER COLUMN image DROP NOT NULL;

-- جعل عمود الصورة في جدول الفئات اختياري
ALTER TABLE categories 
ALTER COLUMN image DROP NOT NULL;

-- جعل عمود الشعار في جدول العلامات التجارية اختياري
ALTER TABLE brands 
ALTER COLUMN logo DROP NOT NULL;

-- جعل عمود الصور في جدول الحزم اختياري
ALTER TABLE bundles 
ALTER COLUMN images DROP NOT NULL;

-- جعل عمود الصورة في جدول النوافذ المنبثقة اختياري
ALTER TABLE popups 
ALTER COLUMN image DROP NOT NULL;
```

### ✅ التحقق من التطبيق:

```sql
-- التحقق من جدول المنتجات
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'products' AND column_name = 'image';

-- يجب أن تكون النتيجة: is_nullable = 'YES'
```

---

## 🎯 كيفية الاستخدام

### إضافة منتج بدون صورة:
1. افتح شاشة إضافة منتج
2. املأ البيانات المطلوبة (الاسم، السعر، إلخ)
3. **لا تقم برفع صورة**
4. اضغط على "حفظ"
5. ✅ سيتم حفظ المنتج بنجاح بدون صورة

### إضافة فئة بدون صورة:
1. افتح شاشة إضافة فئة
2. أدخل اسم الفئة
3. **لا تقم برفع صورة**
4. اضغط على "حفظ"
5. ✅ سيتم حفظ الفئة بنجاح بدون صورة

### إضافة علامة تجارية بدون شعار:
1. افتح شاشة إضافة علامة تجارية
2. أدخل اسم العلامة
3. **لا تقم برفع شعار**
4. اضغط على "حفظ"
5. ✅ سيتم حفظ العلامة بنجاح بدون شعار

---

## 🖼️ عرض الصور الافتراضية

عند عدم وجود صورة، سيتم عرض:
- أيقونة افتراضية
- صورة placeholder
- أيقونة تمثل نوع العنصر (منتج، فئة، إلخ)

---

## 🔧 الملفات المعدلة (قائمة كاملة)

### شاشات العرض:
1. `lib/features/admin/product/presentation/screens/add_product_screen.dart`
2. `lib/features/admin/product/presentation/screens/edit_product_screen.dart`
3. `lib/features/admin/categories/view/create_category_screen.dart`
4. `lib/features/admin/brands/view/create_brand_screen.dart`
5. `lib/features/admin/pandel/presentation/view/create_pandel_screen.dart`
6. `lib/features/admin/popup/presentation/view/create_popup_screen.dart`

### Cubits (منطق الأعمال):
1. `lib/features/admin/product/cubit/get_products_cubit/product_cubit.dart`
2. `lib/features/admin/categories/cubit/categories_cubit.dart`
3. `lib/features/admin/brands/cubit/brand_cubit.dart`
4. `lib/features/admin/pandel/cubit/pandel_cubit.dart`
5. `lib/features/admin/popup/cubit/popup_cubit.dart`

### قاعدة البيانات:
- `supabase_schema_updates.sql` - أوامر SQL لتحديث الجداول

---

## ⚡ خطوات التشغيل السريع

### 1. تشغيل أوامر SQL:
```bash
# افتح Supabase Dashboard
# اذهب إلى SQL Editor
# انسخ والصق محتوى ملف supabase_schema_updates.sql
# اضغط Run
```

### 2. تشغيل التطبيق:
```bash
flutter clean
flutter pub get
flutter run
```

### 3. اختبار الميزة:
- جرب إضافة منتج بدون صورة ✅
- جرب إضافة فئة بدون صورة ✅
- جرب إضافة علامة تجارية بدون شعار ✅
- جرب إضافة حزمة بدون صور ✅

---

## 🐛 حل المشاكل

### المشكلة: لا يزال يظهر خطأ عند الحفظ بدون صورة

**الحل:**
1. تأكد من تشغيل أوامر SQL في Supabase
2. تأكد من تحديث الكود بالكامل
3. قم بعمل `flutter clean` ثم `flutter run`

### المشكلة: الصورة لا تظهر بعد الحفظ

**الحل:**
- هذا طبيعي! لم يتم رفع صورة
- سيتم عرض أيقونة افتراضية بدلاً منها

---

## 📝 ملاحظات مهمة

1. ✅ **جميع التعديلات مطبقة** في الكود
2. ⚠️ **يجب تشغيل أوامر SQL** في Supabase
3. 🔄 **التعديلات متوافقة** مع الكود الموجود
4. 🎨 **لا تؤثر** على العناصر التي تحتوي على صور بالفعل
5. 🚀 **جاهزة للاستخدام** فوراً بعد تشغيل SQL

---

## ✨ الخلاصة

تم بنجاح جعل الصور **اختيارية** في:
- ✅ المنتجات
- ✅ الفئات
- ✅ العلامات التجارية
- ✅ الحزم
- ✅ النوافذ المنبثقة

**الخطوة التالية:** قم بتشغيل أوامر SQL في Supabase!

---

تاريخ التحديث: 2026-04-30
