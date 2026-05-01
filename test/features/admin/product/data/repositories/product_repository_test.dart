import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late ProductRepository repository;
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
    repository = ProductRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('ProductRepository Supabase Implementation Tests', () {
    test('getAllProducts maps Supabase JSON with nested objects correctly', () async {
      final mockData = [
        {
          'id': 'prod-123',
          'name': 'Test Product',
          'ar_name': 'منتج تجريبي',
          'price': 100.0,
          'quantity': 10,
          'image': 'test.jpg',
          'unit': 'pcs',
          'categories': [
            {
              'category': {'id': 'cat-1', 'name': 'Electronics'}
            }
          ],
          'brand': {'id': 'brand-1', 'name': 'Sony'},
          'prices': []
        }
      ];

      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);
      
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllProducts();

      expect(result.first.id, 'prod-123');
      expect(result.first.categoryId.first.name, 'Electronics');
      expect(result.first.brandId.name, 'Sony');
    });

    test('getProductById handles null response correctly', () async {
      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'non-existent')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);
      
      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(null);
      });

      final result = await repository.getProductById('non-existent');

      expect(result, isNull);
    });
  });
}
