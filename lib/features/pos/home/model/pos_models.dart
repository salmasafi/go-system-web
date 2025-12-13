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
      id: json['_id'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String?,
      image: json['image'] as String?,
      productQuantity: json['product_quantity'] as int? ?? 0,
      parentId: json['parentId'] as String?,
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
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
    );
  }
}

// موديل جديد لـ Variation (مثل color أو size)
class Variation {
  final String name; // e.g., "Color" or "Size"
  final List<VariationOption> options;

  Variation({required this.name, required this.options});

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      name: json['name'] as String,
      options: (json['options'] as List)
          .map((o) => VariationOption.fromJson(o))
          .toList(),
    );
  }
}

class VariationOption {
  final String id;
  final String name; // e.g., "brown", "medium"
  final String variationId;

  VariationOption({
    required this.id,
    required this.name,
    required this.variationId,
  });

  factory VariationOption.fromJson(Map<String, dynamic> json) {
    return VariationOption(
      id: json['_id'] as String,
      name: json['name'] as String,
      variationId: json['variationId'] as String,
    );
  }
}

// موديل جديد لكل سعر variation
class PriceVariation {
  final String id;
  final String productId;
  final double price;
  final String code; // e.g., "hoodie1_brown"
  final List<String> gallery;
  final int quantity;
  final List<Variation> variations; // list of color/size etc.

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
      id: json['_id'] as String,
      productId: json['productId'] as String,
      price: (json['price'] as num).toDouble(),
      code: json['code'] as String,
      gallery: (json['gallery'] as List).cast<String>(),
      quantity: json['quantity'] as int,
      variations:
          (json['variations'] as List?)
              ?.map((v) => Variation.fromJson(v))
              .toList() ??
          [],
    );
  }
}

// تعديل موديل Product
class Product {
  final String id;
  final String name;
  final String description;
  final String? image;
  final double price; // سعر افتراضي أو أدنى سعر
  final bool differentPrice; // جديد: هل لديه variations؟
  final List<PriceVariation>
  prices; // جديد: قائمة الـ variations إذا differentPrice true
  // يمكن إضافة حقول أخرى من الـ API إذا لزم (مثل quantity, description)

  Product({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    required this.description,
    this.differentPrice = false,
    this.prices = const [],
  });

  // Factory للرد من القائمة (يحتوي على "prices" array إذا different_price true)
  factory Product.fromList(Map<String, dynamic> json) {
    bool hasDifferentPrice = json['different_price'] as bool? ?? false;
    List<PriceVariation> variations = hasDifferentPrice
        ? (json['prices'] as List?)
                  ?.map((p) => PriceVariation.fromJson(p))
                  .toList() ??
              []
        : [];

    // التحقق الجديد: إذا كان هناك سعر واحد فقط في القائمة، اجعل differentPrice = false
    if (variations.length == 1) {
      hasDifferentPrice = false;
    }

    // حساب السعر الافتراضي: إذا variations، خذ أدنى سعر؛ وإلا السعر الرئيسي
    double defaultPrice = hasDifferentPrice
        ? (variations.isNotEmpty
              ? variations.map((v) => v.price).reduce((a, b) => a < b ? a : b)
              : 0.0)
        : (json['price'] as num?)?.toDouble() ?? 0.0;

    return Product(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      price: defaultPrice,
      differentPrice: hasDifferentPrice,
      prices: variations,
    );
  }

  // Factory للرد من سكان/بحث كود (يحتوي على "price" كـ object، لكن قد يكون variation واحد أو قائمة)
  factory Product.fromScan(Map<String, dynamic> json) {
    bool hasDifferentPrice = json['different_price'] as bool? ?? false;
    List<PriceVariation> variations = [];

    if (hasDifferentPrice) {
      // إذا different_price true، افترض أن "prices" موجودة كقائمة
      variations =
          (json['prices'] as List?)
              ?.map((p) => PriceVariation.fromJson(p))
              .toList() ??
          [];
    } else if (json['price'] is Map) {
      // إذا سعر واحد، حوّله إلى PriceVariation واحد
      variations = [
        PriceVariation.fromJson(json['price'] as Map<String, dynamic>),
      ];
    }

    // التحقق الجديد: إذا كان هناك سعر واحد فقط في القائمة، اجعل differentPrice = false
    if (variations.length == 1) {
      hasDifferentPrice = false;
    }

    // حساب السعر الافتراضي كما فوق
    double defaultPrice = hasDifferentPrice || variations.isNotEmpty
        ? (variations.isNotEmpty
              ? variations.map((v) => v.price).reduce((a, b) => a < b ? a : b)
              : 0.0)
        : (json['price']['price'] as num?)?.toDouble() ?? 0.0;

    return Product(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      price: defaultPrice,
      differentPrice: hasDifferentPrice,
      prices: variations,
    );
  }
}

// Selection Models
class Warehouse {
  final String id;
  final String name;

  Warehouse({required this.id, required this.name});

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(id: json['_id'] as String, name: json['name'] as String);
  }
}

class Customer {
  final String id;
  final String name;

  Customer({required this.id, required this.name});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(id: json['_id'] as String, name: json['name'] as String);
  }
}

class PaymentMethod {
  final String id;
  final String name;

  PaymentMethod({required this.id, required this.name});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
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
  //final String code;
  //final String symbol;

  Currency({
    required this.id,
    required this.name,
    //required this.code, required this.symbol
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'USD',
      //code: json['code'] ?? 'USD',
      //symbol: json['symbol'] ?? '\$',
    );
  }
}
