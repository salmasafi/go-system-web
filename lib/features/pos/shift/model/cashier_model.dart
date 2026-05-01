// lib/features/pos/cashier/model/cashier_model.dart

class CashierResponse {
  final bool success;
  final CashierData data;

  CashierResponse({
    required this.success,
    required this.data,
  });

  factory CashierResponse.fromJson(Map<String, dynamic> json) {
    return CashierResponse(
      success: json['success'] ?? false,
      data: CashierData.fromJson(json['data']),
    );
  }
}

class CashierData {
  final List<CashierModel> cashiers;

  CashierData({required this.cashiers});

  factory CashierData.fromJson(Map<String, dynamic> json) {
    return CashierData(
      cashiers: (json['cashiers'] as List<dynamic>?)
              ?.map((item) => CashierModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CashierModel {
  final String id;
  final String name;
  final String arName;
  final WarehouseModel warehouse; // تم تعديل النوع هنا ليتناسب مع الرد
  final bool status;
  final bool cashierActive;
  final List<String> bankAccounts;
  final String createdAt;
  final String updatedAt;

  CashierModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.warehouse,
    required this.status,
    required this.cashierActive,
    required this.bankAccounts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) {
    return CashierModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      // التعامل الذكي مع Warehouse (سواء كان أوبجكت أو نص)
      warehouse: WarehouseModel.fromJson(json['warehouse_id']),
      status: json['status'] ?? false,
      cashierActive: json['cashier_active'] ?? false,
      // تحويل قائمة الحسابات البنكية بأمان
      bankAccounts: (json['bankAccounts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'warehouse_id': {'_id': warehouse.id, 'name': warehouse.name},
      'status': status,
      'cashier_active': cashierActive,
      'bankAccounts': bankAccounts,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class WarehouseModel {
  final String id;
  final String name;

  WarehouseModel({required this.id, required this.name});

  factory WarehouseModel.fromJson(dynamic json) {
    // إذا كان البيانات عبارة عن Map (كما في الرد الجديد)
    if (json is Map<String, dynamic>) {
      return WarehouseModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
      );
    } 
    // إذا كان البيانات عبارة عن String (مجرد ID فقط)
    else if (json is String) {
      return WarehouseModel(
        id: json,
        name: '', // الاسم غير متوفر في هذه الحالة
      );
    }
    // حالة افتراضية
    return WarehouseModel(id: '', name: '');
  }
}
