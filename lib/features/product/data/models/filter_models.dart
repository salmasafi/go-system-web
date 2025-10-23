// data/models/filter_models.dart (updated with explicit Brand model)
class ProductFiltersModel {
  final bool success;
  final ProductFiltersData? data;

  ProductFiltersModel({
    required this.success,
    this.data,
  });

  factory ProductFiltersModel.fromJson(Map<String, dynamic> json) {
    return ProductFiltersModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? ProductFiltersData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class ProductFiltersData {
  final List<CategoryFilter> categories;
  final List<BrandFilter> brands;
  final List<VariationFilter> variations;
  final List<WarehouseFilter> warehouses;

  ProductFiltersData({
    required this.categories,
    required this.brands,
    required this.variations,
    required this.warehouses,
  });

  factory ProductFiltersData.fromJson(Map<String, dynamic> json) {
    return ProductFiltersData(
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      brands: (json['brands'] as List<dynamic>? ?? [])
          .map((e) => BrandFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      variations: (json['variations'] as List<dynamic>? ?? [])
          .map((e) => VariationFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      warehouses: (json['warehouses'] as List<dynamic>? ?? [])
          .map((e) => WarehouseFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((e) => e.toJson()).toList(),
      'brands': brands.map((e) => e.toJson()).toList(),
      'variations': variations.map((e) => e.toJson()).toList(),
      'warehouses': warehouses.map((e) => e.toJson()).toList(),
    };
  }
}

// Category model (as before)
class CategoryFilter {
  final String id;
  final String name;
  final String image;
  final String? parentId;
  final int productQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryFilter({
    required this.id,
    required this.name,
    required this.image,
    this.parentId,
    required this.productQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryFilter.fromJson(Map<String, dynamic> json) {
    return CategoryFilter(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      parentId: json['parentId'],
      productQuantity: json['product_quantity'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'parentId': parentId,
      'product_quantity': productQuantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Brand model (explicitly defined for filters)
class BrandFilter {
  final String id;
  final String name;
  final String logo;
  final DateTime createdAt;
  final DateTime updatedAt;

  BrandFilter({
    required this.id,
    required this.name,
    required this.logo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrandFilter.fromJson(Map<String, dynamic> json) {
    return BrandFilter(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

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

// Variation and Option (as before)
class VariationFilter {
  final String id;
  final String name;
  final List<Option> options;
  final DateTime createdAt;
  final DateTime updatedAt;

  VariationFilter({
    required this.id,
    required this.name,
    required this.options,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VariationFilter.fromJson(Map<String, dynamic> json) {
    return VariationFilter(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => Option.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'options': options.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
      status: json['status'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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

// Warehouse (as before)
class WarehouseFilter {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int numberOfProducts;
  final int stockQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  WarehouseFilter({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.numberOfProducts,
    required this.stockQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WarehouseFilter.fromJson(Map<String, dynamic> json) {
    return WarehouseFilter(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      numberOfProducts: json['number_of_products'] ?? 0,
      stockQuantity: json['stock_Quantity'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'number_of_products': numberOfProducts,
      'stock_Quantity': stockQuantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}