class RoleResponse {
  final bool success;
  final RoleData data;

  RoleResponse({
    required this.success,
    required this.data,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      success: json['success'] as bool,
      data: RoleData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class RoleData {
  final String message;
  final List<RoleModel> roles;

  RoleData({
    required this.message,
    required this.roles,
  });

  factory RoleData.fromJson(Map<String, dynamic> json) {
    return RoleData(
      message: json['message'],
      roles: (json['roles'] as List)
          .map((e) => RoleModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'roles': roles.map((e) => e.toJson()).toList(),
    };
  }
}

class RoleModel {
  final String id;
  final String name;
  final String status;
  final int permissionsCount;
  final List<Permission> permissions;
  final DateTime createdAt;

  RoleModel({
    required this.id,
    required this.name,
    required this.status,
    required this.permissionsCount,
    required this.permissions,
    required this.createdAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      permissionsCount: json['permissionsCount'] ?? 0,
      permissions: (json['permissions'] as List)
          .map((e) => Permission.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'permissionsCount': permissionsCount,
      'permissions': permissions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Permission {
  final String module;
  final List<ActionModel> actions;

  Permission({
    required this.module,
    required this.actions,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      module: json['module'],
      actions: (json['actions'] as List)
          .map((e) => ActionModel.fromJson(e))
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

class ActionModel {
  final String id;
  final String action;

  ActionModel({
    required this.id,
    required this.action,
  });

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      id: json['id'],
      action: json['action'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
    };
  }
}

extension PermissionExtension on Permission {
  Permission copyWith({
    String? module,
    List<ActionModel>? actions,
  }) {
    return Permission(
      module: module ?? this.module,
      actions: actions ?? List.from(this.actions),
    );
  }
}