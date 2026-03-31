# Requirements Document

## Introduction

إضافة تبويب "Bundles" في شاشة POS Home يعرض الباقات النشطة المسترجعة من الـ API، مع بطاقات تفاعلية وDialog لعرض التفاصيل وإضافة الباقة للسلة. الميزة تتبع نمط Cubit + BlocBuilder الموجود وتُضاف بأقل تعديل ممكن.

---

## Glossary

- **PosCubit**: الـ Cubit المسؤول عن إدارة حالة شاشة POS Home
- **BundleModel**: نموذج البيانات الذي يمثل باقة منتجات
- **BundleProduct**: نموذج بيانات منتج داخل الباقة
- **POSBundlesGrid**: ويدجت عرض شبكة الباقات
- **BundleCard**: بطاقة عرض الباقة الواحدة
- **BundleDetailsDialog**: نافذة تفاصيل الباقة
- **POSTabBar**: شريط التبويبات في POS Home
- **CheckoutCubit**: الـ Cubit المسؤول عن إدارة السلة

---

## Requirements

### Requirement 1: عرض تبويب Bundles

**User Story:** As a cashier, I want to see a Bundles tab in POS Home, so that I can browse available product bundles.

#### Acceptance Criteria

1. THE POSTabBar SHALL display a "Bundles" tab alongside the existing Featured, Category, and Brand tabs.
2. WHEN a cashier selects the Bundles tab, THE PosCubit SHALL call getBundles() if the bundles list is empty.
3. WHEN getBundles() completes successfully, THE PosCubit SHALL emit PosBundlesLoaded with the retrieved bundles list.
4. WHEN PosBundlesLoaded is emitted, THE PosHomeScreen SHALL display the POSBundlesGrid widget.

---

### Requirement 2: عرض بطاقات الباقات

**User Story:** As a cashier, I want to see bundle cards with key information, so that I can quickly identify bundles.

#### Acceptance Criteria

1. THE BundleCard SHALL display the bundle name, discounted price, original price (strikethrough), savings amount, and discount percentage badge.
2. THE BundleCard SHALL display the number of products included in the bundle.
3. WHEN the bundles list is empty, THE POSBundlesGrid SHALL display a "No bundles available" message.

---

### Requirement 3: تفاصيل الباقة وإضافتها للسلة

**User Story:** As a cashier, I want to view bundle details and add it to the cart, so that I can complete a bundle sale.

#### Acceptance Criteria

1. WHEN a cashier taps a BundleCard, THE PosHomeScreen SHALL show BundleDetailsDialog for that bundle.
2. THE BundleDetailsDialog SHALL display the bundle name, prices, savings, and the full list of included products with their names and quantities.
3. WHEN a cashier taps "Add to Cart" in BundleDetailsDialog, THE CheckoutCubit SHALL receive the bundle as a cart item and the dialog SHALL close.

---

### Requirement 4: تحميل البيانات من API

**User Story:** As a cashier, I want bundles to load from the server, so that I always see up-to-date offers.

#### Acceptance Criteria

1. WHEN getBundles() is called, THE PosCubit SHALL send a GET request to the posBundles endpoint.
2. WHEN the API returns a valid response, THE PosCubit SHALL parse the response into a list of BundleModel objects using BundleModel.fromJson().
3. IF the API call fails, THEN THE PosCubit SHALL log the error and emit PosBundlesLoaded with an empty list without crashing the application.

---

### Requirement 5: نموذج البيانات BundleModel

**User Story:** As a developer, I want a well-defined BundleModel, so that bundle data is consistently represented throughout the feature.

#### Acceptance Criteria

1. THE BundleModel SHALL contain: id, name, images, price, originalPrice, savings, savingsPercentage, startDate, endDate, and products fields.
2. THE BundleModel.fromJson() SHALL correctly map all fields from the API JSON response.
3. FOR ALL valid BundleModel objects, serializing to JSON then parsing back SHALL produce an equivalent object (round-trip property).

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system.*

### Property 1: selectTab('bundles') يُصدر PosBundlesLoaded

*For any* PosCubit instance, calling selectTab('bundles') should always result in emitting a PosBundlesLoaded state containing the bundles list.

**Validates: Requirements 1.2, 1.3**

---

### Property 2: BundleModel.fromJson round-trip

*For any* valid BundleModel object, converting it to JSON then parsing it back with fromJson() should produce an equivalent object with identical field values.

**Validates: Requirements 5.2, 5.3**

---

### Property 3: BundleCard تعرض بيانات الباقة كاملة

*For any* BundleModel, rendering a BundleCard should produce a widget tree that contains the bundle name, discounted price, original price, savings amount, and product count.

**Validates: Requirements 2.1, 2.2**

---

### Property 4: BundleDetailsDialog يعرض كل المنتجات

*For any* BundleModel with N products, the BundleDetailsDialog should display exactly N product entries, each showing the product name and quantity.

**Validates: Requirements 3.2**

---

### Property 5: فشل API لا يوقف التطبيق

*For any* network error during getBundles(), the PosCubit should emit PosBundlesLoaded with an empty list rather than throwing an unhandled exception.

**Validates: Requirements 4.3**
