abstract final class TestEnvironment {
  static const runIntegrationTests =
      bool.fromEnvironment('RUN_INTEGRATION_TESTS', defaultValue: false);

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_TEST_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_TEST_ANON_KEY',
    defaultValue: '',
  );

  static bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}