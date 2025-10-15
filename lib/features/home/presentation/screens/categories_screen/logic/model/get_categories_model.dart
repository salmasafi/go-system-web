class CategoryResponse {
  final bool success;
  final CategoryData data;

  CategoryResponse({
    required this.success,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] as bool,
      data: CategoryData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class CategoryData {
  final String message;
  final List<CategoryItem> categories;
  final List<CategoryItem> parentCategories;

  CategoryData({
    required this.message,
    required this.categories,
    required this.parentCategories,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      message: json['message'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      parentCategories: (json['ParentCategories'] as List<dynamic>)
          .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'categories': categories.map((item) => item.toJson()).toList(),
      'ParentCategories': parentCategories.map((item) => item.toJson()).toList(),
    };
  }
}

class CategoryItem {
  final String id;
  final String name;
  final String image;
  final int productQuantity;
  final String createdAt;
  final String updatedAt;
  final int version;
  final ParentCategory? parentId;

  CategoryItem({
    required this.id,
    required this.name,
    required this.image,
    required this.productQuantity,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.parentId,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      productQuantity: json['product_quantity'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
      parentId: json['parentId'] != null
          ? ParentCategory.fromJson(json['parentId'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'product_quantity': productQuantity,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
      'parentId': parentId?.toJson(),
    };
  }
}

class ParentCategory {
  final String id;
  final String name;

  ParentCategory({
    required this.id,
    required this.name,
  });

  factory ParentCategory.fromJson(Map<String, dynamic> json) {
    return ParentCategory(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}