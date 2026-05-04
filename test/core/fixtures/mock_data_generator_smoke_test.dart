import 'package:flutter_test/flutter_test.dart';

import 'mock_data_generator.dart';
import 'test_constants.dart';

void main() {
  group('MockDataGenerator', () {
    test('covers all 36 entity slugs with a generator entry point', () {
      expect(TestConstants.entitySlugs.length, 36);

      final samples = <Map<String, dynamic>>[
        MockDataGenerator.generateAdjustment(),
        MockDataGenerator.generateAdmin(),
        MockDataGenerator.generateBankAccount(),
        MockDataGenerator.generateBrand(),
        MockDataGenerator.generateCashier(),
        MockDataGenerator.generateCategory(),
        MockDataGenerator.generateCity(),
        MockDataGenerator.generateCountry(),
        MockDataGenerator.generateCoupon(),
        MockDataGenerator.generateCurrency(),
        MockDataGenerator.generateCustomer(),
        MockDataGenerator.generateCustomerGroup(),
        MockDataGenerator.generateDepartment(),
        MockDataGenerator.generateDiscount(),
        MockDataGenerator.generateExpense(),
        MockDataGenerator.generateExpenseCategory(),
        MockDataGenerator.generatePaymentMethod(),
        MockDataGenerator.generatePermission(),
        MockDataGenerator.generatePoints(),
        MockDataGenerator.generatePopup(),
        MockDataGenerator.generatePrintLabel(),
        MockDataGenerator.generateProduct(),
        MockDataGenerator.generateProductAttribute(),
        MockDataGenerator.generatePurchase(),
        MockDataGenerator.generatePurchaseReturn(),
        MockDataGenerator.generateReason(),
        MockDataGenerator.generateRedeemPoints(),
        MockDataGenerator.generateRevenue(),
        MockDataGenerator.generateRole(),
        MockDataGenerator.generateSupplier(),
        MockDataGenerator.generateTax(),
        MockDataGenerator.generateTransfer(),
        MockDataGenerator.generateUnit(),
        MockDataGenerator.generateVariation(),
        MockDataGenerator.generateWarehouse(),
        MockDataGenerator.generateZone(),
      ];

      expect(samples.length, 36);
      for (final m in samples) {
        expect(m, isNotEmpty);
      }
    });

    test('edge-case helpers return altered maps', () {
      final base = MockDataGenerator.generateBrand(id: 'b-fixed');
      final empty = MockDataGenerator.emptyStringFields(base);
      expect(empty['name'], '');
    });
  });
}