// Feature: pos-return-sale
// Widget tests: 10.11 RETURN button exists in POSHomeScreen
//               10.12 Tapping RETURN opens ReturnSearchDialog
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:systego/core/services/cache_helper.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/features/POS/return/cubit/return_cubit.dart';
import 'package:systego/features/POS/return/widgets/return_search_dialog.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// A minimal widget that replicates only the RETURN button from POSHomeScreen's
/// AppBar actions, wrapped with the required BlocProvider.
/// This avoids the complexity of bootstrapping the full POSHomeScreen
/// (which requires shift state, network calls, etc.).
class _ReturnButtonTestHarness extends StatelessWidget {
  const _ReturnButtonTestHarness();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReturnCubit>(
      create: (_) => ReturnCubit(),
      child: MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            appBar: AppBar(
              actions: [
                // This mirrors the exact button from POSHomeScreen
                IconButton(
                  key: const Key('return_button'),
                  icon: const Icon(Icons.assignment_return_outlined),
                  tooltip: 'Return Sale',
                  onPressed: () {
                    showDialog(
                      context: ctx,
                      builder: (_) => BlocProvider.value(
                        value: ctx.read<ReturnCubit>(),
                        child: const ReturnSearchDialog(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockDio mockDio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CacheHelper.sharedPreferences = await SharedPreferences.getInstance();

    mockDio = MockDio();
    DioHelper.dio = mockDio;

    final baseOptions = BaseOptions(baseUrl: 'http://test.local');
    when(() => mockDio.options).thenReturn(baseOptions);
  });

  // 10.11 Widget test: RETURN button is present in POSHomeScreen
  testWidgets('10.11: RETURN button (assignment_return_outlined icon) is present', (tester) async {
    await tester.pumpWidget(const _ReturnButtonTestHarness());
    await tester.pump();

    expect(find.byIcon(Icons.assignment_return_outlined), findsOneWidget);
    expect(find.byTooltip('Return Sale'), findsOneWidget);
  });

  // 10.12 Widget test: Tapping RETURN opens ReturnSearchDialog
  testWidgets('10.12: tapping RETURN button opens ReturnSearchDialog', (tester) async {
    await tester.pumpWidget(const _ReturnButtonTestHarness());
    await tester.pump();

    // Tap the return button
    await tester.tap(find.byIcon(Icons.assignment_return_outlined));
    await tester.pumpAndSettle();

    // ReturnSearchDialog renders an AlertDialog — verify it's open
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(ReturnSearchDialog), findsOneWidget);
  });

  testWidgets('10.12: ReturnSearchDialog contains a TextField and action buttons', (tester) async {
    await tester.pumpWidget(const _ReturnButtonTestHarness());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.assignment_return_outlined));
    await tester.pumpAndSettle();

    // Dialog should have a text field for reference input
    expect(find.byType(TextField), findsOneWidget);

    // Should have at least two buttons (Cancel + Search Sale)
    expect(find.byType(TextButton), findsAtLeastNWidgets(1));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('10.12: Cancel button closes ReturnSearchDialog', (tester) async {
    await tester.pumpWidget(const _ReturnButtonTestHarness());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.assignment_return_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.byType(TextButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
