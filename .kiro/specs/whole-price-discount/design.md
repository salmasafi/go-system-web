# Design Document — Whole Price Discount

## Overview

تضيف هذه الميزة منطق **سعر الجملة** إلى نظام POS. عند وصول كمية منتج في العربة إلى `start_quantity`، يُطبَّق `whole_price` تلقائياً بدلاً من `price` العادي، مع عرض بصري واضح في `CartItemTile` وإرسال السعر الصحيح عند إنشاء البيع.

---

## Architecture

لا تتطلب الميزة طبقات جديدة. التغييرات موزعة على الطبقات الموجودة:

```
Data Layer      → pos_models.dart (PriceVariation, Product)
                → online_order_model.dart (OnlineOrderItem)
Domain Layer    → checkout_models.dart (CartItem.effectivePrice)
State Layer     → checkout_cubit.dart (createSale payload)
UI Layer        → cart_item_tile.dart
                → online_order_card.dart
```

---

## Component Design

### 1. PriceVariation (pos_models.dart)

إضافة حقلين nullable:

```dart
class PriceVariation {
  // ... الحقول الحالية ...
  final double? wholePrice;    // من whole_price في JSON
  final int?    startQuantity; // من start_quantity في JSON
}
```

في `fromJson`:
```dart
wholePrice:    (json['whole_price'] as num?)?.toDouble(),
startQuantity: (json['start_quantity'] as num?)?.toInt(),
```

---

### 2. Product (pos_models.dart)

نفس الإضافة للمنتجات البسيطة (بدون `differentPrice`):

```dart
class Product {
  // ... الحقول الحالية ...
  final double? wholePrice;
  final int?    startQuantity;
}
```

في `fromList` و `fromScan`:
```dart
wholePrice:    (json['whole_price'] as num?)?.toDouble(),
startQuantity: (json['start_quantity'] as num?)?.toInt(),
```

---

### 3. CartItem — منطق effectivePrice (checkout_models.dart)

تحديث getter الحالي ليأخذ `quantity` بعين الاعتبار:

```dart
// السعر الأساسي (من variation أو product)
double get basePrice => selectedVariation?.price ?? product.price;

// سعر الجملة (من variation أو product)
double? get wholePrice => selectedVariation?.wholePrice ?? product.wholePrice;

// الحد الأدنى للكمية
int? get startQuantity => selectedVariation?.startQuantity ?? product.startQuantity;

// هل خصم الجملة مفعّل؟
bool get isWholePriceActive =>
    wholePrice != null &&
    startQuantity != null &&
    quantity >= startQuantity!;

// السعر الفعلي
double get effectivePrice => isWholePriceActive ? wholePrice! : basePrice;

// Subtotal
double get subtotal => effectivePrice * quantity;
```

> لا حاجة لـ `WholePriceCalculator` منفصل — المنطق بسيط ويناسب getter مباشر في `CartItem`.

---

### 4. CheckoutCubit — createSale (checkout_cubit.dart)

تحديث بناء `productsList` ليستخدم `effectivePrice` و `subtotal`:

```dart
final productsList = cartItems.map((item) {
  return {
    "product_id": item.product.id,
    if (item.selectedVariation != null)
      "product_price_id": item.selectedVariation!.id,
    "quantity":  item.quantity,
    "price":     item.effectivePrice,          // ← بدلاً من price الثابت
    "subtotal":  item.subtotal,
    if (item.isWholePriceActive)
      "whole_price": item.wholePrice,          // ← إبلاغ الـ backend
  };
}).toList();
```

> `updateQuantity` لا يحتاج تعديلاً — `effectivePrice` يُحسب تلقائياً عند كل emit لأنه getter.

---

### 5. CartItemTile — عرض السعر (cart_item_tile.dart)

منطق العرض:

```
isWholePriceActive == true  →  سعر الجملة (أخضر) + السعر الأصلي (مشطوب رمادي)
isWholePriceActive == false →  السعر العادي (primaryBlue) فقط
```

```dart
Widget _buildPriceDisplay(CartItem item) {
  if (item.isWholePriceActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          item.wholePrice!.toStringAsFixed(2),
          style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold),
        ),
        Text(
          item.basePrice.toStringAsFixed(2),
          style: TextStyle(
            color: AppColors.linkBlue,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }
  return Text(
    item.basePrice.toStringAsFixed(2),
    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
  );
}
```

---

### 6. OnlineOrderModel — إضافة items (online_order_model.dart)

`OnlineOrderModel` حالياً يحتوي فقط على `amount` الإجمالي. لعرض خصم الجملة، نضيف `OnlineOrderItem`:

```dart
class OnlineOrderItem {
  final String productId;
  final String productName;
  final double price;
  final double? wholePrice;
  final int? startQuantity;
  final int quantity;

  double get effectivePrice =>
      (wholePrice != null && startQuantity != null && quantity >= startQuantity!)
          ? wholePrice!
          : price;

  double get subtotal => effectivePrice * quantity;

  factory OnlineOrderItem.fromJson(Map<String, dynamic> json) { ... }
}
```

ونضيف `List<OnlineOrderItem> items` إلى `OnlineOrderModel`.

---

### 7. OnlineOrderCard — عرض المبلغ

`OnlineOrderCard` يعرض `order.amount` الإجمالي القادم من الـ backend مباشرة — لا تغيير مطلوب على مستوى المبلغ الكلي.

لعرض تفاصيل الخصم لكل منتج (اختياري حسب الـ UI)، يمكن استخدام `order.items` إذا كانت متاحة في الـ API response.

---

## Data Flow

```
API Response
    ↓
PriceVariation.fromJson / Product.fromList
    ↓  (whole_price, start_quantity parsed)
CartItem added to cart
    ↓
User increments quantity
    ↓
CheckoutCubit.updateQuantity → emit(PosCartUpdated)
    ↓
CartItemTile rebuilds → CartItem.isWholePriceActive recalculated
    ↓
UI shows green whole_price + strikethrough original price
    ↓
CheckoutCubit.createSale → sends effectivePrice + whole_price in payload
```

---

## Edge Cases

| الحالة | السلوك |
|--------|--------|
| `wholePrice == null` | يُعرض السعر العادي، لا خصم |
| `startQuantity == null` | يُعرض السعر العادي، لا خصم |
| `quantity < startQuantity` | يُعرض السعر العادي |
| `quantity == startQuantity` | يُفعَّل سعر الجملة (حد أدنى شامل) |
| منتج بـ `differentPrice` | يُقرأ `wholePrice` من `selectedVariation` |
| منتج بدون `differentPrice` | يُقرأ `wholePrice` من `product` مباشرة |
