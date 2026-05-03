import 'package:flutter_test/flutter_test.dart';
import 'package:GoSystem/features/pos/return/models/return_sale_model.dart';
import 'package:GoSystem/features/pos/return/models/return_item_model.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Map<String, dynamic> _fullSaleJson({String? customerName}) => {
      'sale': {
        '_id': 'sale123',
        'reference': 'REF-001',
        'date': '2024-01-15',
        'customer': customerName != null ? {'name': customerName} : null,
        'warehouse': {'name': 'Main Warehouse'},
        'created_by': {'email': 'cashier@test.com'},
        'shift': {
          'cashier': {'name': 'John Doe'},
          'cashierman': {'username': 'manager1'},
        },
      },
      'items': [
        {
          '_id': 'item1',
          'sale_id': 'sale123',
          'product': {'_id': 'prod1', 'name': 'Product A', 'code': 'PA001'},
          'product_price': {'_id': 'pp1'},
          'quantity': 5,
          'already_returned': 1,
          'available_to_return': 4,
        },
      ],
    };

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 10.1 Unit test: ReturnSaleModel.fromJson returns correct fields from full JSON
  group('ReturnSaleModel.fromJson', () {
    test('parses all fields correctly from full JSON', () {
      final model = ReturnSaleModel.fromJson(_fullSaleJson(customerName: 'Alice'));

      expect(model.id, 'sale123');
      expect(model.reference, 'REF-001');
      expect(model.date, '2024-01-15');
      expect(model.customerName, 'Alice');
      expect(model.warehouseName, 'Main Warehouse');
      expect(model.cashierEmail, 'cashier@test.com');
      expect(model.cashierName, 'John Doe');
      expect(model.cashierManName, 'manager1');
      expect(model.items, hasLength(1));
      expect(model.items.first.id, 'item1');
    });

    test('handles missing nested fields gracefully', () {
      final json = {
        'sale': {'_id': 'x', 'reference': 'R1', 'date': '2024-01-01'},
        'items': <dynamic>[],
      };
      final model = ReturnSaleModel.fromJson(json);
      expect(model.id, 'x');
      expect(model.warehouseName, '');
      expect(model.cashierEmail, '');
      expect(model.items, isEmpty);
    });

    // 10.3 displayCustomerName returns 'Walk-in Customer' when customer is null
    test('displayCustomerName returns Walk-in Customer when customer is null', () {
      final model = ReturnSaleModel.fromJson(_fullSaleJson(customerName: null));
      expect(model.customerName, isNull);
      expect(model.displayCustomerName, 'Walk-in Customer');
    });

    test('displayCustomerName returns actual name when customer is set', () {
      final model = ReturnSaleModel.fromJson(_fullSaleJson(customerName: 'Bob'));
      expect(model.displayCustomerName, 'Bob');
    });

    // 10.9 [PBT] Property 8: any valid JSON parses without exception and has non-null core fields
    test('[PBT] Property 8: parsing valid JSON never throws and core fields are non-null', () {
      final variants = [
        _fullSaleJson(customerName: 'Alice'),
        _fullSaleJson(customerName: null),
        {'sale': {'_id': 'a', 'reference': 'R', 'date': 'd'}, 'items': <dynamic>[]},
        {'_id': 'b', 'reference': 'R2', 'date': 'd2', 'items': <dynamic>[]},
      ];

      for (final json in variants) {
        expect(() => ReturnSaleModel.fromJson(json), returnsNormally);
        final model = ReturnSaleModel.fromJson(json);
        expect(model.id, isNotNull);
        expect(model.reference, isNotNull);
        expect(model.date, isNotNull);
        expect(model.items, isNotNull);
      }
    });
  });

  // Note: productPriceId tests removed after migration 014
  // Products no longer have separate price IDs - they reference product directly
  group('ReturnItemModel.fromJson', () {
    test('parses product information correctly', () {
      final json = {
        '_id': 'item1',
        'sale_id': 'sale1',
        'product': {'_id': 'prod_id', 'name': 'Widget', 'code': 'W001'},
        'quantity': 3,
        'already_returned': 0,
        'available_to_return': 3,
      };

      final item = ReturnItemModel.fromJson(json);
      expect(item.id, 'item1');
      expect(item.productName, 'Widget');
      expect(item.productCode, 'W001');
    });

    test('returnQuantity defaults to 0', () {
      final json = {
        '_id': 'item3',
        'sale_id': 'sale1',
        'product': {'_id': 'p1', 'name': 'X', 'code': 'X1'},
        'quantity': 5,
        'already_returned': 1,
        'available_to_return': 4,
      };

      final item = ReturnItemModel.fromJson(json);
      expect(item.returnQuantity, 0);
    });
  });
}
