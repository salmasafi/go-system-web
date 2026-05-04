abstract class BaseIntegrationTest {
  static bool get isEnabled =>
      const bool.fromEnvironment('RUN_INTEGRATION_TESTS', defaultValue: false);

  Future<void> connectTestDatabase();
  Future<void> cleanupTestData();
}