class UnitsResponse {
  final bool success;
  final UnitsData data;

  UnitsResponse({required this.success, required this.data});

  factory UnitsResponse.fromJson(Map<String, dynamic> json) {
    return UnitsResponse(
      success: json['success'] as bool,
      data: UnitsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class UnitsData {
  final List<UnitModel> units;

  UnitsData({required this.units});

  factory UnitsData.fromJson(Map<String, dynamic> json) {
    return UnitsData(
      units: (json['units'] as List<dynamic>)
          .map((item) => UnitModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'units': units.map((item) => item.toJson()).toList(),
    };
  }
}

class UnitModel {
  final String id;
  final String code;
  final String name;
  final String arName;
  final BaseUnit? baseUnit;
  final String operator;
  final double operatorValue;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final int version;

  UnitModel({
    required this.id,
    required this.code,
    required this.name,
    required this.arName,
    this.baseUnit,
    required this.operator,
    required this.operatorValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory UnitModel.fromJson(Map json) {
    return UnitModel(
      id: json['_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String,
      baseUnit: json['base_unit'] != null 
          ? BaseUnit.fromJson(json['base_unit'] as Map<String, dynamic>)
          : null,
      operator: json['operator'] as String? ?? '',
      operatorValue: (json['operator_value'] as num?)?.toDouble() ?? 1.0,
      status: json['status'] as bool? ?? true,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'name': name,
      'ar_name': arName,
      'base_unit': baseUnit?.toJson(),
      'operator': operator,
      'operator_value': operatorValue,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}

class BaseUnit {
  final String id;
  final String code;
  final String name;
  final String arName;

  BaseUnit({
    required this.id,
    required this.code,
    required this.name,
    required this.arName,
  });

  factory BaseUnit.fromJson(Map<String, dynamic> json) {
    return BaseUnit(
      id: json['_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'name': name,
      'ar_name': arName,
    };
  }
}
