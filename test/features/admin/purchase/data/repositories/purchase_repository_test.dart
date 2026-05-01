import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/purchase/data/repositories/purchase_repository.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late PurchaseRepository repository;
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
    repository = PurchaseRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('PurchaseRepository Supabase Implementation Tests', () {
    test('getAllPurchases maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'pur-123',
          'reference': 'PUR-001',
          'grand_total': 500.0,
          'status': 'received',
          'created_at': '2024-05-01T10:00:00Z',
          'supplier': {'id': 'sup-1', 'name': 'Test Supplier'},
          'warehouse': {'id': 'wh-1', 'name': 'Main WH'}
        }
      ];

      when(() => mockClient.from('purchases')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);
      
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllPurchases();

      expect(result.first.id, 'pur-123');
      expect(result.first.supplierName, 'Test Supplier');
    });
  });
}
