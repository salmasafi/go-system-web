import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
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

/// Repository implementation using Supabase for roles
class RoleRepository implements RoleRepositoryInterface {
  final _RoleSupabaseDataSource _dataSource = _RoleSupabaseDataSource();

  @override
  Future<List<RoleModel>> getAllRoles() => _dataSource.getAllRoles();

  @override
  Future<List<RoleModel>> getUserRoles(String userId) => _dataSource.getUserRoles(userId);

  @override
  Future<void> createRole({
    required String name,
    required String status,
    required List<Permission> permissions,
  }) => _dataSource.createRole(
        name: name,
        status: status,
        permissions: permissions,
      );

  @override
  Future<void> updateRole({
    required String id,
    String? name,
    String? status,
    required List<Permission> permissions,
  }) => _dataSource.updateRole(
        id: id,
        name: name,
        status: status,
        permissions: permissions,
      );

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
      if (e is PostgrestException && (e.code == 'PGRST303' || e.code == 'PGRST301')) {
        try {
          log('RoleSupabase: JWT expired, attempting session refresh');
          await _client.auth.refreshSession();
          final response = await _client.from('roles').select().order('name');
          return (response as List).map((json) => _mapSupabaseToRoleModel(json)).toList();
        } catch (_) {}
      }
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
