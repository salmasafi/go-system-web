import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Singleton wrapper for Supabase client to provide centralized
/// access and initialization.
class SupabaseClientWrapper {
  static SupabaseClient? _instance;

  // Private constructor to prevent instantiation
  SupabaseClientWrapper._();

  /// Initialize Supabase with configuration from environment variables
  static Future<void> initialize() async {
    if (_instance != null) {
      throw Exception('Supabase already initialized');
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: kDebugMode,
    );

    _instance = Supabase.instance.client;
  }

  /// Get the initialized Supabase client instance
  static SupabaseClient get instance {
    if (_instance == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseClientWrapper.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Sets a mock instance for testing
  @visibleForTesting
  static void setMockInstance(SupabaseClient client) {
    _instance = client;
  }

  /// Disposes the instance (useful for testing)
  @visibleForTesting
  static void dispose() {
    _instance = null;
  }

  /// Check if Supabase has been initialized
  static bool get isInitialized => _instance != null;

  /// Get the current auth session
  static Session? get currentSession => instance.auth.currentSession;

  /// Get the current user
  static User? get currentUser => instance.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentSession != null;
}
