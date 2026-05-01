import 'package:flutter_test/flutter_test.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

Map<String, dynamic> _bundleProductJson({
  String productId = 'prod-1',
  String name = 'Widget A',
  String? image = 'https://example.com/img.png',
  double price = 49.99,
  int quantity = 2,
}) =>
    {
      'productId': productId,
      'quantity': quantity,
      'product': {
        'name': name,
        'image': image,
        'price': price,
      },
    };

Map<String, dynamic> _bundleJson({
  String id = 'bundle-1',
  String name = 'Starter Pack',
  List<String> images = const ['img1.png', 'img2.png'],
  double price = 89.99,
  double originalPrice = 120.0,
  double savings = 30.01,
  int savingsPercentage = 25,
  String startDate = '2026-01-01',
  String endDate = '2026-12-31',
  List<Map<String, dynamic>>? products,
}) =>
    {
      '_id': id,
      'name': name,
      'images': images,
      'price': price,
      'originalPrice': originalPrice,
      'savings': savings,
      'savingsPercentage': savingsPercentage,
      'startdate': startDate,
      'enddate': endDate,
      'products': products ?? [_bundleProductJson()],
    };

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('BundleModel.fromJson — round-trip', () {
    test('parses all scalar fields correctly', () {
      final json = _bundleJson();
      final model = BundleModel.fromJson(json);

      expect(model.id, equals('bundle-1'));
      expect(model.name, equals('Starter Pack'));
      expect(model.price, equals(89.99));
      expect(model.originalPrice, equals(120.0));
      expect(model.savings, equals(30.01));
      expect(model.savingsPercentage, equals(25));
      expect(model.startDate, equals('2026-01-01'));
      expect(model.endDate, equals('2026-12-31'));
    });

    test('parses images list correctly', () {
      final model = BundleModel.fromJson(_bundleJson(images: ['a.png', 'b.png']));
      expect(model.images, equals(['a.png', 'b.png']));
    });

    test('parses nested BundleProduct list', () {
      final json = _bundleJson(products: [
        _bundleProductJson(productId: 'p1', name: 'Alpha', price: 10.0, quantity: 3),
        _bundleProductJson(productId: 'p2', name: 'Beta', price: 20.0, quantity: 1),
      ]);
      final model = BundleModel.fromJson(json);

      expect(model.products.length, equals(2));

      expect(model.products[0].productId, equals('p1'));
      expect(model.products[0].name, equals('Alpha'));
      expect(model.products[0].price, equals(10.0));
      expect(model.products[0].quantity, equals(3));

      expect(model.products[1].productId, equals('p2'));
      expect(model.products[1].name, equals('Beta'));
      expect(model.products[1].price, equals(20.0));
      expect(model.products[1].quantity, equals(1));
    });

    test('BundleProduct.image is nullable — present', () {
      final json = _bundleJson(
        products: [_bundleProductJson(image: 'https://example.com/img.png')],
      );
      final product = BundleModel.fromJson(json).products.first;
      expect(product.image, equals('https://example.com/img.png'));
    });

    test('BundleProduct.image is nullable — absent (null)', () {
      final json = _bundleJson(
        products: [_bundleProductJson(image: null)],
      );
      final product = BundleModel.fromJson(json).products.first;
      expect(product.image, isNull);
    });

    // ─── Defensive / missing-field cases ────────────────────────────────────

    test('falls back to empty string when _id is missing', () {
      final json = _bundleJson()..remove('_id');
      expect(BundleModel.fromJson(json).id, equals(''));
    });

    test('falls back to 0.0 when price is missing', () {
      final json = _bundleJson()..remove('price');
      expect(BundleModel.fromJson(json).price, equals(0.0));
    });

    test('falls back to 0 when savingsPercentage is missing', () {
      final json = _bundleJson()..remove('savingsPercentage');
      expect(BundleModel.fromJson(json).savingsPercentage, equals(0));
    });

    test('falls back to empty list when products key is missing', () {
      final json = _bundleJson()..remove('products');
      expect(BundleModel.fromJson(json).products, isEmpty);
    });

    test('falls back to empty list when images key is missing', () {
      final json = _bundleJson()..remove('images');
      expect(BundleModel.fromJson(json).images, isEmpty);
    });

    // ─── Numeric type coercion ───────────────────────────────────────────────

    test('accepts int price and coerces to double', () {
      final json = _bundleJson()..['price'] = 100; // int, not double
      expect(BundleModel.fromJson(json).price, equals(100.0));
    });

    test('accepts int savingsPercentage', () {
      final json = _bundleJson()..['savingsPercentage'] = 30;
      expect(BundleModel.fromJson(json).savingsPercentage, equals(30));
    });

    // ─── Property: round-trip identity ──────────────────────────────────────

    test('round-trip: parsing same JSON twice yields identical values', () {
      final json = _bundleJson();
      final a = BundleModel.fromJson(json);
      final b = BundleModel.fromJson(json);

      expect(a.id, equals(b.id));
      expect(a.name, equals(b.name));
      expect(a.price, equals(b.price));
      expect(a.originalPrice, equals(b.originalPrice));
      expect(a.savings, equals(b.savings));
      expect(a.savingsPercentage, equals(b.savingsPercentage));
      expect(a.startDate, equals(b.startDate));
      expect(a.endDate, equals(b.endDate));
      expect(a.images, equals(b.images));
      expect(a.products.length, equals(b.products.length));
    });

    test('round-trip: multiple bundles parsed independently', () {
      final jsons = [
        _bundleJson(id: 'b1', name: 'Pack A', price: 50.0),
        _bundleJson(id: 'b2', name: 'Pack B', price: 75.0),
        _bundleJson(id: 'b3', name: 'Pack C', price: 99.0),
      ];

      final models = jsons.map(BundleModel.fromJson).toList();

      expect(models[0].id, equals('b1'));
      expect(models[1].id, equals('b2'));
      expect(models[2].id, equals('b3'));
      expect(models.map((m) => m.price).toList(), equals([50.0, 75.0, 99.0]));
    });
  });
}
