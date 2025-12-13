// models/product_model.dart
class Product {
  final String id;
  final String name;
  final String arName;
  final String image;
  final List<Category> categoryId;
  final Brand brandId;
  final String unit;
  final double price;
  final int quantity;
  final String description;
  final String arDescription;
  final bool expAbility;
  final DateTime? dateOfExpiery;
  final int minimumQuantitySale;
  final int lowStock;
  final double wholePrice;
  final int startQuantaty;
  final String? taxesId;
  final bool productHasImei;
  final bool differentPrice;
  final bool showQuantity;
  final int maximumToShow;
  final List<String> galleryProduct;
  final bool? isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Price> prices;

  Product({
    required this.id,
    required this.name,
    required this.arName,
    required this.image,
    required this.categoryId,
    required this.brandId,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.description,
    required this.arDescription,
    required this.expAbility,
    this.dateOfExpiery,
    required this.minimumQuantitySale,
    required this.lowStock,
    required this.wholePrice,
    required this.startQuantaty,
    this.taxesId,
    required this.productHasImei,
    required this.differentPrice,
    required this.showQuantity,
    required this.maximumToShow,
    required this.galleryProduct,
    this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    required this.prices,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      image: json['image'] ?? '',
      categoryId:
          (json['categoryId'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      brandId: json['brandId'] != null
          ? Brand.fromJson(json['brandId'] as Map<String, dynamic>)
          : Brand.empty(),
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      arDescription: json['ar_description'] ?? '',
      description: json['description'] ?? '',
      expAbility: json['exp_ability'] ?? false,
      dateOfExpiery: json['date_of_expiery'] != null
          ? DateTime.tryParse(json['date_of_expiery'])
          : null,
      minimumQuantitySale: json['minimum_quantity_sale'] ?? 0,
      lowStock: json['low_stock'] ?? 0,
      wholePrice: (json['whole_price'] as num?)?.toDouble() ?? 0.0,
      startQuantaty: json['start_quantaty'] ?? 0,
      taxesId: json['taxesId'],
      productHasImei: json['product_has_imei'] ?? false,
      differentPrice: json['different_price'] ?? false,
      showQuantity: json['show_quantity'] ?? false,
      maximumToShow: json['maximum_to_show'] ?? 0,
      galleryProduct:
          (json['gallery_product'] as List<dynamic>?)?.cast<String>() ?? [],
      isFeatured: json['is_featured'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      prices:
          (json['prices'] as List<dynamic>?)
              ?.map((e) => Price.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'categoryId': categoryId.map((e) => e.toJson()).toList(),
      'brandId': brandId.toJson(),
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'description': description,
      'exp_ability': expAbility,
      'date_of_expiery': dateOfExpiery?.toIso8601String(),
      'minimum_quantity_sale': minimumQuantitySale,
      'low_stock': lowStock,
      'whole_price': wholePrice,
      'start_quantaty': startQuantaty,
      'taxesId': taxesId,
      'product_has_imei': productHasImei,
      'different_price': differentPrice,
      'show_quantity': showQuantity,
      'maximum_to_show': maximumToShow,
      'gallery_product': galleryProduct,
      'is_featured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'prices': prices.map((e) => e.toJson()).toList(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String image;
  final int productQuantity;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.productQuantity,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      productQuantity: json['product_quantity'] ?? 0,
      parentId: json['parentId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'product_quantity': productQuantity,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
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
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory Brand.empty() => Brand(
    id: '',
    name: '',
    logo: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'logo': logo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Price {
  final String id;
  final String productId;
  final double price;
  final String code;
  final List<String> gallery;
  final int quantity;
  final List<VariationDetail> variations;
  final DateTime createdAt;
  final DateTime updatedAt;

  Price({
    required this.id,
    required this.productId,
    required this.price,
    required this.code,
    required this.gallery,
    required this.quantity,
    required this.variations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      code: json['code'] ?? '',
      gallery: (json['gallery'] as List<dynamic>?)?.cast<String>() ?? [],
      quantity: json['quantity'] ?? 0,
      variations:
          (json['variations'] as List<dynamic>?)
              ?.map((e) => VariationDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'price': price,
      'code': code,
      'gallery': gallery,
      'quantity': quantity,
      'variations': variations.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class VariationDetail {
  final String name;
  final List<Option> options;

  VariationDetail({required this.name, required this.options});

  factory VariationDetail.fromJson(Map<String, dynamic> json) {
    return VariationDetail(
      name: json['name'] ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => Option.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'options': options.map((e) => e.toJson()).toList()};
  }
}

class Option {
  final String id;
  final String variationId;
  final String name;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Option({
    required this.id,
    required this.variationId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['_id'] ?? '',
      variationId: json['variationId'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] is bool ? json['status'] : json['status'] == 1,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'variationId': variationId,
      'name': name,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
