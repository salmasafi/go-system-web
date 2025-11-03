class CreateBrandModel {
  CreateBrandModel({
      this.success, 
      this.data,});

  CreateBrandModel.fromJson(dynamic json) {
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
  Data({
      this.message, 
      this.brand,});

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
      this.name, 
      this.logo, 
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  Brand.fromJson(dynamic json) {
    name = json['name'];
    logo = json['logo'];
    id = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? name;
  String? logo;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['logo'] = logo;
    map['_id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}