class AdminsResponse {
  final bool success;
  final AdminsData data;

  AdminsResponse({
    required this.success,
    required this.data,
  });

  factory AdminsResponse.fromJson(Map<String, dynamic> json) {
    return AdminsResponse(
      success: json['success'] as bool,
      data: AdminsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}


class AdminsData {
  final String message;
  final List<AdminModel> admins;

  AdminsData({
    required this.message,
    required this.admins,
  });

  factory AdminsData.fromJson(Map<String, dynamic> json) {
    return AdminsData(
      message: json['message'] as String,
      admins: (json['users'] as List<dynamic>)
          .map((e) => AdminModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'users': admins.map((e) => e.toJson()).toList(),
    };
  }
}

class AdminModel {
  final String id;
  final String username;
  final String email;
  final String companyName;
  final String phone;
  final String role;
  final String status;
  final String? positionId;
  final String? address;
  final String? state;
  final String? postalCode;
  final int? tokenVersion;
  final String? warehouseId;
  final String? warehouseName;
  final List<PermissionModel> permissions;
  final String? createdAt;
  final String? updatedAt;

  AdminModel({
    required this.id,
    required this.username,
    required this.email,
    required this.companyName,
    required this.phone,
    required this.role,
    required this.status,
    this.positionId,
    this.address,
    this.state,
    this.postalCode,
    this.tokenVersion,
    this.warehouseId,
    this.warehouseName,
    required this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    String? warehouseId;
    String? warehouseName;

    // warehouse can be object or string
    if (json['warehouse_id'] is Map<String, dynamic>) {
      warehouseId = json['warehouse_id']['_id'];
      warehouseName = json['warehouse_id']['name'];
    } else if (json['warehouseId'] is String) {
      warehouseId = json['warehouseId'];
    }

    return AdminModel(
      id: json['_id'] as String,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      positionId: json['positionId']?.toString(),
      address: json['address']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString(),
      tokenVersion: json['tokenVersion'] as int?,
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      permissions: (json['permissions'] as List<dynamic>? ?? [])
          .map((e) => PermissionModel.fromJson(e))
          .toList(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'company_name': companyName,
      'phone': phone,
      'role': role,
      'status': status,
      'positionId': positionId,
      'address': address,
      'state': state,
      'postal_code': postalCode,
      'tokenVersion': tokenVersion,
      'warehouseId': warehouseId,
      'permissions': permissions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}


class PermissionModel {
  final String module;
  final List<PermissionAction> actions;

  PermissionModel({
    required this.module,
    required this.actions,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      module: json['module'] as String,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => PermissionAction.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'actions': actions.map((e) => e.toJson()).toList(),
    };
  }
}

class PermissionAction {
  final String id;
  final String action;

  PermissionAction({
    required this.id,
    required this.action,
  });

  factory PermissionAction.fromJson(Map<String, dynamic> json) {
    return PermissionAction(
      id: json['_id'] as String,
      action: json['action'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'action': action,
    };
  }
}
