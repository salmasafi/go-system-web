import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../../core/services/cache_helper.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/user_model.dart' as model;
import 'auth_service_interface.dart';

/// Authentication service using Supabase Auth
/// Mirrors the functionality of the existing Dio-based auth
class SupabaseAuthService implements AuthServiceInterface {
  final SupabaseClient _client;

  SupabaseAuthService(this._client);

  /// Login with email and password
  /// Returns UserModel to match existing API structure
  @override
  Future<model.UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      log('SupabaseAuth: Starting login for $email');

      // Sign in with Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw Exception('Authentication failed: No user or session returned');
      }

      // Fetch additional user data from admins table
      final userData = await _fetchAdminData(response.user!.id);

      // Build UserModel to match existing structure
      final user = model.User(
        id: response.user!.id,
        username: userData?['username'] ?? email.split('@').first,
        email: email,
        position: userData?['position'],
        status: userData?['status'] ?? 'active',
        role: userData?['role']?['name'],
        roles: userData?['roles'] ?? [],
        actions: userData?['actions'] ?? [],
        hasOpenShift: userData?['has_open_shift'] ?? false,
      );

      final data = model.Data(
        message: 'Login successful',
        token: response.session!.accessToken,
        user: user,
      );

      // Save to cache (matching existing behavior)
      await _saveToCache(response.session!.accessToken, user);

      log('SupabaseAuth: Login successful for ${user.username}');

      return model.UserModel(success: true, data: data);
    } on AuthException catch (e) {
      log('SupabaseAuth: AuthException - ${e.message}');
      throw Exception(SupabaseErrorHandler.handleError(e));
    } catch (e) {
      log('SupabaseAuth: Error - $e');
      throw Exception('فشل تسجيل الدخول | Login failed: $e');
    }
  }

  /// Logout user
  @override
  Future<void> logout() async {
    try {
      log('SupabaseAuth: Logging out');

      // Sign out from Supabase
      await _client.auth.signOut();

      // Clear cache
      await CacheHelper.removeData(key: 'user');

      log('SupabaseAuth: Logout successful');
    } catch (e) {
      log('SupabaseAuth: Logout error - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Check if user is currently logged in
  @override
  bool isLoggedIn() {
    return _client.auth.currentSession != null;
  }

  /// Get current session token
  @override
  String? getCurrentToken() {
    return _client.auth.currentSession?.accessToken;
  }

  /// Get current user
  @override
  model.User? getCurrentUser() {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) return null;

    // Try to get cached user data first
    final cachedUser = CacheHelper.getModel<model.User>(
      key: 'user',
      fromJson: (json) => model.User.fromJson(json),
    );

    if (cachedUser != null) {
      return cachedUser;
    }

    // Fallback to basic user from auth
    return model.User(
      id: supabaseUser.id,
      email: supabaseUser.email,
      username: supabaseUser.email?.split('@').first,
    );
  }

  /// Refresh session if needed
  Future<bool> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response.session != null;
    } catch (e) {
      log('SupabaseAuth: Session refresh failed - $e');
      return false;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Fetch admin data from the database
  Future<Map<String, dynamic>?> _fetchAdminData(String userId) async {
    try {
      final response = await _client
          .from('admins')
          .select('''
            *,
            roles:role_id (*),
            warehouses:warehouse_id (*)
          ''')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      log('SupabaseAuth: Failed to fetch admin data - $e');
      return null;
    }
  }

  /// Save authentication data to cache
  Future<void> _saveToCache(String token, model.User user) async {
    // Only save the user model, Supabase handles the token/session automatically
    await CacheHelper.saveModel<model.User>(
      key: 'user',
      model: user,
      toJson: (u) => u.toJson(),
    );
  }

  /// Restore session from cache (for app startup)
  @override
 Future<bool> restoreSession() async {
    try {
      // Check if we have a stored session in Supabase
      final session = _client.auth.currentSession;
      if (session != null) {
        log('SupabaseAuth: Session already active');
        return true;
      }

      // Try to recover session from cache token
      final cachedToken = CacheHelper.getData(key: 'token');
      if (cachedToken != null && cachedToken.isNotEmpty) {
        // Supabase handles session recovery automatically
        // We just need to verify it's still valid
        await _client.auth.recoverSession(cachedToken);
        return _client.auth.currentSession != null;
      }

      return false;
    } catch (e) {
      log('SupabaseAuth: Session restore failed - $e');
      return false;
    }
  }
}
