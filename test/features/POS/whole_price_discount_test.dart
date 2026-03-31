import 'package:flutter_test/flutter_test.dart';
import 'package:systego/features/POS/checkout/model/checkout_models.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';

// Helper: بناء Product بسيط مع دعم wholePrice/startQuantity
Product _makeProduct({
  double price = 100.0,
  double? wholePrice,
  int? startQuantity,
}) {
  return Product(
    id: 'p1',
    name: 'Test Product',
    code: 'TP001',
    description: '',
    price: price,
    wholePrice: wholePrice,
    startQuantity: startQuantity,
  );
}

// Helper: بناء CartItem
CartItem _makeItem({
  required Product product,
  int quantity = 1,
  PriceVariation? variation,
}) {
  return CartItem(product: product, selectedVariation: variation, quantity: quantity);
}

void main() {
  group('WholePriceDiscount — CartItem logic', () {
    test('effectivePrice == wholePrice when quantity >= startQuantity', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 80, startQuantity: 5),
        quantity: 5,
      );
      expect(item.effectivePrice, equals(80.0));
    });

    test('effectivePrice == price when quantity < startQuantity', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 80, startQuantity: 5),
        quantity: 4,
      );
      expect(item.effectivePrice, equals(100.0));
    });

    test('effectivePrice == price when wholePrice is null', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: null, startQuantity: 5),
        quantity: 10,
      );
      expect(item.effectivePrice, equals(100.0));
    });

    test('effectivePrice == price when startQuantity is null', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 80, startQuantity: null),
        quantity: 10,
      );
      expect(item.effectivePrice, equals(100.0));
    });

    test('boundary: quantity == startQuantity activates wholePrice', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 75, startQuantity: 3),
        quantity: 3,
      );
      expect(item.isWholePriceActive, isTrue);
      expect(item.effectivePrice, equals(75.0));
    });

    test('subtotal == effectivePrice * quantity (wholesale active)', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 80, startQuantity: 5),
        quantity: 6,
      );
      expect(item.subtotal, equals(80.0 * 6));
    });

    test('subtotal == effectivePrice * quantity (no discount)', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 80, startQuantity: 5),
        quantity: 3,
      );
      expect(item.subtotal, equals(100.0 * 3));
    });
  });

  group('WholePriceDiscount — PriceVariation overrides Product', () {
    test('uses variation wholePrice when variation has it', () {
      final variation = PriceVariation(
        id: 'v1',
        productId: 'p1',
        price: 90,
        code: 'V001',
        gallery: [],
        quantity: 10,
        variations: [],
        wholePrice: 70,
        startQuantity: 4,
      );
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 80, startQuantity: 5),
        variation: variation,
        quantity: 4,
      );
      // يجب أن يستخدم variation.wholePrice وليس product.wholePrice
      expect(item.effectivePrice, equals(70.0));
    });

    test('falls back to product price when variation has no wholePrice', () {
      final variation = PriceVariation(
        id: 'v1',
        productId: 'p1',
        price: 90,
        code: 'V001',
        gallery: [],
        quantity: 10,
        variations: [],
        wholePrice: null,
        startQuantity: null,
      );
      final item = _makeItem(
        product: _makeProduct(price: 100),
        variation: variation,
        quantity: 10,
      );
      expect(item.effectivePrice, equals(90.0)); // variation.price
    });
  });
}
