// lib/features/pos/home/model/pos_models.dart

class Category {
  final String id;
  final String name;
  final String? arName;
  final String? image;
  final int productQuantity;
  final String? parentId;

  Category({
    required this.id,
    required this.name,
    this.arName,
    this.image,
    required this.productQuantity,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      arName: json['ar_name']?.toString(),
      image: json['image']?.toString(),
      productQuantity: (json['product_quantity'] as num?)?.toInt() ?? 0,
      parentId: json['parentId']?.toString(),
    );
  }
}

class Brand {
  final String id;
  final String name;
  final String? logo;

  Brand({required this.id, required this.name, this.logo});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }
}

class Variation {
  final String name;
  final List<VariationOption> options;

  Variation({required this.name, required this.options});

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      name: json['name']?.toString() ?? '',
      options: (json['options'] as List?)
              ?.map((o) => VariationOption.fromJson(o))
              .toList() ??
          [],
    );
  }
}

class VariationOption {
  final String id;
  final String name;
  final String variationId;

  VariationOption({
    required this.id,
    required this.name,
    required this.variationId,
  });

  factory VariationOption.fromJson(Map<String, dynamic> json) {
    return VariationOption(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      variationId: json['variationId']?.toString() ?? '',
    );
  }
}

// ✅ تم تعديل هذا الموديل ليتوافق مع الـ JSON (variations array)
class PriceVariation {
  final String id;
  final String productId;
  final double price;
  final String code;
  final List<String> gallery;
  final int quantity;
  // أحياناً الـ variations الداخلية تكون موجودة وأحياناً لا، جعلناها اختيارية
  final List<Variation> variations; 

  PriceVariation({
    required this.id,
    required this.productId,
    required this.price,
    required this.code,
    required this.gallery,
    required this.quantity,
    required this.variations,
  });

  factory PriceVariation.fromJson(Map<String, dynamic> json) {
    return PriceVariation(
      id: json['_id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      code: json['code']?.toString() ?? '',
      // تأكد من أن الـ gallery قائمة نصوص
      gallery: (json['gallery'] as List?)?.map((e) => e.toString()).toList() ?? [],
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      variations: (json['variations'] as List?)
              ?.map((v) => Variation.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String code;
  final String description;
  final String? image;
  final double price;
  final bool differentPrice;
  final List<PriceVariation> prices;

  Product({
    required this.id,
    required this.name,
    this.image,
    required this.code,
    required this.price,
    required this.description,
    this.differentPrice = false,
    this.prices = const [],
  });

  factory Product.fromList(Map<String, dynamic> json) {
    bool hasDifferentPrice = json['different_price'] as bool? ?? false;
    
    // ✅ الإصلاح الرئيسي هنا: البحث عن variations أو prices
    var rawVariations = json['variations'] ?? json['prices'];

    List<PriceVariation> variationsList = [];
    
    if (hasDifferentPrice && rawVariations != null && rawVariations is List) {
      variationsList = rawVariations
          .map((p) => PriceVariation.fromJson(p))
          .toList();
    }

    // إذا كانت القائمة تحتوي عنصر واحد فقط، نعتبره ليس سعر مختلف لتسهيل العرض
    if (variationsList.length == 1) {
      hasDifferentPrice = false;
    }

    // حساب السعر الافتراضي
    double defaultPrice = 0.0;
    if (hasDifferentPrice && variationsList.isNotEmpty) {
      // نأخذ أقل سعر
      defaultPrice = variationsList
          .map((v) => v.price)
          .reduce((a, b) => a < b ? a : b);
    } else {
      defaultPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    }

    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      code: json['code']?.toString() ?? 'no code',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      price: defaultPrice,
      differentPrice: hasDifferentPrice,
      prices: variationsList,
    );
  }

  factory Product.fromScan(Map<String, dynamic> json) {
    bool hasDifferentPrice = json['different_price'] as bool? ?? false;
    
    // ✅ نفس الإصلاح للـ Scan
    var rawVariations = json['variations'] ?? json['prices'];
    List<PriceVariation> variationsList = [];

    if (hasDifferentPrice && rawVariations != null && rawVariations is List) {
      variationsList = rawVariations
          .map((p) => PriceVariation.fromJson(p))
          .toList();
    } else if (json['price'] is Map) {
      // حالة خاصة لو السعر جاء كأوبجكت وحيد
      variationsList = [
        PriceVariation.fromJson(json['price'] as Map<String, dynamic>),
      ];
    }

    if (variationsList.length == 1) {
      hasDifferentPrice = false;
    }

    double defaultPrice = 0.0;
    if (hasDifferentPrice && variationsList.isNotEmpty) {
      defaultPrice = variationsList
          .map((v) => v.price)
          .reduce((a, b) => a < b ? a : b);
    } else if (json['price'] is num) {
       defaultPrice = (json['price'] as num).toDouble();
    } else if (json['price'] is Map && json['price']['price'] != null) {
       defaultPrice = (json['price']['price'] as num).toDouble();
    }

    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      code: json['code']?.toString() ?? 'no code',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      price: defaultPrice,
      differentPrice: hasDifferentPrice,
      prices: variationsList,
    );
  }
}

// ... بقية الموديلات (Warehouse, Customer, etc.) كما هي في الكود السابق ...
class Warehouse {
  final String id;
  final String name;
  Warehouse({required this.id, required this.name});
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class Customer {
  final String id;
  final String name;
  Customer({required this.id, required this.name});
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class PaymentMethod {
  final String id;
  final String name;
  PaymentMethod({required this.id, required this.name});
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class BankAccount {
  final String id;
  final String name;
  final String? arName;
  final String? accountNumber;
  final num? initialBalance;
  final bool isDefault;
  final String note;
  String icon;

  BankAccount({
    required this.id,
    required this.name,
    required this.arName,
    required this.accountNumber,
    required this.initialBalance,
    required this.isDefault,
    required this.note,
    required this.icon,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'Cash Register',
      arName: json['ar_name'] ?? '',
      accountNumber: json['account_number'],
      initialBalance: json['initial_balance'] ?? 0,
      isDefault: json['is_default'] ?? false,
      icon: json['icon'] ?? '',
      note: json['note'] ?? '',
    );
  }
}

class Tax {
  final String id;
  final String name;
  final double amount;
  final bool status;
  final String type;

  Tax({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.status,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'No Tax',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'fixed',
      status: json['status'] ?? false,
    );
  }
}

class Currency {
  final String id;
  final String name;
  Currency({required this.id, required this.name});
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(id: json['_id'] ?? json['id'], name: json['name'] ?? 'USD');
  }
}