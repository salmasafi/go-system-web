class ReasonResponse {
  final bool success;
  final ReasonData data;

  ReasonResponse({required this.success, required this.data});

  factory ReasonResponse.fromJson(Map<String, dynamic> json) {
    return ReasonResponse(
      success: json['success'] as bool,
      data: ReasonData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class ReasonData {
  final String message;
  final List<ReasonModel> reasons;

  ReasonData({
    required this.message,
    required this.reasons,
  });

  factory ReasonData.fromJson(Map<String, dynamic> json) {
    return ReasonData(
      message: json['message'] as String,
      reasons: (json['reason'] as List<dynamic>)
          .map((item) => ReasonModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reason': reasons.map((item) => item.toJson()).toList(),
    };
  }
}

class ReasonModel {
  final String id;
  final String reason;
  final DateTime createdAt;
  final int version;

  ReasonModel({
    required this.id,
    required this.reason,
    required this.createdAt,
    required this.version,
  });

  factory ReasonModel.fromJson(Map<String, dynamic> json) {
    return ReasonModel(
      id: (json['_id'] as String?) ?? '',
      reason: (json['reason'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      version: (json['__v'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      '__v': version,
    };
  }

  ReasonModel copyWith({
    String? id,
    String? reason,
    DateTime? createdAt,
    int? version,
  }) {
    return ReasonModel(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
    );
  }
}