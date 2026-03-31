class ShiftModel {
  final String id;
  final DateTime startTime;
  final String status;
  final String cashierId;
  final String cashierManId;
  final double totalSaleAmount;
  final double netCashInDrawer;
  final double totalExpenses;

  ShiftModel({
    required this.id,
    required this.startTime,
    required this.status,
    required this.cashierId,
    required this.cashierManId,
    this.totalSaleAmount = 0.0,
    this.netCashInDrawer = 0.0,
    this.totalExpenses = 0.0,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      // 1. التعامل مع ID الشيفت نفسه
      id: json['_id'] ?? '',

      // 2. تحويل التاريخ (يقبل النص القادم في الـ Response)
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : DateTime.now(),

      // 3. الحالة
      status: json['status'] ?? 'closed',

      // 4. دالة الحماية (تعالج النص "693ea..." وتعالج الـ Map لو حدثت)
      cashierId: _parseId(json['cashier_id']),
      cashierManId: _parseId(json['cashierman_id']),

      // 5. الأرقام (تحويل آمن من int إلى double لأن الـ 0 يعتبر int)
      totalSaleAmount: (json['total_sale_amount'] as num?)?.toDouble() ?? 0.0,
      netCashInDrawer: (json['net_cash_in_drawer'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'start_time': startTime.toIso8601String(),
      'status': status,
      'cashier_id': cashierId,
      'cashierman_id': cashierManId,
      'total_sale_amount': totalSaleAmount,
      'net_cash_in_drawer': netCashInDrawer,
      'total_expenses': totalExpenses,
    };
  }

  // هذه الدالة هي سر ثبات التطبيق
  static String _parseId(dynamic value) {
    if (value == null) return '';
    // في الـ Response الحالي، هذا الشرط هو الذي سيعمل
    if (value is String) return value; 
    // لو تغير الباك إند وأرسل Map، هذا الشرط سيعمل ولن يحدث كراش
    if (value is Map) {
      return value['_id']?.toString() ?? value['id']?.toString() ?? '';
    }
    return value.toString();
  }
}