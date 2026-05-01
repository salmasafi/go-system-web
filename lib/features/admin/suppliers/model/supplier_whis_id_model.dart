class SupplierWhisIdModel {
  SupplierWhisIdModel({
      this.success, 
      this.data,});

  SupplierWhisIdModel.fromJson(dynamic json) {
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
      this.supplier, 
      this.city, 
      this.country,});

  Data.fromJson(dynamic json) {
    message = json['message'];
    supplier = json['supplier'] != null ? Supplier.fromJson(json['supplier']) : null;
    if (json['city'] != null) {
      city = [];
      json['city'].forEach((v) {
        city?.add(City.fromJson(v));
      });
    }
    if (json['country'] != null) {
      country = [];
      json['country'].forEach((v) {
        country?.add(Country.fromJson(v));
      });
    }
  }
  String? message;
  Supplier? supplier;
  List<City>? city;
  List<Country>? country;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (supplier != null) {
      map['supplier'] = supplier?.toJson();
    }
    if (city != null) {
      map['city'] = city?.map((v) => v.toJson()).toList();
    }
    if (country != null) {
      map['country'] = country?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Country {
  Country({
      this.id, 
      this.name, 
      this.isDefault, 
      this.v,});

  Country.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    isDefault = json['isDefault'];
    v = json['__v'];
  }
  String? id;
  String? name;
  bool? isDefault;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['isDefault'] = isDefault;
    map['__v'] = v;
    return map;
  }

}

class City {
  City({
      this.shipingCost, 
      this.id, 
      this.name, 
      this.country, 
      this.v,});

  City.fromJson(dynamic json) {
    shipingCost = json['shipingCost'];
    id = json['_id'];
    name = json['name'];
    country = json['country'];
    v = json['__v'];
  }
  num? shipingCost;
  String? id;
  String? name;
  String? country;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['shipingCost'] = shipingCost;
    map['_id'] = id;
    map['name'] = name;
    map['country'] = country;
    map['__v'] = v;
    return map;
  }

}

class Supplier {
  Supplier({
      this.id, 
      this.image, 
      this.username, 
      this.email, 
      this.phoneNumber, 
      this.address, 
      this.companyName, 
      this.cityId, 
      this.countryId, 
      this.v,});

  Supplier.fromJson(dynamic json) {
    id = json['_id'];
    image = json['image'];
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    companyName = json['company_name'];
    cityId = json['cityId'] != null ? CityId.fromJson(json['cityId']) : null;
    countryId = json['countryId'] != null ? CountryId.fromJson(json['countryId']) : null;
    v = json['__v'];
  }
  String? id;
  String? image;
  String? username;
  String? email;
  String? phoneNumber;
  String? address;
  String? companyName;
  CityId? cityId;
  CountryId? countryId;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['image'] = image;
    map['username'] = username;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    map['address'] = address;
    map['company_name'] = companyName;
    if (cityId != null) {
      map['cityId'] = cityId?.toJson();
    }
    if (countryId != null) {
      map['countryId'] = countryId?.toJson();
    }
    map['__v'] = v;
    return map;
  }

}

class CountryId {
  CountryId({
      this.id, 
      this.name, 
      this.isDefault, 
      this.v,});

  CountryId.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    isDefault = json['isDefault'];
    v = json['__v'];
  }
  String? id;
  String? name;
  bool? isDefault;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['isDefault'] = isDefault;
    map['__v'] = v;
    return map;
  }

}

class CityId {
  CityId({
      this.shipingCost, 
      this.id, 
      this.name, 
      this.country, 
      this.v,});

  CityId.fromJson(dynamic json) {
    shipingCost = json['shipingCost'];
    id = json['_id'];
    name = json['name'];
    country = json['country'];
    v = json['__v'];
  }
  num? shipingCost;
  String? id;
  String? name;
  String? country;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['shipingCost'] = shipingCost;
    map['_id'] = id;
    map['name'] = name;
    map['country'] = country;
    map['__v'] = v;
    return map;
  }

}
