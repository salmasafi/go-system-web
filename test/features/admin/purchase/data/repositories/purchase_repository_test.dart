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
          'payment_status': 'full',
          'status': 'received',
          'date': '2024-05-01T10:00:00Z',
          'created_at': '2024-05-01T10:00:00Z',
          'updated_at': '2024-05-01T10:00:00Z',
          'total': 500.0,
          'discount': 0.0,
          'shipping_cost': 0.0,
          'exchange_rate': 1.0,
          'receipt_img': '',
          'note': null,
          'version': 1,
          'supplier': {
            'id': 'sup-1',
            'company_name': 'Test Supplier',
            'username': '',
            'email': '',
            'phone_number': '',
            'address': '',
            'image': '',
            'city_id': '',
            'country_id': '',
            'version': 1,
          },
          'warehouse': {
            'id': 'wh-1',
            'name': 'Main WH',
            'address': '',
            'phone': '',
            'email': '',
            'number_of_products': 0,
            'stock_quantity': 0,
            'created_at': '2024-05-01T10:00:00Z',
            'updated_at': '2024-05-01T10:00:00Z',
            'version': 1,
            'is_online': false,
          },
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

      expect(result.purchases.full.length, 1);
      expect(result.purchases.full.first.id, 'pur-123');
      expect(result.purchases.full.first.supplier.companyName, 'Test Supplier');
    });
  });
}
