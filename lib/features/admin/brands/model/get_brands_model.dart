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
    this.arName,
    this.logo,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Brands.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    name = json['ar_name'];
    logo = json['logo'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? name;
  String? arName;
  String? logo;
  String? createdAt;
  String? updatedAt;
  int? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['ar_name'] = arName;
    map['logo'] = logo;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }
}
