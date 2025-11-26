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

class Product {
  final String id;
  final String name;
  final String? image;
  final double price;

  Product({
    required this.id,
    required this.name,
    this.image,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
  factory Product.fromJson2(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      price: (json['price']['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
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
  final String? accountNumber;

  BankAccount({required this.id, required this.name, this.accountNumber});

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'Cash Register',
      accountNumber: json['account_number'],
    );
  }
}

class Tax {
  final String id;
  final String name;
  final double rate;

  Tax({required this.id, required this.name, required this.rate});

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'No Tax',
      rate: (json['amount'] ?? 10).toDouble(),
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
