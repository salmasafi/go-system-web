// lib/features/admin/auth/cubit/login_cubit.dart
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/cache_helper.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../generated/locale_keys.g.dart';
import '../model/user_model.dart';
import 'login_state.dart';

import 'package:GoSystem/features/admin/auth/data/repositories/auth_repository.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _repository;
  LoginCubit(this._repository) : super(LoginInitial()) {
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
      // First try to get from cache (legacy or custom metadata storage)
      _savedUser = CacheHelper.getModel<User>(
        key: 'user',
        fromJson: (json) => User.fromJson(json),
      );
      
      // If no cached user but we have a Supabase session, we might need to fetch it
      if (_savedUser == null && SupabaseClientWrapper.isAuthenticated) {
        final sbUser = SupabaseClientWrapper.currentUser;
        if (sbUser != null) {
          log('Supabase session found, creating temporary user from auth data');
          _savedUser = User(
            id: sbUser.id,
            email: sbUser.email,
            username: sbUser.email?.split('@').first ?? 'User',
            role: 'admin',
          );
        }
      }
      
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

      final result = await _repository.login(email: email, password: password);

      userModel = result;

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
        final errorMsg = userModel?.data?.message ?? LocaleKeys.login_failed.tr();
        log('Login failed: $errorMsg');
        emit(LoginError(errorMsg));
      }
    } catch (error) {
      log('Login exception: $error');
      emit(LoginError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  // Get saved token
  String? getSavedToken() {
    return SupabaseClientWrapper.currentSession?.accessToken;
  }

  // Get saved user (fallback)
  User? getSavedUser() => _savedUser;

  // Check if logged in
  bool isLoggedIn() {
    return SupabaseClientWrapper.isAuthenticated;
  }

  // Optional: Logout
  Future<void> logout() async {
    try {
      await _repository.logout();
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
