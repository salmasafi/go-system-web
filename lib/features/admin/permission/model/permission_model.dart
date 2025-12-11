class PermissionResponse {
  final bool success;
  final PermissionData data;

  PermissionResponse({
    required this.success,
    required this.data,
  });

  factory PermissionResponse.fromJson(Map<String, dynamic> json) {
    return PermissionResponse(
      success: json['success'] as bool,
      data: PermissionData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class PermissionData {
  final String message;
  final List<PermissionModel> permisions;

  PermissionData({
    required this.message,
    required this.permisions,
  });

  factory PermissionData.fromJson(Map<String, dynamic> json) {
    return PermissionData(
      message: json['message'] as String,
      permisions: (json['positions'] as List<dynamic>)
          .map((item) => PermissionModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'positions': permisions.map((p) => p.toJson()).toList(),
    };
  }
}

class PermissionModel {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final int version;
  final List<RoleModel> roles;

  PermissionModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.roles,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
      roles: (json['roles'] as List<dynamic>)
          .map((item) => RoleModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
      'roles': roles.map((r) => r.toJson()).toList(),
    };
  }
}

class RoleModel {
  final String name;
  final List<String> actions;

  RoleModel({
    required this.name,
    required this.actions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      name: json['name'] as String,
      actions: List<String>.from(json['actions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'actions': actions,
    };
  }
}
