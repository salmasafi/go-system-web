class CashierResponse {
  final bool success;
  final CashierData data;

  CashierResponse({
    required this.success,
    required this.data,
  });

  factory CashierResponse.fromJson(Map<String, dynamic> json) {
    return CashierResponse(
      success: json['success'] as bool,
      data: CashierData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class CashierData {
  final String message;
  final List<CashierModel> cashiers;

  CashierData({
    required this.message,
    required this.cashiers,
  });

  factory CashierData.fromJson(Map<String, dynamic> json) {
    return CashierData(
      message: json['message'],
      cashiers: (json['cashiers'] as List<dynamic>)
          .map((item) => CashierModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'cashiers': cashiers.map((e) => e.toJson()).toList(),
    };
  }
}

class CashierModel {
  final String id;
  final String name;
  final String arName;
  final Warehouse warehouse;
  final bool status;
  final bool cashierActive;
  final String createdAt;
  final String updatedAt;
  final int version;
  final List<User> users;
  final List<BankAccount> bankAccounts;

   CashierModel copyWith({
    String? id,
    String? name,
    String? arName,
    Warehouse? warehouse,
    bool? status,
    bool? cashierActive,
    String? createdAt,
    String? updatedAt,
    int? version,
    List<User>? users,
    List<BankAccount>? bankAccounts,
  }) {
    return CashierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      arName: arName ?? this.arName,
      warehouse: warehouse ?? this.warehouse,
      status: status ?? this.status,
      cashierActive: cashierActive ?? this.cashierActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      users: users ?? this.users,
      bankAccounts: bankAccounts ?? this.bankAccounts,
    );
  }

  CashierModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.warehouse,
    required this.status,
    required this.cashierActive,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.users,
    required this.bankAccounts,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) {
    return CashierModel(
      id: json['_id'],
      name: json['name'],
      arName: json['ar_name'],
      warehouse: Warehouse.fromJson(json['warehouse_id']),
      status: json['status'],
      cashierActive: json['cashier_active'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
      users: (json['users'] as List<dynamic>)
          .map((item) => User.fromJson(item))
          .toList(),
      bankAccounts: (json['bankAccounts'] as List<dynamic>)
          .map((item) => BankAccount.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'warehouse_id': warehouse.toJson(),
      'status': status,
      'cashier_active': cashierActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
      'users': users.map((e) => e.toJson()).toList(),
      'bankAccounts': bankAccounts.map((e) => e.toJson()).toList(),
      'id': id,
    };
  }
}

class Warehouse {
  final String id;
  final String name;

  Warehouse({
    required this.id,
    required this.name,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String status;
  final String warehouseId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.status,
    required this.warehouseId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      warehouseId: json['warehouseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'role': role,
      'status': status,
      'warehouseId': warehouseId,
    };
  }
}

class BankAccount {
  final String id;
  final String name;
  final List<String> warehouseId;
  final double balance;
  final bool status;
  final bool inPOS;

  BankAccount({
    required this.id,
    required this.name,
    required this.warehouseId,
    required this.balance,
    required this.status,
    required this.inPOS,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['_id'],
      name: json['name'],
      warehouseId: (json['warehouseId'] as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
      balance: (json['balance'] as num).toDouble(),
      status: json['status'],
      inPOS: json['in_POS'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'warehouseId': warehouseId,
      'balance': balance,
      'status': status,
      'in_POS': inPOS,
    };
  }
}