# Requirements Document

## Introduction

هذه الميزة تهدف إلى عرض اسم الموديل بناءً على اللغة المحددة في التطبيق. في كل مكان يُعرض فيه اسم موديل يحتوي على حقلَي `name` (الإنجليزية) و `arName` (العربية)، يجب أن يُعرض الاسم المناسب تلقائيًا وفقًا للغة النشطة في التطبيق. يستخدم التطبيق مكتبة `easy_localization` لإدارة اللغات، وتدعم حاليًا اللغتين العربية والإنجليزية.

---

## Glossary

- **App**: تطبيق Flutter الذي يستخدم `easy_localization` لإدارة اللغات.
- **Localizable_Model**: أي موديل (data class) يحتوي على حقلَي `name` (String) و `arName` (String أو String?) في نفس الوقت.
- **Localized_Name**: الاسم المناسب للعرض بناءً على اللغة النشطة — `name` للإنجليزية، `arName` للعربية.
- **Language_Service**: الخدمة المسؤولة عن تحديد اللغة النشطة في التطبيق (`easy_localization` context).
- **Display_Widget**: أي Widget في واجهة المستخدم يعرض اسم موديل.
- **LocalizedNameExtension**: Extension على الـ Dart classes لتوفير getter موحّد يُرجع الاسم المحلّي.

---

## Requirements

### Requirement 1: Getter موحّد للاسم المحلّي

**User Story:** بصفتي مطوّرًا، أريد getter موحّدًا يُرجع الاسم الصحيح بناءً على اللغة، حتى لا أضطر إلى كتابة منطق اختيار اللغة في كل مكان.

#### Acceptance Criteria

1. THE App SHALL توفير آلية مركزية (extension أو mixin أو utility function) تقبل `name` و `arName` وتُرجع الاسم المناسب بناءً على اللغة النشطة.
2. WHEN تكون اللغة النشطة في التطبيق عربية (`languageCode == 'ar'`)، THE App SHALL إرجاع قيمة `arName`.
3. WHEN تكون اللغة النشطة في التطبيق إنجليزية (`languageCode == 'en'`)، THE App SHALL إرجاع قيمة `name`.
4. IF كانت قيمة `arName` فارغة أو null عند اللغة العربية، THEN THE App SHALL إرجاع قيمة `name` كقيمة احتياطية (fallback).
5. IF كانت قيمة `name` فارغة أو null عند اللغة الإنجليزية، THEN THE App SHALL إرجاع قيمة `arName` كقيمة احتياطية (fallback).

---

### Requirement 2: تطبيق الاسم المحلّي على جميع الموديلات

**User Story:** بصفتي مطوّرًا، أريد أن تدعم جميع الموديلات التي تحتوي على `name` و `arName` الحصول على الاسم المحلّي بطريقة موحّدة.

#### Acceptance Criteria

1. THE App SHALL تطبيق آلية الاسم المحلّي على جميع الموديلات التالية التي تحتوي على `name` و `arName`:
   - `CategoryItem`, `ParentCategory` (categories)
   - `ZoneModel`, `CountryForZone`, `CityForZone` (zone)
   - `UnitModel`, `BaseUnit` (units)
   - `CashierModel` (cashier / POS shift)
   - `PaymentMethodModel` (payment methods)
   - `CurrencyModel` (currency)
   - `CountryModel` (country)
   - `CityModel` (city)
   - `TaxModel` (taxes)
   - `VariationModel` (variations)
   - `ExpenseCategoryModel` (expenses category)
   - `CategoryModel`, `SelectionRevenueModel` (revenue)
   - `PosCategory` (POS home)
   - `BankAccountModel` (POS home / bank account)
   - `PurchaseCategoryModel`, `PurchaseBrandModel` (purchase)
2. WHEN يُضاف موديل جديد يحتوي على `name` و `arName`، THE App SHALL دعم الاسم المحلّي بنفس الآلية دون تعديل الكود المركزي.

---

### Requirement 3: عرض الاسم المحلّي في واجهة المستخدم

**User Story:** بصفتي مستخدمًا، أريد رؤية أسماء العناصر بلغتي المفضّلة في جميع شاشات التطبيق.

#### Acceptance Criteria

1. WHEN يعرض Display_Widget اسم موديل من نوع Localizable_Model، THE Display_Widget SHALL استخدام الـ Localized_Name بدلًا من `name` مباشرةً.
2. WHEN يتغيّر المستخدم اللغة في التطبيق، THE App SHALL تحديث جميع الأسماء المعروضة لتعكس اللغة الجديدة فورًا دون الحاجة لإعادة تشغيل التطبيق.
3. WHILE تكون اللغة العربية نشطة، THE App SHALL عرض `arName` في جميع الـ Display_Widgets التي تعرض Localizable_Models.
4. WHILE تكون اللغة الإنجليزية نشطة، THE App SHALL عرض `name` في جميع الـ Display_Widgets التي تعرض Localizable_Models.

---

### Requirement 4: الاتساق مع نظام اللغة الحالي

**User Story:** بصفتي مطوّرًا، أريد أن تتكامل هذه الميزة مع نظام `easy_localization` الموجود دون إضافة تبعيات جديدة.

#### Acceptance Criteria

1. THE Language_Service SHALL استخدام `context.locale.languageCode` من `easy_localization` لتحديد اللغة النشطة.
2. THE App SHALL عدم إضافة أي حالة (state) إضافية لتتبع اللغة، والاعتماد على `context.locale` فقط.
3. WHERE يكون الـ Widget يحتاج إلى `BuildContext` لتحديد اللغة، THE App SHALL تمرير الـ context إلى الـ getter أو استخدام extension على BuildContext.

---

### Requirement 5: عدم تأثير التغيير على منطق الـ API

**User Story:** بصفتي مطوّرًا، أريد أن تبقى حقول `name` و `arName` في الموديلات كما هي دون تعديل، حتى لا يتأثر منطق الـ API والـ serialization.

#### Acceptance Criteria

1. THE App SHALL الإبقاء على حقلَي `name` و `arName` في جميع الموديلات دون تعديل أو حذف.
2. THE App SHALL عدم تعديل منطق `fromJson` / `toJson` في أي موديل.
3. THE App SHALL إضافة الـ Localized_Name getter كـ computed property أو extension فقط، دون تغيير بنية الموديل.
