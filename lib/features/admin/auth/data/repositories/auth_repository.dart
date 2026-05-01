import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/migration/migration_service.dart';
import '../../../../core/services/cache_helper.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/utils/error_handler.dart';
import '../../model/user_model.dart';
import '../services/auth_service_interface.dart';
import '../services/supabase_auth_service.dart';

/// Hybrid authentication repository that supports both Dio and Supabase
/// Uses MigrationService to determine which data source to use
class AuthRepository implements AuthServiceInterface {
  late final AuthServiceInterface _authService;

  AuthRepository() {
    _initializeService();
  }

  void _initializeService() {
    if (MigrationService.isUsingSupabase('auth')) {
      log('AuthRepository: Using Supabase authentication');
      _authService = SupabaseAuthService(SupabaseClientWrapper.instance);
    } else {
      log('AuthRepository: Using Dio authentication (legacy)');
      _authService = _DioAuthService();
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) {
    return _authService.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return _authService.logout();
  }

  @override
  bool isLoggedIn() {
    return _authService.isLoggedIn();
  }

  @override
  String? getCurrentToken() {
    return _authService.getCurrentToken();
  }

  @override
  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  @override
  Future<bool> restoreSession() {
    return _authService.restoreSession();
  }

  /// Switch to Supabase auth (for migration)
  void enableSupabase() {
    MigrationService.enableSupabase('auth');
    _initializeService();
  }

  /// Switch to Dio auth (for rollback)
  void enableDio() {
    MigrationService.enableDio('auth');
    _initializeService();
  }
}

/// Dio-based authentication service (legacy implementation)
class _DioAuthService implements AuthServiceInterface {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      log('DioAuth: Starting login for $email');

      final response = await DioHelper.postData(
        url: EndPoint.login,
        data: {'email': email, 'password': password},
      );

      log('DioAuth: Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(response.data);

        if (userModel.success == true && userModel.data != null) {
          final data = userModel.data!;

          // Save token
          if (data.token != null && data.token!.isNotEmpty) {
            await CacheHelper.saveData(key: 'token', value: data.token);
          }

          // Save user
          if (data.user != null) {
            await CacheHelper.saveModel<User>(
              key: 'user',
              model: data.user!,
              toJson: (user) => user.toJson(),
            );
          }

          log('DioAuth: Login successful for ${data.user?.username}');
          return userModel;
        } else {
          final errorMsg = userModel.data?.message ?? 'Login failed';
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg = ErrorHandler.handleError(response);
        throw Exception(errorMsg);
      }
    } catch (error) {
      log('DioAuth: Login exception: $error');
      final errorMsg = ErrorHandler.handleError(error);
      throw Exception(errorMsg);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await CacheHelper.removeData(key: 'token');
      await CacheHelper.removeData(key: 'user');
      log('DioAuth: Logout successful');
    } catch (e) {
      log('DioAuth: Logout error: $e');
    }
  }

  @override
  bool isLoggedIn() {
    final token = CacheHelper.getData(key: 'token');
    return token != null && token.isNotEmpty;
  }

  @override
  String? getCurrentToken() {
    return CacheHelper.getData(key: 'token');
  }

  @override
  User? getCurrentUser() {
    return CacheHelper.getModel<User>(
      key: 'user',
      fromJson: (json) => User.fromJson(json),
    );
  }

  @override
  Future<bool> restoreSession() async {
    final token = CacheHelper.getData(key: 'token');
    return token != null && token.isNotEmpty;
  }
}
