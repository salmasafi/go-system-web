// lib/features/pos/shift/model/cashier_model.dart

class CashierModel {
  final String id;
  final String name;
  final String arName;
  final String warehouseId;
  final WarehouseModel? warehouse;
  final bool status;
  final bool cashierActive;
  final List<String> bankAccounts;
  final String? createdAt;
  final String? updatedAt;

  CashierModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.warehouseId,
    this.warehouse,
    required this.status,
    required this.cashierActive,
    this.bankAccounts = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) {
    return CashierModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      warehouseId: json['warehouse_id'] ?? '',
      warehouse: json['warehouse'] != null 
          ? WarehouseModel.fromJson(json['warehouse']) 
          : (json['warehouse_id'] is Map 
              ? WarehouseModel.fromJson(json['warehouse_id']) 
              : null),
      status: json['status'] ?? false,
      cashierActive: json['cashier_active'] ?? false,
      bankAccounts: (json['bank_accounts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ar_name': arName,
      'warehouse_id': warehouseId,
      'status': status,
      'cashier_active': cashierActive,
      'bank_accounts': bankAccounts,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class WarehouseModel {
  final String id;
  final String name;
  final String? arName;

  WarehouseModel({
    required this.id, 
    required this.name,
    this.arName,
  });

  factory WarehouseModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return WarehouseModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        arName: json['ar_name'],
      );
    } else if (json is String) {
      return WarehouseModel(
        id: json,
        name: '',
      );
    }
    return WarehouseModel(id: '', name: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ar_name': arName,
    };
  }
}

