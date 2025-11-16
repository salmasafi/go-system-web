// lib/features/admin/auth/cubit/login_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/endpoints.dart';
import '../../../../core/services/cache_helper.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/user_model.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial()) {
    _loadSavedUser(); // Load saved user on app start
  }

  // Public data
  UserModel? userModel;
  User? _savedUser;

  // Public getter for UI (e.g., AppBar)
  User? get savedUser => _savedUser;

  // Load saved user from cache on initialization
  void _loadSavedUser() {
    try {
      _savedUser = CacheHelper.getModel<User>(
        key: 'user',
        fromJson: (json) => User.fromJson(json),
      );
      log('Saved user loaded: ${_savedUser?.username ?? 'none'}');
    } catch (e) {
      log('Failed to load saved user: $e');
    }
  }

  // Login method
  Future<void> userLogin({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    try {
      log('Starting login request for: $email');

      final response = await DioHelper.postData(
        url: EndPoint.login,
        data: {'email': email, 'password': password},
      );

      log('Login response: ${response.statusCode}');
      DioHelper.printResponse(response);

      if (response.statusCode == 200) {
        userModel = UserModel.fromJson(response.data);

        if (userModel?.success == true && userModel?.data != null) {
          final data = userModel!.data!;

          // Save token
          if (data.token != null && data.token!.isNotEmpty) {
            await CacheHelper.saveData(key: 'token', value: data.token);
            log('Token saved');
          }

          // Save user
          if (data.user != null) {
            await CacheHelper.saveModel<User>(
              key: 'user',
              model: data.user!,
              toJson: (user) => user.toJson(),
            );
            _savedUser = data.user; // Keep in memory
            log('User saved: ${data.user!.username}');
          }

          emit(LoginSuccess());
        } else {
          final errorMsg = userModel?.data?.message ?? 'Login failed';
          log('Login failed: $errorMsg');
          emit(LoginError(errorMsg));
        }
      } else {
        final errorMsg = ErrorHandler.handleError(response);
        emit(LoginError(errorMsg));
      }
    } catch (error) {
      log('Login exception: $error');
      final errorMsg = ErrorHandler.handleError(error);
      emit(LoginError(errorMsg));
    }
  }

  // Get saved token
  String? getSavedToken() {
    return CacheHelper.getData(key: 'token');
  }

  // Get saved user (fallback)
  User? getSavedUser() => _savedUser;

  // Check if logged in
  bool isLoggedIn() {
    final token = getSavedToken();
    return token != null && token.isNotEmpty;
  }

  // Optional: Logout
  Future<void> logout() async {
    try {
      await CacheHelper.removeData(key: 'token');
      await CacheHelper.removeData(key: 'user');
      userModel = null;
      _savedUser = null;
      emit(LoginInitial());
      log('Logged out successfully');
    } catch (e) {
      log('Logout error: $e');
    }
  }
}