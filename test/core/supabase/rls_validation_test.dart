import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late ProductRepository repository;
  late MockSupabaseClient mockClient;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    
    repository = ProductRepository();
    repository.enableSupabase();
  });

  group('RLS Validation Simulation Tests', () {
    test('Delete product fails when RLS denies permission', () async {
      // Simulate RLS error (403 Forbidden or custom error)
      final rlsError = PostgrestException(
        message: 'new row violates row-level security policy for table "products"',
        code: '42501',
      );

      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', '1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenThrow(rlsError);

      expect(
        () => repository.deleteProduct('1'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('security policy'))),
      );
    });

    test('Update product fails when user role is insufficient', () async {
      final rlsError = PostgrestException(
        message: 'permission denied for table products',
        code: '42501',
      );

      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', '1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenThrow(rlsError);

      expect(
        () => repository.updateProduct('1', {'name': 'New Name'}),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('permission denied'))),
      );
    });
  });
}
