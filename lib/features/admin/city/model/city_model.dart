import 'package:GoSystem/features/admin/country/model/country_model.dart';

class CityResponse {
  final bool success;
  final CityData data;

  CityResponse({required this.success, required this.data});

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      success: json['success'] as bool,
      data: CityData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class CityData {
  final String message;
  final List<CityModel> cities;
  final List<CountryModel> countries;

  CityData({
    required this.message,
    required this.cities,
    required this.countries,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      message: json['message'] as String,
      cities: (json['cities'] as List<dynamic>)
          .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      countries: (json['countries'] as List<dynamic>)
          .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'cities': cities.map((item) => item.toJson()).toList(),
      'countries': countries.map((item) => item.toJson()).toList(),
    };
  }
}

// CityResponse and CityData unchanged (they already handle the structure correctly)

class CityModel {
  final String id;
  final num
  shipingCost; // Note: Typo in JSON key ('shipingCost')—keep as-is to match API
  final String name;
  final CountryModel? country; // Fix: Make nullable to handle null from JSON
  final int version;

  CityModel({
    required this.id,
    required this.shipingCost,
    required this.name,
    this.country, // Nullable
    required this.version,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['_id'] as String,
      shipingCost: json['shipingCost'] as num,
      name: json['name'] as String,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'shipingCost': shipingCost,
      'name': name,
      '__v': version,
      'country': country?.toJson(), // Null-safe
    };
  }
}
