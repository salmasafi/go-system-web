import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/pandel/data/repositories/bundle_repository.dart';
import 'package:GoSystem/features/admin/pandel/model/pandel_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late BundleRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = BundleRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('BundleRepository Unit Tests', () {
    test('getAllBundles should return list of PandelModel', () async {
      final mockData = [
        {
          'id': 'bundle-1',
          'name': 'Summer Bundle',
          'start_date': '2024-06-01',
          'end_date': '2024-08-31',
          'status': true,
          'price': 299.99,
          'all_warehouses': true,
          'images': ['image1.jpg'],
          'created_at': '2024-01-01',
          'updated_at': '2024-01-01',
          'bundle_products': [],
          'bundle_warehouses': [],
        },
      ];

      when(() => mockClient.from('bundles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllBundles();

      expect(result.length, 1);
      expect(result[0].id, 'bundle-1');
      expect(result[0].name, 'Summer Bundle');
      expect(result[0].price, 299.99);
    });

    test('deleteBundle should return true on success', () async {
      when(() => mockClient.from('bundles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      final result = await repository.deleteBundle('bundle-1');

      expect(result, true);
    });
  });
}
