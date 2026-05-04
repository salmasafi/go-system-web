import 'package:flutter_test/flutter_test.dart';

Future<void> expectAsyncThrows(
  Future<Object?> Function() run,
  Matcher matcher,
) async {
  await expectLater(run, throwsA(matcher));
}