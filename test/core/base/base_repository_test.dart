import 'package:flutter_test/flutter_test.dart';

abstract class BaseRepositoryTest {
  void registerFallbacks();

  Future<void> testCreateSuccess();
  Future<void> testReadListSuccess();
  Future<void> testReadByIdSuccess();
  Future<void> testUpdateSuccess();
  Future<void> testDeleteSuccess();
  Future<void> testNetworkOrDbError();

  void defineTests() {
    setUp(registerFallbacks);
  }
}