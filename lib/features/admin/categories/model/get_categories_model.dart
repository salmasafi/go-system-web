class CategoryResponse {
  final bool success;
  final CategoryData data;

  CategoryResponse({required this.success, required this.data});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] as bool,
      data: CategoryData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
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
      'ParentCategories': parentCategories
          .map((item) => item.toJson())
          .toList(),
    };
  }
}

class CategoryItem {
  final String id;
  final String name;
  final String arName;
  final String image;
  final int productQuantity;
  final String createdAt;
  final String updatedAt;
  final int version;
  final ParentCategory? parentId;

  CategoryItem({
    required this.id,
    required this.name,
    required this.arName,
    required this.image,
    required this.productQuantity,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.parentId,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      arName: json['ar_name']?.toString() ?? '',
      image: json['image']?.toString() ?? json['image_url']?.toString() ?? '',
      productQuantity: (json['product_quantity'] ?? json['productQuantity'] ?? 0) as int,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
      version: json['version'] ?? json['__v'] ?? 0,
      parentId: (json['parent_id'] ?? json['parentId']) != null
          ? ParentCategory.fromJson((json['parent_id'] ?? json['parentId']) as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'name': name,
      'ar_name': arName,
      'image': image,
      'product_quantity': productQuantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'version': version,
      'parent_id': parentId?.toJson(),
    };
  }
}

class ParentCategory {
  final String id;
  final String name;
  final String arName;

  ParentCategory({required this.id, required this.name, required this.arName});

  factory ParentCategory.fromJson(Map<String, dynamic> json) {
    return ParentCategory(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      arName: json['ar_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'ar_name': arName};
  }
}
