import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/bank_account/data/repositories/bank_account_repository.dart';
import 'package:GoSystem/features/admin/bank_account/model/bank_account_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late BankAccountRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = BankAccountRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('BankAccountRepository Supabase Implementation Tests', () {
    test('getAllBankAccounts maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'bank-123',
          'name': 'Business Account',
          'current_balance': 1000.0,
          'account_type': 'checking',
          'currency': 'SAR',
          'is_active': true,
          'is_default': true
        }
      ];

      when(() => mockClient.from('bank_accounts')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);
      
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllBankAccounts();

      expect(result.first.id, 'bank-123');
      expect(result.first.currentBalance, 1000.0);
    });
  });
}
