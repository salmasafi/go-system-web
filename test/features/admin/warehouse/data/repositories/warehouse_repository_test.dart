import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/warehouse/data/repositories/warehouse_repository.dart';
import 'package:GoSystem/features/admin/warehouse/model/warehouse_model.dart';
import 'package:GoSystem/features/admin/warehouses/data/repositories/warehouse_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late WarehouseRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = WarehouseRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('WarehouseRepository Supabase Implementation Tests', () {
    test('getAllWarehouses maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'wh-123',
          'name': 'Main Warehouse',
          'phone': '12345',
          'email': 'wh@example.com',
          'address': 'Street 1',
          'is_active': true,
        },
      ];

      when(() => mockClient.from('warehouses')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback =
            invocation.positionalArguments[0]
                as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllWarehouses();

      expect(result.first.id, 'wh-123');
      expect(result.first.name, 'Main Warehouse');
    });
  });
}
