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
    // Handle both old API structure and new Supabase joins
    final cat = (json['category'] ?? json['Category_id']) as Map<String, dynamic>? ?? {};
    final acc = (json['bank_account'] ?? json['financial_accountId']) as Map<String, dynamic>? ?? {};
    
    return ExpenseModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      categoryId: cat['id']?.toString() ?? cat['_id']?.toString() ?? '',
      categoryName: cat['name']?.toString() ?? '',
      financialAccountId: acc['id']?.toString() ?? acc['_id']?.toString() ?? '',
      financialAccountName: acc['name']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }
}
