import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:systego/features/POS/customer/cubit/pos_customer_cubit.dart';
import 'package:systego/features/POS/customer/model/pos_customer_model.dart';
import 'package:systego/features/POS/customer/presentation/widgets/customer_selector_widget.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockPosCustomerCubit extends MockCubit<PosCustomerState>
    implements PosCustomerCubit {}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildSubject(MockPosCustomerCubit cubit) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<PosCustomerCubit>.value(
        value: cubit,
        child: const CustomerSelectorWidget(),
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockPosCustomerCubit cubit;

  setUp(() {
    cubit = MockPosCustomerCubit();
  });

  tearDown(() => cubit.close());

  // ── 12.9 shows placeholder when no customer selected ─────────────────────
  testWidgets('shows "Select Customer" placeholder when selectedCustomer is null', (tester) async {
    when(() => cubit.state).thenReturn(PosCustomerLoaded(customers: []));
    when(() => cubit.selectedCustomer).thenReturn(null);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.text('Select Customer'), findsOneWidget);
  });

  // ── 12.10 shows name + phone when customer selected ───────────────────────
  testWidgets('shows customer name and phone when selectedCustomer is set', (tester) async {
    const customer = PosCustomer(id: 'c1', name: 'Alice Smith', phoneNumber: '555-0001');

    when(() => cubit.state).thenReturn(
      PosCustomerLoaded(customers: [customer], selectedCustomer: customer),
    );
    when(() => cubit.selectedCustomer).thenReturn(customer);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('555-0001'), findsOneWidget);
    expect(find.text('Select Customer'), findsNothing);
  });

  // ── 12.11 "+" button always present in both states ────────────────────────
  testWidgets('"+" button is present when no customer selected', (tester) async {
    when(() => cubit.state).thenReturn(PosCustomerLoaded(customers: []));
    when(() => cubit.selectedCustomer).thenReturn(null);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('"+" button is present when a customer is selected', (tester) async {
    const customer = PosCustomer(id: 'c2', name: 'Bob', phoneNumber: '555-0002');

    when(() => cubit.state).thenReturn(
      PosCustomerLoaded(customers: [customer], selectedCustomer: customer),
    );
    when(() => cubit.selectedCustomer).thenReturn(customer);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
