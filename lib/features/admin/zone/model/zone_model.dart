class ZoneResponse {
  final bool success;
  final ZoneData data;

  ZoneResponse({required this.success, required this.data});

  factory ZoneResponse.fromJson(Map<String, dynamic> json) {
    return ZoneResponse(
      success: json['success'] as bool,
      data: ZoneData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class ZoneData {
  final String message;
  final List<ZoneModel> zones;

  ZoneData({required this.message, required this.zones});

  factory ZoneData.fromJson(Map<String, dynamic> json) {
    return ZoneData(
      message: json['message'] as String,
      zones: (json['zones'] as List<dynamic>)
          .map((item) => ZoneModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'zones': zones.map((item) => item.toJson()).toList(),
    };
  }
}

// ZoneResponse and ZoneData unchanged (they already handle the structure correctly)

class ZoneModel {
  final String id;
  final num? cost;
  final String name;
  final String arName;
  final CountryForZone country;
  final CityForZone city;
  final int version;

  ZoneModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.country,
    required this.city,
    required this.version,
    required this.cost,
  });

  // Fix: Handle null 'country' in JSON (e.g., second Zone in your response has "country": null)
  // Also specify Map<String, dynamic> for type safety
  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      cost: json['cost'] as num?,
      name: json['name'] as String? ?? '',
      arName: json['ar_name'] as String? ?? '',
      country: CountryForZone.fromJson(
        json['countryId'] as Map<String, dynamic>,
      ),
      city: CityForZone.fromJson(json['cityId'] as Map<String, dynamic>),
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'cost': cost,
      'name': name,
      'ar_name': arName,
      '__v': version,
      'countryId': country.toJson(),
      'cityId': country.toJson(),
    };
  }
}

class CountryForZone {
  final String id;
  final String name;
  final String arName;

  CountryForZone({required this.id, required this.name, required this.arName});

  factory CountryForZone.fromJson(Map<String, dynamic> json) {
    return CountryForZone(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] as String? ?? '',
      arName: json['ar_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'ar_name': arName};
  }
}

class CityForZone {
  final String id;
  final String name;
  final String arName;
  final num shipingCost;

  CityForZone({
    required this.id,
    required this.name,
    required this.arName,
    required this.shipingCost,
  });

  factory CityForZone.fromJson(Map<String, dynamic> json) {
    return CityForZone(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] as String? ?? '',
      arName: json['ar_name'] as String? ?? '',
      shipingCost: json['shipingCost'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'shipingCost': shipingCost,
    };
  }
}
