class ExpensesResponse {
  final bool success;
  final ExpensesData data;

  ExpensesResponse({required this.success, required this.data});

  factory ExpensesResponse.fromJson(Map<String, dynamic> json) {
    return ExpensesResponse(
      success: json['success'] as bool,
      data: ExpensesData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class ExpensesData {
  final String message;
  final List<ExpenseModel> expenses;

  ExpensesData({required this.message, required this.expenses});

  factory ExpensesData.fromJson(Map<String, dynamic> json) {
    return ExpensesData(
      message: json['message'] as String,
      expenses: (json['expenses'] as List<dynamic>)
          .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'expenses': expenses.map((item) => item.toJson()).toList(),
    };
  }
}

class ExpenseModel {
  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final String? reasonId;
  final String? note;
  final String financialAccountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    this.reasonId,
    this.note,
    required this.financialAccountId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: (json['category_id'] ?? json['Category_id'] ?? '')?.toString() ?? '',
      reasonId: (json['reason_id'] ?? '')?.toString(),
      note: json['note'] as String?,
      financialAccountId: (json['bank_account_id'] ?? json['financial_accountId'] ?? json['financial_account_id'] ?? '')?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now()),
      version: json['version'] ?? json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'amount': amount,
      'Category_id': categoryId,
      'reason_id': reasonId,
      'note': note,
      'financial_accountId': financialAccountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
