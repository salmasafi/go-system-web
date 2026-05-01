import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/pos/home/presentation/widgets/bundle_card.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

BundleModel _makeBundle({
  String id = 'bundle-1',
  String name = 'Starter Pack',
  double price = 89.99,
  double originalPrice = 120.0,
  double savings = 30.01,
  int savingsPercentage = 25,
  List<BundleProduct>? products,
}) {
  return BundleModel(
    id: id,
    name: name,
    images: [],
    price: price,
    originalPrice: originalPrice,
    savings: savings,
    savingsPercentage: savingsPercentage,
    startDate: '2026-01-01',
    endDate: '2026-12-31',
    products: products ??
        [
          BundleProduct(
            productId: 'p1',
            name: 'Product A',
            price: 60.0,
            quantity: 1,
          ),
          BundleProduct(
            productId: 'p2',
            name: 'Product B',
            price: 60.0,
            quantity: 1,
          ),
        ],
  );
}

/// Wraps [widget] in a minimal MaterialApp so MediaQuery and Theme are available.
Widget _wrap(Widget widget) => MaterialApp(home: Scaffold(body: widget));

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('BundleCard — Property 3: تعرض بيانات الباقة كاملة', () {
    testWidgets('shows bundle name', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(name: 'Starter Pack'),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Starter Pack'), findsOneWidget);
    });

    testWidgets('shows discount badge with correct percentage', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(savingsPercentage: 25),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('-25%'), findsOneWidget);
    });

    testWidgets('shows product count', (tester) async {
      final bundle = _makeBundle(products: [
        BundleProduct(productId: 'p1', name: 'A', price: 10, quantity: 1),
        BundleProduct(productId: 'p2', name: 'B', price: 20, quantity: 1),
        BundleProduct(productId: 'p3', name: 'C', price: 30, quantity: 1),
      ]);

      await tester.pumpWidget(_wrap(
        BundleCard(bundle: bundle, index: 0, onTap: () {}, onAddToCart: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('3 Items'), findsOneWidget);
    });

    testWidgets('shows original price with strikethrough', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(originalPrice: 120.0),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('120.00 EGP'), findsOneWidget);
    });

    testWidgets('shows bundle price', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(price: 89.99),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('89.99 EGP'), findsOneWidget);
    });

    testWidgets('shows savings amount', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(savings: 30.01),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Save 30.01 EGP'), findsOneWidget);
    });

    testWidgets('shows gift icon', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.redeem), findsOneWidget);
    });

    testWidgets('shows Add to Cart button', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('onAddToCart callback fires when button tapped', (tester) async {
      bool called = false;

      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(),
          index: 0,
          onTap: () {},
          onAddToCart: () => called = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Cart'));
      expect(called, isTrue);
    });

    testWidgets('onTap callback fires when card tapped', (tester) async {
      bool called = false;

      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(),
          index: 0,
          onTap: () => called = true,
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      expect(called, isTrue);
    });

    testWidgets('renders correctly with single product', (tester) async {
      final bundle = _makeBundle(products: [
        BundleProduct(productId: 'p1', name: 'Solo', price: 50, quantity: 1),
      ]);

      await tester.pumpWidget(_wrap(
        BundleCard(bundle: bundle, index: 0, onTap: () {}, onAddToCart: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('1 Items'), findsOneWidget);
    });

    testWidgets('renders correctly with zero savings percentage', (tester) async {
      await tester.pumpWidget(_wrap(
        BundleCard(
          bundle: _makeBundle(savingsPercentage: 0),
          index: 0,
          onTap: () {},
          onAddToCart: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('-0%'), findsOneWidget);
    });
  });
}
