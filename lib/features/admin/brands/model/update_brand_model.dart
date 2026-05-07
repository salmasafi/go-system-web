class UpdateBrandModel {
  UpdateBrandModel({this.success, this.data});

  UpdateBrandModel.fromJson(dynamic json) {
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
  Data({this.message, this.brand});

  Data.fromJson(dynamic json) {
    message = json['message'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
  }
  String? message;
  Brand? brand;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (brand != null) {
      map['brand'] = brand?.toJson();
    }
    return map;
  }
}

class Brand {
  Brand({
    this.id,
    this.name,
    this.logo,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Brand.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    logo = json['logo'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? name;
  String? logo;
  String? createdAt;
  String? updatedAt;
  int? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['logo'] = logo;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }
}
