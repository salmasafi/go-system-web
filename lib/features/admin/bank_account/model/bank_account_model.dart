class BankAccountResponse {
  final bool success;
  final BankAccountData data;

  BankAccountResponse({required this.success, required this.data});

  factory BankAccountResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountResponse(
      success: json['success'] as bool,
      data: BankAccountData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class BankAccountData {
  final String message;
  final List<BankAccountModel> accounts;

  BankAccountData({required this.message, required this.accounts});

  factory BankAccountData.fromJson(Map<String, dynamic> json) {
    return BankAccountData(
      message: json['message'] as String,
      accounts: (json['accounts'] as List<dynamic>)
          .map((item) => BankAccountModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'taxes': accounts.map((item) => item.toJson()).toList(),
    };
  }
}


class BankAccountModel {
  final String id;
  final String name;
  final String? arName;
  final String accountNumber;
  final double initialBalance;
  final String note;
  final String icon;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final int version;

  BankAccountModel({
    required this.id,
    required this.name,
    this.arName,
    required this.accountNumber,
    required this.initialBalance,
    required this.note,
    required this.icon,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String?,
      accountNumber: json['account_no'] ?? 0,
      initialBalance: double.tryParse(json['initial_balance'].toString()) ?? 0.0,
      note: json['note'] as String,
      icon: json['icon'].toString(),
      status: json['is_default'] as bool,
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
      'account_no': accountNumber,
      'initial_balance': initialBalance,
      'note': note,
      'icon': icon,
      'is_default': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}

