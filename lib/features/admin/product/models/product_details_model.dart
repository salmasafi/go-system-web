// models/product_details_model.dart
class ProductDetailsModel {
  final bool success;
  final ProductDetailsData? data;

  ProductDetailsModel({
    required this.success,
    this.data,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? ProductDetailsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data?.toJson(),
      };
}

class ProductDetailsData {
  final Product product;
  final String message;

  ProductDetailsData({
    required this.product,
    required this.message,
  });

  factory ProductDetailsData.fromJson(Map<String, dynamic> json) {
    return ProductDetailsData(
      product: Product.fromJson(json['product']),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'message': message,
      };
}

class Product {
  final String id;
  final String name;
  final String image;
  final List<Category> categoryId;
  final Brand? brandId;
  final String saleUnit;
  final String purchaseUnit;
  final double price;
  final int quantity;
  final String description;
  final bool expAbility;
  final int minimumQuantitySale;
  final int lowStock;
  final double wholePrice;
  final int startQuantaty;
  final bool productHasImei;
  final bool showQuantity;
  final int maximumToShow;
  final bool isFeatured;
  final List<String> galleryProduct;
  final DateTime createdAt;
  final DateTime updatedAt;
  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryId,
    this.brandId,
    required this.saleUnit,
    required this.purchaseUnit,
    required this.price,
    required this.quantity,
    required this.description,
    required this.expAbility,
    required this.minimumQuantitySale,
    required this.lowStock,
    required this.wholePrice,
    required this.startQuantaty,
    required this.productHasImei,
    required this.showQuantity,
    required this.maximumToShow,
    required this.isFeatured,
    required this.galleryProduct,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      categoryId: (json['categoryId'] as List?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
      brandId:
          json['brandId'] != null ? Brand.fromJson(json['brandId']) : null,
      saleUnit: json['sale_unit'] ?? '',
      purchaseUnit: json['purchase_unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      expAbility: json['exp_ability'] ?? false,
      minimumQuantitySale: json['minimum_quantity_sale'] ?? 0,
      lowStock: json['low_stock'] ?? 0,
      wholePrice: (json['whole_price'] as num?)?.toDouble() ?? 0.0,
      startQuantaty: json['start_quantaty'] ?? 0,
      productHasImei: json['product_has_imei'] ?? false,
      showQuantity: json['show_quantity'] ?? false,
      maximumToShow: json['maximum_to_show'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      galleryProduct:
          (json['gallery_product'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'image': image,
        'categoryId': categoryId.map((e) => e.toJson()).toList(),
        'brandId': brandId?.toJson(),
        'sale_unit': saleUnit,
        'purchase_unit': purchaseUnit,
        'price': price,
        'quantity': quantity,
        'description': description,
        'exp_ability': expAbility,
        'minimum_quantity_sale': minimumQuantitySale,
        'low_stock': lowStock,
        'whole_price': wholePrice,
        'start_quantaty': startQuantaty,
        'product_has_imei': productHasImei,
        'show_quantity': showQuantity,
        'maximum_to_show': maximumToShow,
        'is_featured': isFeatured,
        'gallery_product': galleryProduct,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class Category {
  final String id;
  final String name;
  final String image;
  final int productQuantity;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.productQuantity,
    this.parentId,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      productQuantity: json['product_quantity'] ?? 0,
      parentId: json['parentId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'image': image,
        'product_quantity': productQuantity,
        'parentId': parentId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class Brand {
  final String id;
  final String name;
  final String logo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.logo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'logo': logo,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

