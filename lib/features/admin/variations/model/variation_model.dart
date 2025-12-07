class VariationResponse {
  final bool success;
  final VariationData data;

  VariationResponse({required this.success, required this.data});

  factory VariationResponse.fromJson(Map<String, dynamic> json) {
    return VariationResponse(
      success: json['success'] as bool,
      data: VariationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class VariationData {
  final List<VariationModel> variations;

  VariationData({required this.variations});

  factory VariationData.fromJson(Map<String, dynamic> json) {
    return VariationData(
      variations: (json['variations'] as List<dynamic>)
          .map((item) => VariationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variations': variations.map((item) => item.toJson()).toList(),
    };
  }
}

class VariationModel {
  final String id;
  final String name;
  final String? arName;
  final String createdAt;
  final String updatedAt;
  final int version;
  final List<VariationOption> options;

  VariationModel({
    required this.id,
    required this.name,
    this.arName,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.options,
  });

  factory VariationModel.fromJson(Map<String, dynamic> json) {
    return VariationModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
      options: (json['options'] as List<dynamic>)
          .map((item) => VariationOption.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'options': options.map((item) => item.toJson()).toList(),
      '__v': version,
    };
  }
}

class VariationOption {
  final String id;
  final String variationId;
  final String name;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final int version;

  VariationOption({
    required this.id,
    required this.variationId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory VariationOption.fromJson(Map<String, dynamic> json) {
    return VariationOption(
      id: json['_id'] as String,
      variationId: json['variationId'] as String,
      name: json['name'] as String,
      status: json['status'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'variationId': variationId,
      'name': name,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}
