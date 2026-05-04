import 'dart:math';

class MockDataGenerator {
  MockDataGenerator._();

  static final Random _rnd = Random();

  static String _id(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_rnd.nextInt(1 << 20)}';

  static String _isoNow() => DateTime.now().toIso8601String();

  static Map<String, dynamic> emptyStringFields(Map<String, dynamic> base) {
    final m = Map<String, dynamic>.from(base);
    for (final e in m.entries.toList()) {
      if (e.value is String) m[e.key] = '';
    }
    return m;
  }

  static Map<String, dynamic> nullOptionalFields(Map<String, dynamic> base) =>
      Map<String, dynamic>.from(base)..removeWhere((_, v) => v == null);

  static Map<String, dynamic> generateAdjustment({String? id}) => {
        'id': id ?? _id('adj'),
        'reference': 'REF',
        'warehouse_id': _id('wh'),
        'created_at': _isoNow(),
      };

  static Map<String, dynamic> generateAdmin({String? id}) => {
        'id': id ?? _id('adm'),
        'email': 'a@test',
      };

  static Map<String, dynamic> generateBankAccount({String? id}) => {
        'id': id ?? _id('bank'),
        'name': 'Main',
      };

  static Map<String, dynamic> generateBrand({String? id}) => {
        'id': id ?? _id('brand'),
        'name': 'Brand',
      };

  static Map<String, dynamic> generateCashier({String? id}) => {
        'id': id ?? _id('cash'),
        'name': 'C',
      };

  static Map<String, dynamic> generateCategory({String? id}) => {
        'id': id ?? _id('cat'),
        'name': 'Cat',
      };

  static Map<String, dynamic> generateCity({String? id}) => {
        'id': id ?? _id('city'),
        'name': 'City',
      };

  static Map<String, dynamic> generateCountry({String? id}) => {
        'id': id ?? _id('country'),
        'name': 'Country',
      };

  static Map<String, dynamic> generateCoupon({String? id}) => {
        'id': id ?? _id('coup'),
        'code': 'SAVE',
      };

  static Map<String, dynamic> generateCurrency({String? id}) => {
        'id': id ?? _id('cur'),
        'code': 'USD',
      };

  static Map<String, dynamic> generateCustomer({String? id}) => {
        'id': id ?? _id('cust'),
        'name': 'Customer',
      };

  static Map<String, dynamic> generateCustomerGroup({String? id}) => {
        'id': id ?? _id('cg'),
        'name': 'Group',
      };

  static Map<String, dynamic> generateDepartment({String? id}) => {
        'id': id ?? _id('dep'),
        'name': 'Dept',
      };

  static Map<String, dynamic> generateDiscount({String? id}) => {
        'id': id ?? _id('disc'),
        'name': 'Disc',
      };

  static Map<String, dynamic> generateExpense({String? id}) => {
        'id': id ?? _id('exp'),
        'amount': 1.0,
      };

  static Map<String, dynamic> generateExpenseCategory({String? id}) => {
        'id': id ?? _id('exc'),
        'name': 'Exc',
      };

  static Map<String, dynamic> generatePaymentMethod({String? id}) => {
        'id': id ?? _id('pm'),
        'name': 'Card',
      };

  static Map<String, dynamic> generatePermission({String? id}) => {
        'id': id ?? _id('perm'),
        'key': 'k',
      };

  static Map<String, dynamic> generatePoints({String? id}) => {
        'id': id ?? _id('pts'),
        'balance': 0,
      };

  static Map<String, dynamic> generatePopup({String? id}) => {
        'id': id ?? _id('pop'),
        'title': 'T',
      };

  static Map<String, dynamic> generatePrintLabel({String? id}) => {
        'id': id ?? _id('lbl'),
        'qty': 1,
      };

  static Map<String, dynamic> generateProduct({String? id}) => {
        'id': id ?? _id('prod'),
        'name': 'Product',
      };

  static Map<String, dynamic> generateProductAttribute({String? id}) => {
        'id': id ?? _id('attr'),
        'name': 'Attr',
      };

  static Map<String, dynamic> generatePurchase({String? id}) => {
        'id': id ?? _id('pur'),
        'total': 1.0,
      };

