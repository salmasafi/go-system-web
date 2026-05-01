import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/permission_model.dart';

/// Interface for permission data operations
abstract class PermissionRepositoryInterface {
  Future<List<PermissionModel>> getAllPermissions();
  Future<void> createPermission({
    required String name,
    required List<RoleModel> roles,
  });
  Future<void> updatePermission({
    required String id,
    required String name,
    required List<RoleModel> roles,
  });
  Future<void> deletePermission(String id);
  Future<PermissionModel?> getPermissionById(String id);
}

/// Hybrid repository that supports both Dio and Supabase for permissions
class PermissionRepository implements PermissionRepositoryInterface {
  late final PermissionRepositoryInterface _dataSource;

  PermissionRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('permissions')) {
      log('PermissionRepository: Using Supabase');
      _dataSource = _PermissionSupabaseDataSource();
    } else {
      log('PermissionRepository: Using Dio (legacy)');
      _dataSource = _PermissionDioDataSource();
    }
  }

  @override
  Future<List<PermissionModel>> getAllPermissions() => _dataSource.getAllPermissions();

  @override
  Future<void> createPermission({
    required String name,
    required List<RoleModel> roles,
  }) => _dataSource.createPermission(name: name, roles: roles);

  @override
  Future<void> updatePermission({
    required String id,
    required String name,
    required List<RoleModel> roles,
  }) => _dataSource.updatePermission(id: id, name: name, roles: roles);

  @override
  Future<void> deletePermission(String id) => _dataSource.deletePermission(id);

  @override
  Future<PermissionModel?> getPermissionById(String id) => _dataSource.getPermissionById(id);
}

/// Supabase implementation for Permission data source
class _PermissionSupabaseDataSource implements PermissionRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<PermissionModel>> getAllPermissions() async {
    try {
      log('PermissionSupabase: Fetching all permissions');
      final response = await _client.from('permissions').select().order('name');
      return (response as List).map((json) => _mapSupabaseToPermissionModel(json)).toList();
    } catch (e) {
      log('PermissionSupabase: Error fetching permissions - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createPermission({
    required String name,
    required List<RoleModel> roles,
  }) async {
    try {
      log('PermissionSupabase: Creating permission: $name');
      await _client.from('permissions').insert({
        'name': name,
        'roles': roles.map((r) => r.toJson()).toList(),
      });
    } catch (e) {
      log('PermissionSupabase: Error creating permission - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updatePermission({
    required String id,
    required String name,
    required List<RoleModel> roles,
  }) async {
    try {
      log('PermissionSupabase: Updating permission: $id');
      await _client.from('permissions').update({
        'name': name,
        'roles': roles.map((r) => r.toJson()).toList(),
      }).eq('id', id);
    } catch (e) {
      log('PermissionSupabase: Error updating permission - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deletePermission(String id) async {
    try {
      log('PermissionSupabase: Deleting permission: $id');
      await _client.from('permissions').delete().eq('id', id);
    } catch (e) {
      log('PermissionSupabase: Error deleting permission - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PermissionModel?> getPermissionById(String id) async {
    try {
      log('PermissionSupabase: Fetching permission by id: $id');
      final response = await _client.from('permissions').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return _mapSupabaseToPermissionModel(response);
    } catch (e) {
      log('PermissionSupabase: Error fetching permission - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  PermissionModel _mapSupabaseToPermissionModel(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      roles: (json['roles'] as List?)?.map((r) => RoleModel.fromJson(r)).toList() ?? [],
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      version: json['version'] ?? 1,
    );
  }
}

/// Dio implementation for Permission data source (legacy)
class _PermissionDioDataSource implements PermissionRepositoryInterface {
  @override
  Future<List<PermissionModel>> getAllPermissions() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllpermissions);
      if (response.statusCode == 200) {
        final model = PermissionResponse.fromJson(response.data);
        return model.data.permisions;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createPermission({
    required String name,
    required List<RoleModel> roles,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addpermission,
        data: {
          'name': name,
          'roles': roles.map((r) => r.toJson()).toList(),
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
  Future<void> updatePermission({
    required String id,
    required String name,
    required List<RoleModel> roles,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updatepermission(id),
        data: {
          'name': name,
          'roles': roles.map((r) => r.toJson()).toList(),
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
  Future<void> deletePermission(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deletepermission(id));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<PermissionModel?> getPermissionById(String id) async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getUserPermissions(id));
      if (response.statusCode == 200) {
        // final model = PermissionResponse.fromJson(response.data);
        // return model.data.permisions.first;
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
