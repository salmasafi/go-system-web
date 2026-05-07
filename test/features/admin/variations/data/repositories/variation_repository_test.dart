import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/variations/data/repositories/variation_repository.dart';
import 'package:GoSystem/features/admin/variations/model/variation_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late VariationRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = VariationRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('VariationRepository Unit Tests', () {
    test('getAllVariations should return list of VariationModel', () async {
      final mockData = [
        {
          'id': 'var-1',
          'name': 'Size',
          'created_at': '2024-01-01',
          'updated_at': '2024-01-01',
          'options': [
            {'id': 'opt-1', 'variation_id': 'var-1', 'name': 'Small', 'status': true},
            {'id': 'opt-2', 'variation_id': 'var-1', 'name': 'Large', 'status': true},
          ],
        },
        {
          'id': 'var-2',
          'name': 'Color',
          'created_at': '2024-01-02',
          'updated_at': '2024-01-02',
          'options': [
            {'id': 'opt-3', 'variation_id': 'var-2', 'name': 'Red', 'status': true},
          ],
        },
      ];

      when(() => mockClient.from('variations')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllVariations();

      expect(result.length, 2);
      expect(result[0].id, 'var-1');
      expect(result[0].name, 'Size');
      expect(result[0].options.length, 2);
    });

    test('deleteVariation should return true on success', () async {
      when(() => mockClient.from('variations')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      final result = await repository.deleteVariation('var-1');

      expect(result, true);
    });
  });
}
