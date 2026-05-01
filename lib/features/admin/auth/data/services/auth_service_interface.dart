import '../../model/user_model.dart';

/// Interface for authentication services
/// Allows switching between Dio and Supabase implementations
abstract class AuthServiceInterface {
  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Logout user
  Future<void> logout();

  /// Check if user is logged in
  bool isLoggedIn();

  /// Get current token
  String? getCurrentToken();

  /// Get current user
  User? getCurrentUser();

  /// Restore session on app startup
  Future<bool> restoreSession();
}
