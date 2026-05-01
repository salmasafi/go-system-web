class UnitResponse {
  final bool success;
  final UnitData data;

  UnitResponse({required this.success, required this.data});

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    return UnitResponse(
      success: json['success'] as bool,
      data: UnitData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class UnitData {
  final List<UnitModel> units;

  UnitData({
    required this.units,
  });

  factory UnitData.fromJson(Map<String, dynamic> json) {
    return UnitData(
      units: (json['units'] as List<dynamic>)
          .map((item) => UnitModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'units': units.map((unit) => unit.toJson()).toList(),
    };
  }
}

class UnitModel {
  final String id;
  final String code;
  final String name;
  final String arName;
  final BaseUnit? baseUnit; // Can be null for base units
  final String operator;
  final double operatorValue;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
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

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      arName: json['ar_name'] as String? ?? '',
      baseUnit: json['base_unit'] != null
          ? BaseUnit.fromJson(json['base_unit'] as Map<String, dynamic>)
          : null,
      operator: json['operator'] as String? ?? '',
      operatorValue: (json['operator_value'] as num?)?.toDouble() ?? 1.0,
      status: json['status'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      version: json['__v'] as int? ?? json['version'] as int? ?? 1,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      arName: json['ar_name'] as String? ?? '',
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