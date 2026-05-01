import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/brands/data/repositories/brand_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late BrandRepository repository;
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
    repository = BrandRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('BrandRepository Unit Tests', () {
    test('getAllBrands should return list of Brands', () async {
      final mockData = [
        {
          'id': 'brand-1',
          'name': 'Nike',
          'ar_name': 'نايك',
          'logo': 'nike_logo.jpg',
          'created_at': '2024-01-01',
          'updated_at': '2024-01-01',
          'version': 1,
        },
        {
          'id': 'brand-2',
          'name': 'Adidas',
          'ar_name': 'أديداس',
          'logo': 'adidas_logo.jpg',
          'created_at': '2024-01-02',
          'updated_at': '2024-01-02',
          'version': 1,
        },
      ];

      when(() => mockClient.from('brands')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllBrands();

      expect(result.length, 2);
      expect(result[0].id, 'brand-1');
      expect(result[0].name, 'Nike');
      expect(result[0].arName, 'نايك');
      expect(result[1].name, 'Adidas');
    });

    test('getBrandById should return Brands for existing id', () async {
      final mockData = {
        'id': 'brand-1',
        'name': 'Nike',
        'ar_name': 'نايك',
        'logo': 'nike_logo.jpg',
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        'version': 1,
      };

      when(() => mockClient.from('brands')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'brand-1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockData);
      });

      final result = await repository.getBrandById('brand-1');

      expect(result, isNotNull);
      expect(result!.id, 'brand-1');
      expect(result.name, 'Nike');
      expect(result.arName, 'نايك');
    });

    test('getBrandById should return null for non-existent id', () async {
      when(() => mockClient.from('brands')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'non-existent')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(null);
      });

      final result = await repository.getBrandById('non-existent');

      expect(result, isNull);
    });
  });
}
