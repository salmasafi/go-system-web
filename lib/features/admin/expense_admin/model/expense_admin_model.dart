class ExpenseAdminResponse {
  final bool success;
  final ExpenseAdminData data;

  ExpenseAdminResponse({required this.success, required this.data});

  factory ExpenseAdminResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseAdminResponse(
      success: json['success'] as bool,
      data: ExpenseAdminData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ExpenseAdminData {
  final String message;
  final List<ExpenseAdminModel> expenses;

  ExpenseAdminData({required this.message, required this.expenses});

  factory ExpenseAdminData.fromJson(Map<String, dynamic> json) {
    return ExpenseAdminData(
      message: json['message'] as String? ?? '',
      expenses: (json['expenses'] as List<dynamic>? ?? [])
          .map((e) => ExpenseAdminModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExpenseAdminModel {
  final String id;
  final String name;
  final double amount;
  final String? categoryId;
  final String? financialAccountId;
  final String? financialAccountName;
  final String note;
  final DateTime createdAt;

  ExpenseAdminModel({
    required this.id,
    required this.name,
    required this.amount,
    this.categoryId,
    this.financialAccountId,
    this.financialAccountName,
    required this.note,
    required this.createdAt,
  });

  factory ExpenseAdminModel.fromJson(Map<String, dynamic> json) {
    String? accountId;
    String? accountName;
    final fa = json['financial_accountId'];
    if (fa is Map<String, dynamic>) {
      accountId = fa['_id']?.toString();
      accountName = fa['name']?.toString();
    }

    return ExpenseAdminModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: (json['Category_id'] as Map?)?.containsKey('_id') == true
          ? json['Category_id']['_id']?.toString()
          : null,
      financialAccountId: accountId,
      financialAccountName: accountName,
      note: json['note']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
