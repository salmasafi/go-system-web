// models/product_model.dart
import 'product_attribute_model.dart';

class Product {
  final String id;
  final String name;
  final String image;
  final List<Category> categoryId;
  final Brand brandId;
  final String saleUnit;
  final String purchaseUnit;
  final double price;
  final int quantity;
  final String description;
  final bool expAbility;
  final DateTime? dateOfExpiry;
  final int minimumQuantitySale;
  final int lowStock;
  final double wholePrice;
  final int startQuantaty;
  final String? taxesId;
  final bool productHasImei;
  final bool showQuantity;
  final int maximumToShow;
  final List<String> galleryProduct;
  final bool? isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductAttribute> attributes;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryId,
    required this.brandId,
    required this.saleUnit,
    required this.purchaseUnit,
    required this.price,
    required this.quantity,
    required this.description,
    required this.expAbility,
    this.dateOfExpiry,
    required this.minimumQuantitySale,
    required this.lowStock,
    required this.wholePrice,
    required this.startQuantaty,
    this.taxesId,
    required this.productHasImei,
    required this.showQuantity,
    required this.maximumToShow,
    required this.galleryProduct,
    this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.attributes = const [],
  });

  /// Check if product has attributes assigned
  bool get hasAttributes => attributes.isNotEmpty;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Check if it's from Supabase (has 'id' and no '_id') or legacy
    final isSupabase = json.containsKey('id') && !json.containsKey('_id');
    
    return Product(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      categoryId: isSupabase 
          ? (json['product_categories'] as List<dynamic>?)
              ?.map((e) => Category.fromSupabase(e['category'] as Map<String, dynamic>))
              .toList() ?? []
          : (json['categoryId'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      brandId: isSupabase
          ? (json['brand'] != null ? Brand.fromSupabase(json['brand']) : Brand.empty())
          : (json['brandId'] != null ? Brand.fromJson(json['brandId']) : Brand.empty()),
      saleUnit: json['sale_unit'] ?? '',
      purchaseUnit: json['purchase_unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      description: json['description'] ?? '',
      expAbility: json['exp_ability'] ?? false,
      dateOfExpiry: json['date_of_expiry'] != null
          ? DateTime.tryParse(json['date_of_expiry'])
          : null,
      minimumQuantitySale: (json['minimum_quantity_sale'] as num?)?.toInt() ?? 0,
      lowStock: (json['low_stock'] as num?)?.toInt() ?? 0,
      wholePrice: (json['whole_price'] as num?)?.toDouble() ?? 0.0,
      startQuantaty: (json['start_quantaty'] ?? json['quantity'] as num?)?.toInt() ?? 0,
      taxesId: json['taxes_id'] ?? json['taxesId'],
      productHasImei: json['product_has_imei'] ?? false,
      showQuantity: json['show_quantity'] ?? false,
      maximumToShow: (json['maximum_to_show'] as num?)?.toInt() ?? 0,
      galleryProduct: (json['gallery'] as List<dynamic>?)?.cast<String>() ?? 
                      (json['gallery_product'] as List<dynamic>?)?.cast<String>() ?? [],
      isFeatured: json['is_featured'],
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'categoryId': categoryId.map((e) => e.toJson()).toList(),
      'brandId': brandId.toJson(),
      'sale_unit': saleUnit,
      'purchase_unit': purchaseUnit,
      'price': price,
      'quantity': quantity,
      'description': description,
      'exp_ability': expAbility,
      'date_of_expiry': dateOfExpiry?.toIso8601String(),
      'minimum_quantity_sale': minimumQuantitySale,
      'low_stock': lowStock,
      'whole_price': wholePrice,
      'start_quantaty': startQuantaty,
      'taxesId': taxesId,
      'product_has_imei': productHasImei,
      'show_quantity': showQuantity,
      'maximum_to_show': maximumToShow,
      'gallery_product': galleryProduct,
      'is_featured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'attributes': attributes.map((e) => e.toJson()).toList(),
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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      productQuantity: (json['product_quantity'] as num?)?.toInt() ?? 0,
      parentId: json['parent_id'] ?? json['parentId'],
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory Category.fromSupabase(Map<String, dynamic> json) {
    return Category.fromJson(json);
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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory Brand.fromSupabase(Map<String, dynamic> json) {
    return Brand.fromJson(json);
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

