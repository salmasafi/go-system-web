class TaxResponse {
  final bool success;
  final TaxData data;

  TaxResponse({required this.success, required this.data});

  factory TaxResponse.fromJson(Map<String, dynamic> json) {
    return TaxResponse(
      success: json['success'] as bool,
      data: TaxData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class TaxData {
  final String message;
  final List<TaxModel> taxes;

  TaxData({required this.message, required this.taxes});

  factory TaxData.fromJson(Map<String, dynamic> json) {
    return TaxData(
      message: json['message'] as String,
      taxes: (json['taxes'] as List<dynamic>)
          .map((item) => TaxModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'taxes': taxes.map((item) => item.toJson()).toList(),
    };
  }
}

class TaxModel {
  final String id;
  final String name;
  final String? arName;
  final String type;   
  final bool status;
  final double amount;
  final String createdAt;
  final String updatedAt;
  final int version;

  TaxModel({
    required this.id,
    required this.name,
     this.arName,
    required this.type,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.version
  });



  factory TaxModel.fromJson(Map json) {
    return TaxModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String?,
      type: json['type'] as String,     
      status: json['status'] as bool,
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'type': type,     
      'status': status,
      'amount': amount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}

