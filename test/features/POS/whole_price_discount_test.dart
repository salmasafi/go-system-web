import 'package:flutter_test/flutter_test.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';

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
}) {
  return CartItem(product: product, quantity: quantity);
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

  // Note: PriceVariation tests removed after migration 014
  // Products now have single price only - no price variations
  group('WholePriceDiscount — Edge Cases', () {
    test('wholePrice with zero startQuantity is never active', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 80, startQuantity: 0),
        quantity: 10,
      );
      // startQuantity of 0 means wholesale never activates
      expect(item.isWholePriceActive, isFalse);
      expect(item.effectivePrice, equals(100.0));
    });

    test('large quantity still uses wholePrice when conditions met', () {
      final item = _makeItem(
        product: _makeProduct(price: 100, wholePrice: 75, startQuantity: 5),
        quantity: 1000,
      );
      expect(item.isWholePriceActive, isTrue);
      expect(item.effectivePrice, equals(75.0));
      expect(item.subtotal, equals(75.0 * 1000));
    });
  });
}
