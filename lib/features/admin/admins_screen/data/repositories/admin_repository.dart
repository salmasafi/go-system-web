import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/admins_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseAdminModel {
  final String id;
  final String username;
  final String? fullName;
  final String phone;
  final String role;
  final String? roleId;
  final String? roleName;
  final String? warehouseId;
  final String? warehouseName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupabaseAdminModel({
    required this.id,
    required this.username,
    this.fullName,
    required this.phone,
    required this.role,
    this.roleId,
    this.roleName,
    this.warehouseId,
    this.warehouseName,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SupabaseAdminModel.fromJson(Map<String, dynamic> json) {
    final roleObj = json['role_data'] as Map<String, dynamic>?;
    final warehouseObj = json['warehouse'] as Map<String, dynamic>?;

    return SupabaseAdminModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      roleId: json['role_id'] as String?,
      roleName: roleObj?['name'] as String?,
      warehouseId: json['warehouse_id'] as String?,
      warehouseName: warehouseObj?['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  AdminModel toLegacyModel(String email) {
    return AdminModel(
      id: id,
      username: username,
      email: email, // Email must be joined from auth.users or kept separate
      role: role,
      roleData: roleId != null && roleName != null
          ? RoleData(id: roleId!, name: roleName!)
          : null,
      status: isActive ? 'active' : 'inactive',
      companyName: '', // Add to user_profiles if needed
      phone: phone,
      warehouse: warehouseId != null && warehouseName != null
          ? WarehouseModel(id: warehouseId!, name: warehouseName!)
          : null,
      createdAt: createdAt?.toIso8601String(),
      updatedAt: updatedAt?.toIso8601String(),
    );
  }
}

class SupabaseRoleModel {
  final String id;
  final String name;
  final String? description;

  SupabaseRoleModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory SupabaseRoleModel.fromJson(Map<String, dynamic> json) {
    return SupabaseRoleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class AdminRepositoryInterface {
  Future<List<AdminModel>> getAllAdmins();
  Future<AdminModel?> getAdminById(String id);
  Future<AdminModel> createAdmin({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String roleId,
    String? warehouseId,
  });
  Future<AdminModel> updateAdmin({
    required String id,
    String? username,
    String? phone,
    String? roleId,
    String? warehouseId,
    bool? isActive,
  });
  Future<bool> deleteAdmin(String id);
  
  Future<List<SupabaseRoleModel>> getRoles();
  Future<SupabaseRoleModel> createRole(String name, [String? description]);
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class AdminRepository implements AdminRepositoryInterface {
  late final AdminRepositoryInterface _dataSource;

  AdminRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('admin')) {
      log('AdminRepository: Using Supabase');
      _dataSource = _AdminSupabaseDataSource();
    } else {
      log('AdminRepository: Using Dio (legacy)');
      _dataSource = _AdminDioDataSource();
    }
  }

  @override
  Future<List<AdminModel>> getAllAdmins() => _dataSource.getAllAdmins();

  @override
  Future<AdminModel?> getAdminById(String id) => _dataSource.getAdminById(id);

  @override
  Future<AdminModel> createAdmin({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String roleId,
    String? warehouseId,
  }) =>
      _dataSource.createAdmin(
        username: username,
        email: email,
        password: password,
        phone: phone,
        roleId: roleId,
        warehouseId: warehouseId,
      );

  @override
  Future<AdminModel> updateAdmin({
    required String id,
    String? username,
    String? phone,
    String? roleId,
    String? warehouseId,
    bool? isActive,
  }) =>
      _dataSource.updateAdmin(
        id: id,
        username: username,
        phone: phone,
        roleId: roleId,
        warehouseId: warehouseId,
        isActive: isActive,
      );

  @override
  Future<bool> deleteAdmin(String id) => _dataSource.deleteAdmin(id);

  @override
  Future<List<SupabaseRoleModel>> getRoles() => _dataSource.getRoles();

  @override
  Future<SupabaseRoleModel> createRole(String name, [String? description]) =>
      _dataSource.createRole(name, description);

  void enableSupabase() {
    MigrationService.enableSupabase('admin');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('admin');
    _initializeDataSource();
  }
}

// ─────────────────────────────────────────────
// Supabase Implementation
// ─────────────────────────────────────────────

class _AdminSupabaseDataSource implements AdminRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'user_profiles';

  @override
  Future<List<AdminModel>> getAllAdmins() async {
    try {
      log('AdminSupabase: Fetching all admins');
      // In Supabase, email is stored in auth.users, which is not directly accessible
      // via standard client queries due to security.
      // Usually, you either duplicate email in user_profiles via trigger, or use an RPC.
      // Assuming a secure RPC 'get_all_users_with_email' exists, or we just fetch profiles.
      
      final response = await _client.from(_table).select('''
        *,
        role_data:roles!role_id(id, name),
        warehouse:warehouses!warehouse_id(id, name)
      ''').order('created_at', ascending: false);

      return (response as List).map((json) {
        final profile = SupabaseAdminModel.fromJson(json as Map<String, dynamic>);
        return profile.toLegacyModel('hidden@email.com'); // Placeholder if email isn't in profile
      }).toList();
    } catch (e) {
      log('AdminSupabase: Error fetching admins - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AdminModel?> getAdminById(String id) async {
    try {
      final response = await _client.from(_table).select('''
        *,
        role_data:roles!role_id(id, name),
        warehouse:warehouses!warehouse_id(id, name)
      ''').eq('id', id).maybeSingle();

      if (response == null) return null;
      final profile = SupabaseAdminModel.fromJson(response);
      return profile.toLegacyModel('hidden@email.com');
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AdminModel> createAdmin({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String roleId,
    String? warehouseId,
  }) async {
    try {
      log('AdminSupabase: Creating admin');
      // WARNING: Client-side creation of other users requires calling an Edge Function
      // because auth.signUp logs the current user out.
      // For migration completeness, assuming an RPC 'admin_create_user' exists:
      
      final response = await _client.rpc('admin_create_user', params: {
        'p_email': email,
        'p_password': password,
        'p_username': username,
        'p_phone': phone,
        'p_role_id': roleId,
        'p_warehouse_id': warehouseId,
      });

      final admin = await getAdminById(response['user_id'] as String);
      if (admin == null) throw Exception('Failed to fetch newly created admin');
      return admin;
    } catch (e) {
      log('AdminSupabase: Error creating admin - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AdminModel> updateAdmin({
    required String id,
    String? username,
    String? phone,
    String? roleId,
    String? warehouseId,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (phone != null) updates['phone'] = phone;
      if (roleId != null) updates['role_id'] = roleId;
      if (warehouseId != null) updates['warehouse_id'] = warehouseId;
      if (isActive != null) updates['is_active'] = isActive;

      await _client.from(_table).update(updates).eq('id', id);
      final admin = await getAdminById(id);
      if (admin == null) throw Exception('Admin not found after update');
      return admin;
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteAdmin(String id) async {
    try {
      // In a real app, we usually deactivate instead of deleting
      await _client.from(_table).update({'is_active': false}).eq('id', id);
      return true;
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SupabaseRoleModel>> getRoles() async {
    try {
      final response = await _client.from('roles').select();
      return (response as List).map((e) => SupabaseRoleModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseRoleModel> createRole(String name, [String? description]) async {
    try {
      final response = await _client.from('roles').insert({
        'name': name,
        'description': description,
      }).select().single();
      return SupabaseRoleModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

// ─────────────────────────────────────────────
// Dio (Legacy) Implementation
// ─────────────────────────────────────────────

class _AdminDioDataSource implements AdminRepositoryInterface {
  @override
  Future<List<AdminModel>> getAllAdmins() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllAdmins);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data']?['users'] as List? ?? [];
        return list.map((e) => AdminModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<AdminModel?> getAdminById(String id) async {
    return null; // Legacy API might not have this
  }

  @override
  Future<AdminModel> createAdmin({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String roleId,
    String? warehouseId,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createAdmin,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
          'role_id': roleId,
          if (warehouseId != null) 'warehouse_id': warehouseId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AdminModel.fromJson(response.data['data']?['user'] ?? {});
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<AdminModel> updateAdmin({
    required String id,
    String? username,
    String? phone,
    String? roleId,
    String? warehouseId,
    bool? isActive,
  }) async {
    throw UnimplementedError('Update admin not implemented in legacy Dio');
  }

  @override
  Future<bool> deleteAdmin(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteAdmin(id));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SupabaseRoleModel>> getRoles() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllRoles);
      if (response.statusCode == 200) {
        final list = response.data['data']?['roles'] as List? ?? [];
        return list.map((e) => SupabaseRoleModel(
          id: e['_id'] ?? '',
          name: e['name'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseRoleModel> createRole(String name, [String? description]) async {
    throw UnimplementedError('Create role not implemented in legacy Dio');
  }
}
