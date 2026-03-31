class ExpenseModel {
  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final String categoryName;
  final String financialAccountId;
  final String financialAccountName;
  final String note;
  final String createdAt;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.financialAccountId,
    required this.financialAccountName,
    required this.note,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final cat = json['Category_id'] is Map ? json['Category_id'] : {};
    final acc = json['financial_accountId'] is Map ? json['financial_accountId'] : {};
    return ExpenseModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      categoryId: cat['_id'] ?? '',
      categoryName: cat['name'] ?? '',
      financialAccountId: acc['_id'] ?? '',
      financialAccountName: acc['name'] ?? '',
      note: json['note'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
