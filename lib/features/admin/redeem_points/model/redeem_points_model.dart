class RedeemPointsModel {
  final String id;
  final double amount;
  final int points;

  RedeemPointsModel({
    required this.id,
    required this.amount,
    required this.points,
  });

  factory RedeemPointsModel.fromJson(Map<String, dynamic> json) {
    return RedeemPointsModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
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

  RedeemPointsModel copyWith({
    String? id,
    double? amount,
    int? points,
  }) {
    return RedeemPointsModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      points: points ?? this.points,
    );
  }
}
