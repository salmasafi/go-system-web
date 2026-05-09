import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/cache_helper.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/user_model.dart';

/// Interface for authentication data operations
abstract class AuthRepositoryInterface {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}

/// Auth repository using Supabase as the primary data source.
class AuthRepository implements AuthRepositoryInterface {
  final sb.SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      log('AuthRepository: Logging in');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      final session = response.session;

      if (user == null || session == null) {
        throw Exception('Login failed: Invalid credentials');
      }

      // Fetch real profile from user_profiles (role + warehouse)
      String realRole = 'cashier';
      String? warehouseId;
      String? warehouseName;
      String displayName = user.email ?? 'User';

      try {
        final profile = await _client
            .from('user_profiles')
            .select('role, warehouse_id, full_name, warehouses(name)')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          realRole = profile['role'] as String? ?? 'cashier';
          warehouseId = profile['warehouse_id'] as String?;
          displayName = profile['full_name'] as String? ?? displayName;
          final wh = profile['warehouses'];
          if (wh is Map) {
            warehouseName = wh['name'] as String?;
          }
        }
      } catch (e) {
        log('AuthRepository: Could not fetch user_profiles — $e');
      }

      final legacyUser = User(
        id: user.id,
        username: displayName,
        email: user.email ?? '',
        role: realRole,
        warehouseId: warehouseId,
        warehouseName: warehouseName,
      );

      final data = Data(
        user: legacyUser,
        token: session.accessToken,
        message: 'Login successful',
      );

      return UserModel(success: true, data: data);
    } catch (e) {
      log('AuthRepository: Error logging in - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      log('AuthRepository: Logging out');
      await _client.auth.signOut();
    } catch (e) {
      log('AuthRepository: Error logging out - $e');
    }
  }
}
