import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/revenue/data/repositories/revenue_repository.dart';
import 'package:GoSystem/features/admin/revenue/model/revenue_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late RevenueRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = RevenueRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('RevenueRepository Supabase Implementation Tests', () {
    test('getAllRevenues maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'rev-123',
          'description': 'Consulting Fee',
          'amount': 500.0,
          'category_id': 'cat-1',
          'bank_account_id': 'bank-1',
          'date': '2024-05-01',
          'created_at': '2024-05-01T10:00:00Z',
          'status': 'approved'
        }
      ];

      when(() => mockClient.from('revenues')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);
      
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllRevenues();

      expect(result.first.id, 'rev-123');
      expect(result.first.amount, 500.0);
    });
  });
}
