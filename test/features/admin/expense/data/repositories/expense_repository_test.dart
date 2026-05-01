import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/expences/data/repositories/expense_repository.dart';
import 'package:GoSystem/features/admin/expense/data/repositories/expense_repository.dart';
import 'package:GoSystem/features/admin/expense/model/expense_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late ExpenseRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = ExpenseRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('ExpenseRepository Supabase Implementation Tests', () {
    test('getAllExpenses maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'exp-123',
          'description': 'Office Supplies',
          'amount': 50.0,
          'category_id': 'cat-1',
          'bank_account_id': 'bank-1',
          'date': '2024-05-01',
          'created_at': '2024-05-01T10:00:00Z',
          'status': 'approved',
        },
      ];

      when(() => mockClient.from('expenses')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(
        () =>
            mockFilterBuilder.order(any(), ascending: any(named: 'ascending')),
      ).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback =
            invocation.positionalArguments[0]
                as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllExpenses();

      expect(result.first.id, 'exp-123');
      expect(result.first.amount, 50.0);
    });
  });
}
