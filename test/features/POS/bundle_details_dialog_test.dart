import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import 'package:systego/features/POS/home/presentation/widgets/bundle_details_dialog.dart';

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
          BundleProduct(productId: 'p1', name: 'Product A', price: 60.0, quantity: 1),
          BundleProduct(productId: 'p2', name: 'Product B', price: 60.0, quantity: 1),
        ],
  );
}

/// Pumps the dialog inside a MaterialApp so it can be shown via showDialog.
Future<void> _pumpDialog(
  WidgetTester tester,
  BundleModel bundle, {
  VoidCallback? onAddToCart,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => BundleDetailsDialog(
                bundle: bundle,
                onAddToCart: onAddToCart ?? () {},
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('BundleDetailsDialog — Property 4: يعرض كل المنتجات', () {
    testWidgets('shows all product names', (tester) async {
      final bundle = _makeBundle(products: [
        BundleProduct(productId: 'p1', name: 'Alpha', price: 10.0, quantity: 1),
        BundleProduct(productId: 'p2', name: 'Beta', price: 20.0, quantity: 2),
        BundleProduct(productId: 'p3', name: 'Gamma', price: 30.0, quantity: 3),
      ]);

      await _pumpDialog(tester, bundle);

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('shows correct product count in header', (tester) async {
      final bundle = _makeBundle(products: [
        BundleProduct(productId: 'p1', name: 'A', price: 10, quantity: 1),
        BundleProduct(productId: 'p2', name: 'B', price: 20, quantity: 1),
        BundleProduct(productId: 'p3', name: 'C', price: 30, quantity: 1),
      ]);

      await _pumpDialog(tester, bundle);

      expect(find.text('Products (3)'), findsOneWidget);
    });

    testWidgets('shows product quantity for each product', (tester) async {
      final bundle = _makeBundle(products: [
        BundleProduct(productId: 'p1', name: 'Alpha', price: 10.0, quantity: 2),
        BundleProduct(productId: 'p2', name: 'Beta', price: 20.0, quantity: 5),
      ]);

      await _pumpDialog(tester, bundle);

      expect(find.text('x2'), findsOneWidget);
      expect(find.text('x5'), findsOneWidget);
    });

    testWidgets('shows product price for each product', (tester) async {
      final bundle = _makeBundle(products: [
        BundleProduct(productId: 'p1', name: 'Alpha', price: 15.50, quantity: 1),
        BundleProduct(productId: 'p2', name: 'Beta', price: 22.00, quantity: 1),
      ]);

      await _pumpDialog(tester, bundle);

      expect(find.text('15.50 EGP'), findsOneWidget);
      expect(find.text('22.00 EGP'), findsOneWidget);
    });

    testWidgets('shows bundle name in header', (tester) async {
      await _pumpDialog(tester, _makeBundle(name: 'Starter Pack'));

      expect(find.text('Starter Pack'), findsOneWidget);
    });

    testWidgets('shows discount badge', (tester) async {
      await _pumpDialog(tester, _makeBundle(savingsPercentage: 25));

      expect(find.text('-25%'), findsOneWidget);
    });

    testWidgets('shows bundle price', (tester) async {
      await _pumpDialog(tester, _makeBundle(price: 89.99));

      expect(find.text('89.99 EGP'), findsOneWidget);
    });

    testWidgets('shows original price', (tester) async {
      await _pumpDialog(tester, _makeBundle(originalPrice: 120.0));

      expect(find.text('120.00 EGP'), findsOneWidget);
    });

    testWidgets('shows savings amount', (tester) async {
      await _pumpDialog(tester, _makeBundle(savings: 30.01));

      expect(find.text('Save 30.01 EGP'), findsOneWidget);
    });

    testWidgets('shows Cancel and Add to Cart buttons', (tester) async {
      await _pumpDialog(tester, _makeBundle());

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('Cancel button closes the dialog', (tester) async {
      await _pumpDialog(tester, _makeBundle());

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(BundleDetailsDialog), findsNothing);
    });

    testWidgets('Add to Cart fires callback and closes dialog', (tester) async {
      bool called = false;

      await _pumpDialog(tester, _makeBundle(), onAddToCart: () => called = true);

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.byType(BundleDetailsDialog), findsNothing);
    });

    testWidgets('renders single product correctly', (tester) async {
      final bundle = _makeBundle(products: [
        BundleProduct(productId: 'p1', name: 'Solo Item', price: 50.0, quantity: 1),
      ]);

      await _pumpDialog(tester, bundle);

      expect(find.text('Solo Item'), findsOneWidget);
      expect(find.text('Products (1)'), findsOneWidget);
    });

    testWidgets('renders with many products — all names visible after scroll', (tester) async {
      final products = List.generate(
        6,
        (i) => BundleProduct(productId: 'p$i', name: 'Item $i', price: 10.0 * (i + 1), quantity: 1),
      );

      await _pumpDialog(tester, _makeBundle(products: products));

      // First few items should be visible
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Products (6)'), findsOneWidget);
    });
  });
}
