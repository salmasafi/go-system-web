import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/sales/data/repositories/sale_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}
class MockPostgrestFilterBuilderAny extends Mock implements PostgrestFilterBuilder<dynamic> {}

void main() {
  late SaleRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;
  late MockPostgrestFilterBuilderAny mockRPCBuilder;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    mockRPCBuilder = MockPostgrestFilterBuilderAny();
    
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = SaleRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('SaleRepository Supabase Implementation Tests', () {
    test('getAllSales maps Supabase JSON to SaleItemModel list', () async {
      final mockData = [
        {
          'id': 'sale-123',
          'reference': 'REF-001',
          'grand_total': 150.5,
          'sale_status': 'completed',
          'created_at': '2024-05-01T10:00:00Z',
          'customer': {'name': 'Test Customer'}
        }
      ];

      when(() => mockClient.from('sales')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);
      
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllSales();

      expect(result.first.id, 'sale-123');
      expect(result.first.customerName, 'Test Customer');
    });

    test('getSaleById returns SaleDetailModel when found', () async {
      final mockSale = {
        'id': 'sale-123',
        'reference': 'REF-001',
        'customer_id': 'cust-1',
        'warehouse_id': 'wh-1',
        'grand_total': 200.0,
        'tax_amount': 10.0,
        'discount': 5.0,
        'customer': {'id': 'cust-1', 'name': 'John Doe'},
        'warehouse': {'id': 'wh-1', 'name': 'Main Warehouse'},
        'items': []
      };

      when(() => mockClient.from('sales')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'sale-123')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);
      
      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockSale);
      });

      final result = await repository.getSaleById('sale-123');

      expect(result, isNotNull);
      expect(result!.id, 'sale-123');
    });

    test('payDue calls pay_sale_due RPC', () async {
      when(() => mockClient.rpc('pay_sale_due', params: any(named: 'params')))
          .thenReturn(mockRPCBuilder);
      
      when(() => mockRPCBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(dynamic);
        return callback(true);
      });

      final result = await repository.payDue(
        'sale-123',
        'cust-456',
        50.0,
        [{'account_id': 'bank-1', 'amount': 50.0}],
      );

      expect(result, isTrue);
      verify(() => mockClient.rpc('pay_sale_due', params: any(named: 'params'))).called(1);
    });
  });
}
