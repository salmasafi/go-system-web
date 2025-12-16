class CurrenciesResponse {
  final bool success;
  final CurrenciesData data;

  CurrenciesResponse({required this.success, required this.data});

  factory CurrenciesResponse.fromJson(Map<String, dynamic> json) {
    return CurrenciesResponse(
      success: json['success'] as bool,
      data: CurrenciesData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class CurrenciesData {
  final String message;
  final List<CurrencyModel> currencies;

  CurrenciesData({required this.message, required this.currencies});

  factory CurrenciesData.fromJson(Map<String, dynamic> json) {
    return CurrenciesData(
      message: json['message'] as String,
      currencies: (json['currencies'] as List<dynamic>)
          .map((item) => CurrencyModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'currencies': currencies.map((item) => item.toJson()).toList(),
    };
  }
}

class CurrencyModel {
  final String id;
  final String name;
  final String arName;
  final bool isDefault;
  final double? amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  CurrencyModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
     this.amount,
    required this.version,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      isDefault: json['isdefault'] as bool,
      // amount: json['amount'] as double ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // Handle null amount
      arName: json['ar_name'] as String,
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      updatedAt: DateTime.parse(json['createdAt'] ?? ''),
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'isdefault': isDefault,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
