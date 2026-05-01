import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration class for managing environment variables
/// and application-wide settings.
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // Supabase Configuration
  static String get supabaseUrl => _getString('SUPABASE_URL');
  static String get supabaseAnonKey => _getString('SUPABASE_ANON_KEY');
  static String? get supabaseServiceRoleKey => _getOptionalString('SUPABASE_SERVICE_ROLE_KEY');

  // Environment
  static String get environment => _getString('ENVIRONMENT', defaultValue: 'development');
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  // API Configuration
  static int get apiTimeoutSeconds => _getInt('API_TIMEOUT_SECONDS', defaultValue: 30);
  static Duration get apiTimeout => Duration(seconds: apiTimeoutSeconds);

  // Feature Flags
  static bool get useSupabaseAuth => _getBool('USE_SUPABASE_AUTH', defaultValue: true);
  static bool get useSupabaseStorage => _getBool('USE_SUPABASE_STORAGE', defaultValue: true);
  static bool get useSupabaseRealtime => _getBool('USE_SUPABASE_REALTIME', defaultValue: true);

  /// Initialize configuration by loading the appropriate .env file
  static Future<void> initialize() async {
    const envFile = kReleaseMode ? '.env.production' : '.env.development';

    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      // If the specific env file fails, try to load default .env
      try {
        await dotenv.load();
      } catch (fallbackError) {
        throw Exception(
          'Failed to load environment configuration. '
          'Please ensure $envFile or .env exists in the project root.',
        );
      }
    }

    _validateConfig();
  }

  /// Validate that required configuration values are present
  static void _validateConfig() {
    final required = [
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY',
    ];

    final missing = <String>[];
    for (final key in required) {
      if (dotenv.env[key]?.isEmpty ?? true) {
        missing.add(key);
      }
    }

    if (missing.isNotEmpty) {
      throw Exception(
        'Missing required environment variables: ${missing.join(', ')}',
      );
    }
  }

  // Helper methods for getting values from dotenv
  static String _getString(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  static String? _getOptionalString(String key) {
    final value = dotenv.env[key];
    return value?.isEmpty ?? true ? null : value;
  }

  static int _getInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  static bool _getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null || value.isEmpty) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }
}
