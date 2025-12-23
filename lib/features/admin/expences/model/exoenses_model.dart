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
    this.note,
    required this.financialAccountId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['Category_id'] as String,
      note: json['note'] as String?,
      financialAccountId: json['financial_accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'amount': amount,
      'Category_id': categoryId,
      'note': note,
      'financial_accountId': financialAccountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}