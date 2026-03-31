# Implementation Tasks — Whole Price Discount

## Task 1: تحديث PriceVariation بحقلي wholePrice و startQuantity

**File:** `lib/features/POS/home/model/pos_models.dart`

- [x] أضف `final double? wholePrice;` و `final int? startQuantity;` إلى class `PriceVariation`
- [x] حدّث constructor ليقبل الحقلين الجديدين
- [x] في `PriceVariation.fromJson`، أضف:
  - `wholePrice: (json['whole_price'] as num?)?.toDouble()`
  - `startQuantity: (json['start_quantity'] as num?)?.toInt()`

**Requirements:** R1

---

## Task 2: تحديث Product بحقلي wholePrice و startQuantity

**File:** `lib/features/POS/home/model/pos_models.dart`

- [x] أضف `final double? wholePrice;` و `final int? startQuantity;` إلى class `Product`
- [x] حدّث constructor ليقبل الحقلين الجديدين (nullable, default null)
- [x] في `Product.fromList`، أضف parsing للحقلين من JSON
- [x] في `Product.fromScan`، أضف نفس الـ parsing

**Requirements:** R2

---

## Task 3: تحديث CartItem بمنطق سعر الجملة

**File:** `lib/features/POS/checkout/model/checkout_models.dart`

- [x] أضف getter `basePrice` يرجع `selectedVariation?.price ?? product.price`
- [x] أضف getter `wholePrice` يرجع `selectedVariation?.wholePrice ?? product.wholePrice`
- [x] أضف getter `startQuantity` يرجع `selectedVariation?.startQuantity ?? product.startQuantity`
- [x] أضف getter `isWholePriceActive` يرجع `true` عندما `wholePrice != null && startQuantity != null && quantity >= startQuantity!`
- [x] حدّث getter `effectivePrice` ليرجع `isWholePriceActive ? wholePrice! : basePrice`
- [x] تأكد أن `subtotal` لا يزال `effectivePrice * quantity` (لا تغيير مطلوب)

**Requirements:** R3

---

## Task 4: تحديث createSale في CheckoutCubit

**File:** `lib/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart`

- [x] في `productsList` داخل `createSale`، استبدل:
  - `"price": item.selectedVariation?.price ?? item.product.price` → `"price": item.effectivePrice`
  - `"subtotal": item.subtotal` (لا تغيير، لكن تأكد أنه يستخدم getter المحدّث)
- [x] أضف `if (item.isWholePriceActive) "whole_price": item.wholePrice` إلى كل عنصر في القائمة

**Requirements:** R6

---

## Task 5: تحديث CartItemTile لعرض سعر الجملة

**File:** `lib/features/POS/checkout/presentation/widgets/cart_item_tile.dart`

- [x] أضف method خاصة `_buildPriceDisplay(BuildContext context)` تُرجع Widget
- [x] عندما `item.isWholePriceActive`:
  - اعرض `item.wholePrice!` بلون `AppColors.successGreen` وخط عريض
  - اعرض `item.basePrice` بلون `AppColors.linkBlue` مع `TextDecoration.lineThrough`
- [x] عندما `!item.isWholePriceActive`:
  - اعرض `item.basePrice` بلون `AppColors.primaryBlue` فقط
- [x] استبدل عرض السعر الحالي في الـ widget بـ `_buildPriceDisplay(context)`

**Requirements:** R4

---

## Task 6: تحديث OnlineOrderModel بإضافة OnlineOrderItem

**File:** `lib/features/POS/online_orders/model/online_order_model.dart`

- [x] أنشئ class `OnlineOrderItem` بالحقول:
  - `productId`, `productName`, `price`, `wholePrice?`, `startQuantity?`, `quantity`
  - getter `effectivePrice` بنفس منطق CartItem
  - getter `subtotal`
  - factory `OnlineOrderItem.fromJson`
- [x] أضف `final List<OnlineOrderItem> items;` إلى `OnlineOrderModel`
- [x] في `OnlineOrderModel.fromJson`، parse قائمة `products` أو `items` من JSON إذا كانت موجودة (وإلا قائمة فارغة)

**Requirements:** R5

---

## Task 7: تحديث OnlineOrderCard لعرض خصم الجملة

**File:** `lib/features/POS/online_orders/presentation/widgets/online_order_card.dart`

- [x] المبلغ الإجمالي `order.amount` يبقى كما هو (يأتي من الـ backend)
- [x] إذا كانت `order.items` غير فارغة، أضف قسم تفاصيل المنتجات يعرض لكل item:
  - اسم المنتج، الكمية، والسعر الفعلي
  - إذا `item.isWholePriceActive`: اعرض `wholePrice` بالأخضر + `price` مشطوب
  - إذا لا: اعرض `price` العادي

**Requirements:** R5

---

## Task 8: كتابة Unit Tests لمنطق الحساب

**File:** `test/features/pos/whole_price_discount_test.dart`

- [x] اكتب test: `effectivePrice == wholePrice` عندما `quantity >= startQuantity`
- [x] اكتب test: `effectivePrice == price` عندما `quantity < startQuantity`
- [x] اكتب test: `effectivePrice == price` عندما `wholePrice == null`
- [x] اكتب test: `effectivePrice == price` عندما `startQuantity == null`
- [x] اكتب test: `subtotal == effectivePrice * quantity` في كلا الحالتين
- [x] اكتب test: الحد الحرج `quantity == startQuantity` يُفعّل `wholePrice`

**Requirements:** R7
