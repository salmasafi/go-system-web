class GeBrandsModel {
  GeBrandsModel({this.success, this.data});

  GeBrandsModel.fromJson(dynamic json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? success;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({this.message, this.brands});

  Data.fromJson(dynamic json) {
    message = json['message'];
    if (json['brands'] != null) {
      brands = [];
      json['brands'].forEach((v) {
        brands?.add(Brands.fromJson(v));
      });
    }
  }
  String? message;
  List<Brands>? brands;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (brands != null) {
      map['brands'] = brands?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Brands {
  Brands({
    this.id,
    this.name,
    this.logo,
    this.productQuantity,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Brands.fromJson(dynamic json) {
    id = (json['id'] ?? json['_id'] ?? "").toString();
    name = json['name']?.toString() ?? "";
    logo = (json['logo'] ?? json['image_url'] ?? "").toString();
    productQuantity = json['product_quantity'] ?? json['productQuantity'] ?? 0;
    createdAt = (json['created_at'] ?? json['createdAt'] ?? "").toString();
    updatedAt = (json['updated_at'] ?? json['updatedAt'] ?? "").toString();
    v = json['version'] ?? json['__v'] ?? 0;
  }
  String? id;
  String? name;
  String? logo;
  int? productQuantity;
  String? createdAt;
  String? updatedAt;
  int? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['logo'] = logo;
    map['product_quantity'] = productQuantity;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }
}
