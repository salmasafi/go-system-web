import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/customer/data/repositories/customer_repository.dart';
import 'package:GoSystem/features/admin/customer/model/customer_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late CustomerRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = CustomerRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('CustomerRepository Supabase Implementation Tests', () {
    test('getAllCustomers maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'cust-123',
          'name': 'Test Customer',
          'phone_number': '123456789',
          'email': 'test@example.com',
          'country': {'id': 'country-1', 'name': 'Saudi Arabia'},
          'city': {'id': 'city-1', 'name': 'Riyadh'},
          'customer_group': {'id': 'group-1', 'name': 'VIP'}
        }
      ];

      when(() => mockClient.from('customers')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllCustomers();

      expect(result.first.id, 'cust-123');
      expect(result.first.country?.name, 'Saudi Arabia');
    });
  });
}
