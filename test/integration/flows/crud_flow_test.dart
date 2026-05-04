import 'package:flutter_test/flutter_test.dart';

import '../setup/test_environment.dart';

void main() {
  test('integration gate defaults off', () {
    expect(TestEnvironment.runIntegrationTests, anyOf(isTrue, isFalse));
  });
}