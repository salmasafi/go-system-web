class GetCategoriesModel {
  GetCategoriesModel({this.success, this.data});

  GetCategoriesModel.fromJson(dynamic json) {
    success = json['success'];
    data = json['data'] != null ? CategoriesData.fromJson(json['data']) : null;
  }
  bool? success;
  CategoriesData? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) map['data'] = data?.toJson();
    return map;
  }
}

class CategoriesData {
  CategoriesData({this.message, this.categories, this.parentCategories});

  CategoriesData.fromJson(dynamic json) {
    message = json['message'];
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) => categories?.add(CategoryItem.fromJson(v)));
    }
    if (json['ParentCategories'] != null) {
      parentCategories = [];
      json['ParentCategories'].forEach((v) => parentCategories?.add(CategoryItem.fromJson(v)));
    }
  }
  String? message;
  List<CategoryItem>? categories;
  List<CategoryItem>? parentCategories;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (categories != null) map['categories'] = categories?.map((v) => v.toJson()).toList();
    if (parentCategories != null) map['ParentCategories'] = parentCategories?.map((v) => v.toJson()).toList();
    return map;
  }
}

class CategoryItem {
  CategoryItem({
    this.id,
    this.name,
    this.image,
    this.productQuantity,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  CategoryItem.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    image = json['image'];
    productQuantity = json['product_quantity'];
    parentId = json['parentId'] != null ? ParentIdInfo.fromJson(json['parentId']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? name;
  String? image;
  int? productQuantity;
  ParentIdInfo? parentId;
  String? createdAt;
  String? updatedAt;
  int? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['product_quantity'] = productQuantity;
    if (parentId != null) map['parentId'] = parentId?.toJson();
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
class ParentIdInfo {
  ParentIdInfo({this.id, this.name});

  ParentIdInfo.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
  }
  String? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    return map;
  }
}