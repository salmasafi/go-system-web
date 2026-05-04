import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration binding is ready', (WidgetTester tester) async {
    expect(tester.binding, isNotNull);
  });
}