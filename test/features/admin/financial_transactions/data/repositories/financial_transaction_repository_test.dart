import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/financial_transactions/data/repositories/financial_transaction_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestBuilder extends Mock implements PostgrestBuilder<Map<String, dynamic>> {}

void main() {
  late FinancialTransactionRepository repository;
  late MockSupabaseClient mockClient;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    
    // We need to enable Supabase for the repository to use the Supabase data source
    repository = FinancialTransactionRepository();
    repository.enableSupabase();
  });

  group('FinancialTransactionRepository Supabase Tests', () {
    test('getAllTransactions returns list of transactions', () async {
      final mockData = [
        {
          'id': '1',
          'reference': 'REF-1',
          'transaction_type': 'expense',
          'bank_account_id': 'acc-1',
          'amount': 100.0,
          'previous_balance': 500.0,
          'new_balance': 400.0,
          'date': '2026-05-01T10:00:00Z',
          'created_at': '2026-05-01T10:00:00Z'
        }
      ];

      when(() => mockClient.from('financial_transactions')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false))
          .thenAnswer((_) async => mockData);

      final result = await repository.getAllTransactions();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.amount, 100.0);
    });

    test('getTransactionsByAccount returns filtered list', () async {
      final mockData = [
        {
          'id': '1',
          'bank_account_id': 'acc-1',
          'amount': 100.0,
          'transaction_type': 'revenue',
          'previous_balance': 400.0,
          'new_balance': 500.0,
          'date': '2026-05-01T10:00:00Z',
          'created_at': '2026-05-01T10:00:00Z'
        }
      ];

      when(() => mockClient.from('financial_transactions')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('bank_account_id', 'acc-1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false))
          .thenAnswer((_) async => mockData);

      final result = await repository.getTransactionsByAccount('acc-1');

      expect(result.length, 1);
      expect(result.first.bankAccountId, 'acc-1');
    });

    test('createTransaction inserts new transaction', () async {
      final mockResponse = {
        'id': 'new-id',
        'reference': 'TXN-123',
        'transaction_type': 'expense',
        'bank_account_id': 'acc-1',
        'amount': 50.0,
        'previous_balance': 500.0,
        'new_balance': 450.0,
        'date': '2026-05-01T10:00:00Z',
        'created_at': '2026-05-01T10:00:00Z'
      };

      when(() => mockClient.from('financial_transactions')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockTransformBuilder);
      when(() => mockTransformBuilder.single()).thenAnswer((_) async => mockResponse);

      final result = await repository.createTransaction(
        transactionType: 'expense',
        bankAccountId: 'acc-1',
        amount: 50.0,
        previousBalance: 500.0,
        newBalance: 450.0,
        description: 'Test transaction',
      );

      expect(result.id, 'new-id');
      expect(result.amount, 50.0);
      verify(() => mockQueryBuilder.insert(any(that: isA<Map<String, dynamic>>()))).called(1);
    });
  });
}
