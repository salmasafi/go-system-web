// // lib/features/admin/permissions/model/permissions_model.dart
// import 'package:systego/features/admin/admins_screen/model/admins_model.dart';

// class AdminPermissionsModel {
//   final String userId;
//   final String username;
//   final String email;
//   final List<ModulePermission> permissions;

//   AdminPermissionsModel({
//     required this.userId,
//     required this.username,
//     required this.email,
//     required this.permissions,
//   });

//   factory AdminPermissionsModel.fromJson(Map<String, dynamic> json) {
//     return AdminPermissionsModel(
//       userId: json['user']['id'] ?? '',
//       username: json['user']['username'] ?? '',
//       email: json['user']['email'] ?? '',
//       permissions: (json['permissions'] as List)
//           .map((e) => ModulePermission.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'username': username,
//       'email': email,
//       'permissions': permissions.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// // class ModulePermission {
// //   final String module;
// //   final List<String> actions;

// //   ModulePermission({
// //     required this.module,
// //     required this.actions,
// //   });

// //   factory ModulePermission.fromJson(Map<String, dynamic> json) {
// //     List<String> actions = [];
    
// //     if (json['actions'] != null && json['actions'] is List) {
// //       final actionsList = json['actions'] as List;
// //       for (var item in actionsList) {
// //         if (item is Map<String, dynamic> && item['action'] != null) {
// //           actions.add(item['action'].toString());
// //         } else if (item is String) {
// //           actions.add(item);
// //         }
// //       }
// //     }
    
// //     return ModulePermission(
// //       module: json['module'] ?? '',
// //       actions: actions,
// //     );
// //   }

// //   Map<String, dynamic> toJson() {
// //     return {
// //       'module': module,
// //       'actions': actions,
// //     };
// //   }

// //   ModulePermission copyWith({
// //     String? module,
// //     List<String>? actions,
// //   }) {
// //     return ModulePermission(
// //       module: module ?? this.module,
// //       actions: actions ?? this.actions,
// //     );
// //   }
// // }


// class ModulePermission {
//   final String module;
//   final List<PermissionAction> actions;

//   ModulePermission({
//     required this.module,
//     required this.actions,
//   });

//   factory ModulePermission.fromJson(Map<String, dynamic> json) {
//     return ModulePermission(
//       module: json['module'] ?? '',
//       actions: (json['actions'] as List?)
//           ?.map((e) => PermissionAction.fromJson(e))
//           .toList() ?? [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'module': module,
//       'actions': actions.map((e) => e.toJson()).toList(),
//     };
//   }

//   // Helper method to get just the action names
//   List<String> get actionNames => actions.map((e) => e.action).toList();
// }

class ModulePermission {
  final String module;
  final List<String> actions;

  ModulePermission({
    required this.module,
    required this.actions,
  });

  factory ModulePermission.fromJson(Map<String, dynamic> json) {
    List<String> actions = [];
    
    // Handle both formats: list of strings or list of objects
    if (json['actions'] != null && json['actions'] is List) {
      final actionsList = json['actions'] as List;
      for (var item in actionsList) {
        if (item is Map<String, dynamic> && item['action'] != null) {
          // Handle format: {"id": "...", "action": "View"}
          actions.add(item['action'].toString());
        } else if (item is String) {
          // Handle format: "View"
          actions.add(item);
        }
      }
    }
    
    return ModulePermission(
      module: json['module'] ?? '',
      actions: actions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'actions': actions,
    };
  }

  ModulePermission copyWith({
    String? module,
    List<String>? actions,
  }) {
    return ModulePermission(
      module: module ?? this.module,
      actions: actions ?? this.actions,
    );
  }
}

class AdminPermissionsModel {
  final String userId;
  final String username;
  final String email;
  final List<ModulePermission> permissions;

  AdminPermissionsModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.permissions,
  });

  factory AdminPermissionsModel.fromJson(Map<String, dynamic> json) {
    return AdminPermissionsModel(
      userId: json['user']['id']?.toString() ?? '',
      username: json['user']['username']?.toString() ?? '',
      email: json['user']['email']?.toString() ?? '',
      permissions: (json['permissions'] as List)
          .map((e) => ModulePermission.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }
}