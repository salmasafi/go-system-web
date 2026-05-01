// get_category_by_id_model.dart
class GetCategoryByIdModel {
  GetCategoryByIdModel({this.success, this.data});

  GetCategoryByIdModel.fromJson(dynamic json) {
    success = json['success'];
    data = json['data'] != null ? CategoryByIdData.fromJson(json['data']) : null;
  }
  bool? success;
  CategoryByIdData? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class CategoryByIdData {
  CategoryByIdData({this.message, this.category});

  CategoryByIdData.fromJson(dynamic json) {
    message = json['message'];
    category = json['category'] != null ? CategoryDetail.fromJson(json['category']) : null;
  }
  String? message;
  CategoryDetail? category;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    return map;
  }
}

class CategoryDetail {
  CategoryDetail({
    this.id,
    this.name,
    this.image,
    this.productQuantity,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  CategoryDetail.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    image = json['image'];
    productQuantity = json['product_quantity'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? name;
  String? image;
  int? productQuantity;
  String? createdAt;
  String? updatedAt;
  int? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['product_quantity'] = productQuantity;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }
}
