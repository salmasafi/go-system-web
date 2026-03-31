import 'package:flutter_test/flutter_test.dart';
import 'package:systego/features/POS/customer/model/pos_customer_model.dart';

void main() {
  // ── 12.1 fromJson maps all fields correctly ──────────────────────────────
  group('PosCustomer.fromJson', () {
    final json = {
      '_id': 'abc123',
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone_number': '+1234567890',
      'address': '123 Main St',
      'country': 'US',
      'city': 'New York',
      'customer_group_id': 'grp1',
      'total_points_earned': 150.5,
      'amount_due': 20.0,
      'is_due': true,
    };

    test('maps all fields from JSON', () {
      final customer = PosCustomer.fromJson(json);

      expect(customer.id, 'abc123');
      expect(customer.name, 'John Doe');
      expect(customer.email, 'john@example.com');
      expect(customer.phoneNumber, '+1234567890');
      expect(customer.address, '123 Main St');
      expect(customer.country, 'US');
      expect(customer.city, 'New York');
      expect(customer.customerGroupId, 'grp1');
      expect(customer.totalPointsEarned, 150.5);
      expect(customer.amountDue, 20.0);
      expect(customer.isDue, true);
    });

    test('uses defaults for missing optional fields', () {
      final minimal = PosCustomer.fromJson({'_id': 'x', 'name': 'Min', 'phone_number': '000'});

      expect(minimal.email, isNull);
      expect(minimal.address, isNull);
      expect(minimal.country, isNull);
      expect(minimal.city, isNull);
      expect(minimal.customerGroupId, isNull);
      expect(minimal.totalPointsEarned, 0.0);
      expect(minimal.amountDue, 0.0);
      expect(minimal.isDue, false);
    });

    test('handles is_due as integer 1', () {
      final c = PosCustomer.fromJson({'_id': 'y', 'name': 'A', 'phone_number': '1', 'is_due': 1});
      expect(c.isDue, true);
    });

    test('handles is_due as false', () {
      final c = PosCustomer.fromJson({'_id': 'z', 'name': 'B', 'phone_number': '2', 'is_due': false});
      expect(c.isDue, false);
    });
  });

  // ── 12.2 toCreateJson produces correct POST body keys ────────────────────
  group('PosCustomer.toCreateJson', () {
    test('includes required fields', () {
      final customer = PosCustomer(id: '', name: 'Alice', phoneNumber: '555-0100');
      final json = customer.toCreateJson();

      expect(json['name'], 'Alice');
      expect(json['phone_number'], '555-0100');
    });

    test('includes optional fields when provided', () {
      final customer = PosCustomer(
        id: '',
        name: 'Bob',
        phoneNumber: '555-0200',
        email: 'bob@example.com',
        address: '456 Elm St',
      );
      final json = customer.toCreateJson();

      expect(json['email'], 'bob@example.com');
      expect(json['address'], '456 Elm St');
    });

    test('omits optional fields when null', () {
      final customer = PosCustomer(id: '', name: 'Carol', phoneNumber: '555-0300');
      final json = customer.toCreateJson();

      expect(json.containsKey('email'), false);
      expect(json.containsKey('address'), false);
    });

    test('omits optional fields when empty string', () {
      final customer = PosCustomer(
        id: '',
        name: 'Dave',
        phoneNumber: '555-0400',
        email: '',
        address: '',
      );
      final json = customer.toCreateJson();

      expect(json.containsKey('email'), false);
      expect(json.containsKey('address'), false);
    });
  });
}
