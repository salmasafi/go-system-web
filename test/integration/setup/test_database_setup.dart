import 'package:supabase_flutter/supabase_flutter.dart';
import 'test_environment.dart';

class TestDatabaseSetup {
  static SupabaseClient? _testClient;

  static SupabaseClient? get testClient => _testClient;

  static Future<void> initialize() async {
    if (!TestEnvironment.runIntegrationTests) {
      return;
    }

    if (!TestEnvironment.hasSupabaseCredentials) {
      throw StateError(
        'Integration tests requested but SUPABASE_TEST_URL / '
        'SUPABASE_TEST_ANON_KEY are empty.',
      );
    }

    await Supabase.initialize(
      url: TestEnvironment.supabaseUrl,
      anonKey: TestEnvironment.supabaseAnonKey,
    );

    _testClient = Supabase.instance.client;
  }

  static Future<void> dispose() async {
    _testClient = null;
  }
}

/// Legacy method for backward compatibility
Future<void> connectIntegrationDatabase() async {
  await TestDatabaseSetup.initialize();
}