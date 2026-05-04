import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/expense_admin/cubit/expense_admin_cubit.dart';
import 'package:GoSystem/features/admin/expense_admin/cubit/expense_admin_state.dart';
import 'package:GoSystem/features/admin/expences/data/repositories/expense_repository.dart';
import 'package:GoSystem/features/admin/expense_admin/model/expense_admin_model.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late MockExpenseRepository mockRepo;

  setUp(() {
    mockRepo = MockExpenseRepository();
  });

  ExpenseAdminModel sampleExpense(String id) => ExpenseAdminModel.fromJson({
        'id': id,
        'name': 'Expense $id',
        'amount': 100.0,
        'category_id': {'id': 'c1', 'name': 'Category'},
        'financial_account_id': {'id': 'f1', 'name': 'Account'},
        'note': 'Note',
        'created_at': '2024-01-01',
      });

  group('ExpenseAdminCubit', () {
    blocTest<ExpenseAdminCubit, ExpenseAdminState>(
      'getExpenses emits loading then success',
      build: () {
        when(() => mockRepo.getAllExpenses()).thenAnswer((_) async => [sampleExpense('e1')]);
        return ExpenseAdminCubit(mockRepo);
      },
      act: (c) => c.getExpenses(),
      expect: () => [
        isA<GetExpensesAdminLoading>(),
        isA<GetExpensesAdminSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllExpenses()).called(1);
      },
    );

    blocTest<ExpenseAdminCubit, ExpenseAdminState>(
      'getExpenses emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllExpenses()).thenThrow(Exception('network'));
        return ExpenseAdminCubit(mockRepo);
      },
      act: (c) => c.getExpenses(),
      expect: () => [
        isA<GetExpensesAdminLoading>(),
        isA<GetExpensesAdminError>(),
      ],
    );

    blocTest<ExpenseAdminCubit, ExpenseAdminState>(
      'createExpense emits loading then success',
      build: () {
        when(() => mockRepo.createExpense(
          name: any(named: 'name'),
          amount: any(named: 'amount'),
          categoryId: any(named: 'categoryId'),
          financialAccountId: any(named: 'financialAccountId'),
          note: any(named: 'note'),
        )).thenAnswer((_) async {});
        when(() => mockRepo.getAllExpenses()).thenAnswer((_) async => [sampleExpense('e1')]);
        return ExpenseAdminCubit(mockRepo);
      },
      act: (c) => c.createExpense(
        name: 'New Expense',
        amount: 100.0,
        categoryId: 'c1',
        financialAccountId: 'f1',
        note: 'Note',
      ),
      expect: () => [
        isA<CreateExpenseAdminLoading>(),
        isA<CreateExpenseAdminSuccess>(),
        isA<GetExpensesAdminLoading>(),
        isA<GetExpensesAdminSuccess>(),
      ],
    );
  });
}
