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

/// Hybrid repository that supports both Dio and Supabase for auth
class AuthRepository implements AuthRepositoryInterface {
  late final AuthRepositoryInterface _dataSource;

  AuthRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('auth')) {
      log('AuthRepository: Using Supabase');
      _dataSource = _AuthSupabaseDataSource();
    } else {
      log('AuthRepository: Using Dio (legacy)');
      _dataSource = _AuthDioDataSource();
    }
  }

  @override
  Future<UserModel> login({required String email, required String password}) =>
      _dataSource.login(email: email, password: password);

  @override
  Future<void> logout() => _dataSource.logout();
}

/// Supabase implementation for Auth data source
class _AuthSupabaseDataSource implements AuthRepositoryInterface {
  final sb.SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      log('AuthSupabase: Logging in');
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
      log('AuthSupabase: Error logging in - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      log('AuthSupabase: Error logging out - $e');
    }
  }
}

/// Dio implementation for Auth data source (legacy)
class _AuthDioDataSource implements AuthRepositoryInterface {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> logout() async {
    // Legacy API might not have a logout endpoint or just client-side token removal
  }
}
