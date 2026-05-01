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

      // Map Supabase user to legacy User model
      final legacyUser = User(
        id: user.id,
        username: user.email ?? 'User',
        email: user.email ?? '',
        role: 'admin', // Default role
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
