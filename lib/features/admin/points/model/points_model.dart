class PointsResponse {
  final bool success;
  final PointsData data;

  PointsResponse({required this.success, required this.data});

  factory PointsResponse.fromJson(Map<String, dynamic> json) {
    return PointsResponse(
      success: json['success'] as bool,
      data: PointsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class PointsData {
  final String message;
  final List<PointsModel> points;

  PointsData({required this.message, required this.points});

  factory PointsData.fromJson(Map<String, dynamic> json) {
    return PointsData(
      message: json['message'] as String? ?? '',
      points: (json['points'] as List<dynamic>? ?? [])
          .map((e) => PointsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PointsModel {
  final String id;
  final double amount;
  final int points;

  PointsModel({
    required this.id,
    required this.amount,
    required this.points,
  });

  factory PointsModel.fromJson(Map<String, dynamic> json) {
    return PointsModel(
      id: json['_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'points': points,
    };
  }
}
