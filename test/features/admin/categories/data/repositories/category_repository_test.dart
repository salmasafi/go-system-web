import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/categories/data/repositories/category_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late CategoryRepository repository;
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
    repository = CategoryRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('CategoryRepository Unit Tests', () {
    test('getAllCategories should return list of CategoryItem', () async {
      final mockData = [
        {
          'id': 'cat-1',
          'name': 'Electronics',
          'image': 'electronics.jpg',
          'product_quantity': 10,
          'created_at': '2024-01-01',
          'updated_at': '2024-01-01',
          'version': 1,
          'parent': null,
        },
        {
          'id': 'cat-2',
          'name': 'Phones',
          'image': 'phones.jpg',
          'product_quantity': 5,
          'created_at': '2024-01-02',
          'updated_at': '2024-01-02',
          'version': 1,
          'parent': {'id': 'cat-1', 'name': 'Electronics'},
        },
      ];

      when(() => mockClient.from('categories')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllCategories();

      expect(result.length, 2);
      expect(result[0].id, 'cat-1');
      expect(result[0].name, 'Electronics');
      expect(result[1].parentId, isNotNull);
      expect(result[1].parentId!.name, 'Electronics');
    });

    test('getCategoryById should return CategoryItem for existing id', () async {
      final mockData = {
        'id': 'cat-1',
        'name': 'Electronics',
        'image': 'electronics.jpg',
        'product_quantity': 10,
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        'version': 1,
        'parent': null,
      };

      when(() => mockClient.from('categories')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'cat-1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockData);
      });

      final result = await repository.getCategoryById('cat-1');

      expect(result, isNotNull);
      expect(result!.id, 'cat-1');
      expect(result.name, 'Electronics');
    });

    test('getCategoryById should return null for non-existent id', () async {
      when(() => mockClient.from('categories')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'non-existent')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(null);
      });

      final result = await repository.getCategoryById('non-existent');

      expect(result, isNull);
    });
  });
}