  static Map<String, dynamic> generatePurchaseReturn({String? id}) => {
        'id': id ?? _id('prt'),
        'purchase_id': _id('pur'),
      };

  static Map<String, dynamic> generateReason({String? id}) => {
        'id': id ?? _id('rsn'),
        'name': 'Reason',
      };

  static Map<String, dynamic> generateRedeemPoints({String? id}) => {
        'id': id ?? _id('rdm'),
        'points': 1,
      };

  static Map<String, dynamic> generateRevenue({String? id}) => {
        'id': id ?? _id('rev'),
        'amount': 1.0,
      };

  static Map<String, dynamic> generateRole({String? id}) => {
        'id': id ?? _id('role'),
        'name': 'Role',
      };

  static Map<String, dynamic> generateSupplier({String? id}) => {
        'id': id ?? _id('sup'),
        'name': 'Supplier',
      };

  static Map<String, dynamic> generateTax({String? id}) => {
        'id': id ?? _id('tax'),
        'rate': 1.0,
      };

  static Map<String, dynamic> generateTransfer({String? id}) => {
        'id': id ?? _id('trf'),
        'status': 'pending',
      };

  static Map<String, dynamic> generateUnit({String? id}) => {
        'id': id ?? _id('unit'),
        'name': 'pc',
      };

  static Map<String, dynamic> generateVariation({String? id}) => {
        'id': id ?? _id('var'),
        'sku': 'SKU',
      };

  static Map<String, dynamic> generateWarehouse({String? id}) => {
        'id': id ?? _id('wh'),
        'name': 'WH',
      };

  static Map<String, dynamic> generateZone({String? id}) => {
        'id': id ?? _id('zone'),
        'name': 'Zone',
      };

  // ================= INVALID DATA GENERATION FOR ERROR TESTING =================

  static Map<String, dynamic> generateInvalidAdjustment() => {
        'id': '',
        'reference': '',
        'warehouse_id': '',
      };

  static Map<String, dynamic> generateInvalidAdmin() => {
        'id': '',
        'email': 'invalid-email',
        'password': '',
      };

  static Map<String, dynamic> generateInvalidBrand() => {
        'id': '',
        'name': '',
      };

  static Map<String, dynamic> generateInvalidCategory() => {
        'id': '',
        'name': '',
      };

  static Map<String, dynamic> generateInvalidProduct() => {
        'id': '',
        'name': '',
        'price': -100.0,
        'quantity': -5,
      };

  static Map<String, dynamic> generateInvalidCustomer() => {
        'id': '',
        'name': '',
        'email': 'invalid',
      };

  static Map<String, dynamic> generateInvalidSupplier() => {
        'id': '',
        'company_name': '',
        'email': 'invalid',
      };

  static Map<String, dynamic> generateInvalidWarehouse() => {
        'id': '',
        'name': '',
      };

  static Map<String, dynamic> generateInvalidPurchase() => {
        'id': '',
        'reference': '',
        'grand_total': -1000.0,
      };

  static Map<String, dynamic> generateInvalidCity() => {
        'id': '',
        'name': '',
        'shipping_cost': -10.0,
      };

  static Map<String, dynamic> generateInvalidCoupon() => {
        'id': '',
        'coupon_code': '',
        'amount': -50.0,
        'quantity': -1,
      };

  static Map<String, dynamic> generateInvalidDiscount() => {
        'id': '',
        'name': '',
        'amount': -10.0,
      };

  static Map<String, dynamic> generateInvalidTax() => {
        'id': '',
        'name': '',
        'amount': -15.0,
      };

  static Map<String, dynamic> generateNullFields(String entity) {
    switch (entity) {
      case 'brand':
        return {'id': null, 'name': null};
      case 'category':
        return {'id': null, 'name': null};
      case 'product':
        return {'id': null, 'name': null, 'price': null};
      case 'customer':
        return {'id': null, 'name': null, 'email': null};
      default:
        return {};
    }
  }

  static Map<String, dynamic> generateEmptyStringFields(String entity) {
    switch (entity) {
      case 'brand':
        return {'id': '', 'name': ''};
      case 'category':
        return {'id': '', 'name': ''};
      case 'product':
        return {'id': '', 'name': '', 'code': ''};
      case 'customer':
        return {'id': '', 'name': '', 'email': ''};
      default:
        return {};
    }
  }
}