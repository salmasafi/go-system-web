# Implementation Plan: POS Bundles

## Overview

إضافة تبويب Bundles في POS Home بنفس نمط الكود الموجود (Cubit + BlocBuilder)، مع نماذج بيانات، ويدجت بطاقات، وDialog للتفاصيل.

## Tasks

- [x] 1. إضافة BundleModel و BundleProduct في pos_models.dart
  - إضافة class `BundleProduct` و `BundleModel` مع `fromJson()`
  - _Requirements: 5.1, 5.2_

  - [x] 1.1 كتابة property test لـ BundleModel.fromJson round-trip
    - **Property 2: BundleModel.fromJson round-trip**
    - **Validates: Requirements 5.2, 5.3**

- [x] 2. إضافة endpoint وتحديث PosCubit وPosState
  - إضافة `posBundles` في `endpoints.dart`
  - إضافة `PosBundlesLoaded` في `pos_home_state.dart`
  - إضافة `bundles` list و `getBundles()` في `pos_home_cubit.dart`
  - تعديل `selectTab()` لاستدعاء `getBundles()` عند tab == 'bundles'
  - _Requirements: 1.2, 1.3, 4.1, 4.2, 4.3_

  - [x] 2.1 كتابة property test لـ selectTab('bundles')
    - **Property 1: selectTab('bundles') يُصدر PosBundlesLoaded**
    - **Validates: Requirements 1.2, 1.3**

  - [x] 2.2 كتابة property test لفشل API
    - **Property 5: فشل API لا يوقف التطبيق**
    - **Validates: Requirements 4.3**

- [x] 3. إنشاء BundleCard widget
  - إنشاء `bundle_card.dart` يعرض: أيقونة هدية، شارة خصم، اسم، عدد منتجات، سعر أصلي مشطوب، سعر جديد، Save، زر Add to Cart
  - تلفيف الكارد بـ `AnimatedElement` مع delay متدرج
  - _Requirements: 2.1, 2.2_

  - [x] 3.1 كتابة widget test لـ BundleCard
    - **Property 3: BundleCard تعرض بيانات الباقة كاملة**
    - **Validates: Requirements 2.1, 2.2**

- [x] 4. إنشاء BundleDetailsDialog widget
  - إنشاء `bundle_details_dialog.dart` يعرض: اسم + شارة، أسعار، قائمة المنتجات، زر Cancel + Add to Cart
  - _Requirements: 3.1, 3.2, 3.3_

  - [x] 4.1 كتابة widget test لـ BundleDetailsDialog
    - **Property 4: BundleDetailsDialog يعرض كل المنتجات**
    - **Validates: Requirements 3.2**

- [x] 5. إنشاء POSBundlesGrid وربط كل شيء
  - إنشاء `bundles_grid.dart` بـ GridView يعرض BundleCard لكل باقة، مع رسالة "No bundles available" عند القائمة الفارغة
  - إضافة تبويب "Bundles" في `tab_bar.dart`
  - تحديث `pos_home_screen.dart` لعرض `POSBundlesGrid` عند `PosBundlesLoaded`
  - _Requirements: 1.1, 1.4, 2.3, 3.1_

- [x] 6. Checkpoint - التأكد من عمل الميزة
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- المهام المعلّمة بـ `*` اختيارية ويمكن تخطيها
- الميزة لا تحتاج dependencies جديدة
- يتبع نفس نمط AnimatedElement الموجود في `lib/core/widgets/animation/`
