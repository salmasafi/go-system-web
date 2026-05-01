import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/role_model.dart';

/// Interface for role data operations
abstract class RoleRepositoryInterface {
  Future<List<RoleModel>> getAllRoles();
  Future<List<RoleModel>> getUserRoles(String userId);
  Future<void> createRole({
    required String name,
    required String status,
    required List<Permission> permissions,
  });
  Future<void> updateRole({
    required String id,
    String? name,
    String? status,
    required List<Permission> permissions,
  });
  Future<void> deleteRole(String id);
}

/// Hybrid repository that supports both Dio and Supabase for roles
class RoleRepository implements RoleRepositoryInterface {
  late final RoleRepositoryInterface _dataSource;

  RoleRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('roles')) {
      log('RoleRepository: Using Supabase');
      _dataSource = _RoleSupabaseDataSource();
    } else {
      log('RoleRepository: Using Dio (legacy)');
      _dataSource = _RoleDioDataSource();
    }
  }

  @override
  Future<List<RoleModel>> getAllRoles() => _dataSource.getAllRoles();

  @override
  Future<List<RoleModel>> getUserRoles(String userId) => _dataSource.getUserRoles(userId);

  @override
  Future<void> createRole({
    required String name,
    required String status,
    required List<Permission> permissions,
  }) => _dataSource.createRole(name: name, status: status, permissions: permissions);

  @override
  Future<void> updateRole({
    required String id,
    String? name,
    String? status,
    required List<Permission> permissions,
  }) => _dataSource.updateRole(id: id, name: name, status: status, permissions: permissions);

  @override
  Future<void> deleteRole(String id) => _dataSource.deleteRole(id);
}

/// Supabase implementation for Role data source
class _RoleSupabaseDataSource implements RoleRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<RoleModel>> getAllRoles() async {
    try {
      log('RoleSupabase: Fetching all roles');
      final response = await _client.from('roles').select().order('name');
      return (response as List).map((json) => _mapSupabaseToRoleModel(json)).toList();
    } catch (e) {
      log('RoleSupabase: Error fetching roles - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<RoleModel>> getUserRoles(String userId) async {
    try {
      log('RoleSupabase: Fetching user roles: $userId');
      // In Supabase, we might have a user_roles join table
      final response = await _client
          .from('user_roles')
          .select('*, roles(*)')
          .eq('user_id', userId);
      
      return (response as List)
          .map((json) => _mapSupabaseToRoleModel(json['roles']))
          .toList();
    } catch (e) {
      log('RoleSupabase: Error fetching user roles - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createRole({
    required String name,
    required String status,
    required List<Permission> permissions,
  }) async {
    try {
      log('RoleSupabase: Creating role: $name');
      await _client.from('roles').insert({
        'name': name,
        'status': status,
        'permissions': permissions.map((p) => {
          'module': p.module,
          'actions': p.actions.map((a) => a.toJson()).toList(),
        }).toList(),
      });
    } catch (e) {
      log('RoleSupabase: Error creating role - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateRole({
    required String id,
    String? name,
    String? status,
    required List<Permission> permissions,
  }) async {
    try {
      log('RoleSupabase: Updating role: $id');
      await _client.from('roles').update({
        if (name != null) 'name': name,
        if (status != null) 'status': status,
        'permissions': permissions.map((p) => {
          'module': p.module,
          'actions': p.actions.map((a) => a.toJson()).toList(),
        }).toList(),
      }).eq('id', id);
    } catch (e) {
      log('RoleSupabase: Error updating role - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      log('RoleSupabase: Deleting role: $id');
      await _client.from('roles').delete().eq('id', id);
    } catch (e) {
      log('RoleSupabase: Error deleting role - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  RoleModel _mapSupabaseToRoleModel(Map<String, dynamic> json) {
    final permsList = (json['permissions'] as List?)?.map((p) => Permission.fromJson(p)).toList() ?? [];
    return RoleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'active',
      permissionsCount: permsList.length,
      permissions: permsList,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

/// Dio implementation for Role data source (legacy)
class _RoleDioDataSource implements RoleRepositoryInterface {
  @override
  Future<List<RoleModel>> getAllRoles() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllRoles);
      if (response.statusCode == 200) {
        final model = RoleResponse.fromJson(response.data);
        return model.data.roles;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<RoleModel>> getUserRoles(String userId) async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getUserPermissions(userId));
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((roleJson) => RoleModel.fromJson(roleJson))
            .toList();
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createRole({
    required String name,
    required String status,
    required List<Permission> permissions,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createRolePermission,
        data: {
          'name': name,
          'status': status,
          'permissions': permissions.map((p) => {
            'module': p.module,
            'actions': p.actions.map((a) => a.toJson()).toList(),
          }).toList(),
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateRole({
    required String id,
    String? name,
    String? status,
    required List<Permission> permissions,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateRole(id),
        data: {
          if (name != null) 'name': name,
          if (status != null) 'status': status,
          'permissions': permissions.map((p) => {
            'module': p.module,
            'actions': p.actions.map((a) => a.toJson()).toList(),
          }).toList(),
        },
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteRole(id));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
