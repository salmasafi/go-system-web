# Requirements Document

## Introduction

خاصية **Whole Price Discount** تتيح تطبيق سعر الجملة تلقائياً في نظام POS عند وصول كمية المنتج في العربة إلى حد معين (`start_quantity`). عند تحقق الشرط، يُستبدل سعر القطعة من `price` إلى `whole_price`، ويُعرض الفرق بصرياً في واجهة العربة وعرض الطلبات.

## Glossary

- **POS_Cart**: عربة التسوق في شاشة POS الرئيسية
- **CartItem**: عنصر واحد داخل POS_Cart يحتوي على منتج وكميته وسعره الفعلي
- **PriceVariation**: نموذج بيانات تنويعة السعر للمنتج (`PriceVariation` في `pos_models.dart`)
- **whole_price**: سعر الجملة للقطعة الواحدة، يُطبَّق عند بلوغ `start_quantity`
- **start_quantity**: الحد الأدنى للكمية الذي يُفعِّل سعر الجملة
- **effective_price**: السعر الفعلي المُطبَّق على CartItem (إما `price` أو `whole_price`)
- **WholePriceCalculator**: المنطق المسؤول عن تحديد `effective_price` بناءً على الكمية
- **CartItemTile**: ويدجت عرض عنصر العربة في شاشة POS (`cart_item_tile.dart`)
- **OnlineOrderCard**: ويدجت عرض بطاقة الطلب في شاشة الطلبات الإلكترونية (`online_order_card.dart`)
- **CheckoutCubit**: الـ Cubit المسؤول عن إدارة حالة العربة والدفع

## Requirements

---

### Requirement 1: تحديث نموذج بيانات PriceVariation

**User Story:** As a developer, I want `PriceVariation` to carry `whole_price` and `start_quantity` fields from the API, so that the discount logic can access them.

#### Acceptance Criteria

1. THE `PriceVariation` SHALL contain a nullable field `wholePrice` of type `double?` mapped from `whole_price` in the API JSON.
2. THE `PriceVariation` SHALL contain a nullable field `startQuantity` of type `int?` mapped from `start_quantity` in the API JSON.
3. WHEN `whole_price` is absent or null in the JSON, THE `PriceVariation` SHALL set `wholePrice` to `null`.
4. WHEN `start_quantity` is absent or null in the JSON, THE `PriceVariation` SHALL set `startQuantity` to `null`.

---

### Requirement 2: تحديث نموذج بيانات Product

**User Story:** As a developer, I want `Product` (المنتجات بدون `differentPrice`) to also carry `whole_price` and `start_quantity`, so that simple products support the discount too.

#### Acceptance Criteria

1. THE `Product` SHALL contain a nullable field `wholePrice` of type `double?` mapped from `whole_price` in the API JSON.
2. THE `Product` SHALL contain a nullable field `startQuantity` of type `int?` mapped from `start_quantity` in the API JSON.
3. WHEN `whole_price` is absent or null in the JSON, THE `Product` SHALL set `wholePrice` to `null`.
4. WHEN `start_quantity` is absent or null in the JSON, THE `Product` SHALL set `startQuantity` to `null`.

---

### Requirement 3: منطق حساب السعر الفعلي (WholePriceCalculator)

**User Story:** As a cashier, I want the system to automatically apply the wholesale price when the quantity reaches the threshold, so that I don't have to calculate discounts manually.

#### Acceptance Criteria

1. WHEN `quantity >= startQuantity` AND `wholePrice != null` AND `startQuantity != null`, THE `WholePriceCalculator` SHALL return `wholePrice` as the `effective_price`.
2. WHEN `quantity < startQuantity` OR `wholePrice == null` OR `startQuantity == null`, THE `WholePriceCalculator` SHALL return the original `price` as the `effective_price`.
3. THE `CartItem.effectivePrice` SHALL use `WholePriceCalculator` logic based on the current `quantity`, `wholePrice`, and `startQuantity` of the item.
4. THE `CartItem.subtotal` SHALL equal `effectivePrice * quantity`.
5. WHEN `quantity` changes in the cart, THE `CheckoutCubit` SHALL re-evaluate `effectivePrice` for the affected `CartItem` and emit `PosCartUpdated`.

---

### Requirement 4: عرض سعر الجملة في CartItemTile (POS Cart)

**User Story:** As a cashier, I want to see the wholesale price highlighted in green with the original price struck through, so that I can confirm the discount is applied.

#### Acceptance Criteria

1. WHEN `effective_price == wholePrice` (خصم مُفعَّل), THE `CartItemTile` SHALL display `wholePrice` formatted as currency in green color (`AppColors.successGreen`).
2. WHEN `effective_price == wholePrice`, THE `CartItemTile` SHALL display the original `price` with a strikethrough decoration in gray color.
3. WHEN `effective_price == price` (لا خصم), THE `CartItemTile` SHALL display only `price` in the default blue color (`AppColors.primaryBlue`) without strikethrough.
4. THE `CartItemTile` SHALL display the subtotal as `effectivePrice * quantity`.
5. WHEN `quantity` increases to reach `startQuantity`, THE `CartItemTile` SHALL update the price display reactively without requiring a page reload.

---

### Requirement 5: عرض سعر الجملة في OnlineOrderCard

**User Story:** As a store manager, I want online order cards to reflect wholesale pricing when applicable, so that order totals are accurate.

#### Acceptance Criteria

1. WHEN an online order item has `whole_price` applied (i.e., `quantity >= start_quantity`), THE `OnlineOrderCard` SHALL display the discounted total amount using `whole_price * quantity`.
2. THE `OnlineOrderModel` SHALL parse `whole_price` and `start_quantity` per order item from the API response when available.
3. IF `whole_price` or `start_quantity` is absent in the order item data, THEN THE `OnlineOrderCard` SHALL display the original `price` without modification.

---

### Requirement 6: إرسال السعر الصحيح عند إنشاء البيع

**User Story:** As a developer, I want the sale creation payload to use `effective_price` (which may be `whole_price`), so that the backend records the correct discounted price.

#### Acceptance Criteria

1. WHEN `CheckoutCubit.createSale` builds the products list, THE `CheckoutCubit` SHALL use `item.effectivePrice` (not `item.product.price`) as the `price` field per item.
2. THE `CheckoutCubit` SHALL use `item.subtotal` (= `effectivePrice * quantity`) as the `subtotal` field per item.
3. WHEN `wholePrice` is applied, THE `CheckoutCubit` SHALL include `"whole_price": item.wholePrice` in the product payload to inform the backend.

---

### Requirement 7: اختبارات الوحدة لمنطق الحساب

**User Story:** As a developer, I want unit tests for the wholesale price logic, so that regressions are caught early.

#### Acceptance Criteria

1. THE test suite SHALL verify that `effectivePrice == wholePrice` when `quantity >= startQuantity`.
2. THE test suite SHALL verify that `effectivePrice == price` when `quantity < startQuantity`.
3. THE test suite SHALL verify that `effectivePrice == price` when `wholePrice == null`.
4. THE test suite SHALL verify that `subtotal == effectivePrice * quantity` for both price modes.
5. THE test suite SHALL verify the boundary condition: `quantity == startQuantity` activates `wholePrice`.
