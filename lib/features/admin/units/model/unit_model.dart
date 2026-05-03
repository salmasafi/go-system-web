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
  final String? id;
  final String? code;
  final String? name;
  final String? arName;
  final String? operator;
  final double? operatorValue;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  UnitModel({
    this.id,
    this.code,
    this.name,
    this.arName,
    this.operator,
    this.operatorValue,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      arName: json['ar_name']?.toString(),
      operator: json['operator']?.toString() ?? '*',
      operatorValue: (json['operator_value'] as num?)?.toDouble() ?? 1.0,
      status: json['status'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : DateTime.now(),
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'ar_name': arName,
      'operator': operator,
      'operator_value': operatorValue,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'version': version,
    };
  }
}
