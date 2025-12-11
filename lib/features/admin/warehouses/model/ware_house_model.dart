class WareHouseModel {
  WareHouseModel({
      this.success, 
      this.data,});

  WareHouseModel.fromJson(dynamic json) {
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
      this.warehouses,});

  Data.fromJson(dynamic json) {
    message = json['message'];
    if (json['warehouses'] != null) {
      warehouses = [];
      json['warehouses'].forEach((v) {
        warehouses?.add(Warehouses.fromJson(v));
      });
    }
  }
  String? message;
  List<Warehouses>? warehouses;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (warehouses != null) {
      map['warehouses'] = warehouses?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Warehouses {
  Warehouses({
      required this.id, 
      required this.name, 
      this.address, 
      this.phone, 
      this.email, 
      this.numberOfProducts, 
      this.stockQuantity, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

 Warehouses.fromJson(dynamic json)
    : id = json['_id'] ?? "",
      name = json['name'] ?? "",
      address = json['address'],
      phone = json['phone'],
      email = json['email'],
      numberOfProducts = json['number_of_products'],
      stockQuantity = json['stock_Quantity'],
      createdAt = json['createdAt'],
      updatedAt = json['updatedAt'],
      v = json['__v'];

  String id;
  String name;
  String? address;
  String? phone;
  String? email;
  num? numberOfProducts;
  num? stockQuantity;
  String? createdAt;
  String? updatedAt;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['address'] = address;
    map['phone'] = phone;
    map['email'] = email;
    map['number_of_products'] = numberOfProducts;
    map['stock_Quantity'] = stockQuantity;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}