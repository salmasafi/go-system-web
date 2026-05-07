class CountryResponse {
  final bool success;
  final CountryData data;

  CountryResponse({required this.success, required this.data});

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      success: json['success'] as bool,
      data: CountryData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class CountryData {
  final String message;
  final List<CountryModel> countries;

  CountryData({required this.message, required this.countries});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      message: json['message'] as String,
      countries: (json['countries'] as List<dynamic>)
          .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'countries': countries.map((item) => item.toJson()).toList(),
    };
  }
}

class CountryModel {
  final String id;
  final String name;
  final bool isDefault;
  final int version;

  CountryModel({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.version,
  });

  factory CountryModel.fromJson(Map json) {
    return CountryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      isDefault: json['isDefault'] as bool,
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'isDefault': isDefault,
      '__v': version,
    };
  }
}
