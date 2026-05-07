import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/taxes/data/repositories/tax_repository.dart';
import 'package:GoSystem/features/admin/taxes/model/taxes_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<PostgrestMap> {}

void main() {
  late TaxRepository repository;
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
    repository = TaxRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('TaxRepository Unit Tests', () {
    test('getAllTaxes should return list of TaxModel', () async {
      final mockData = [
        {
          'id': 'tax-1',
          'name': 'VAT',
          'type': 'percentage',
          'status': true,
          'amount': 15.0,
          'created_at': '2024-01-01',
          'updated_at': '2024-01-01',
        },
        {
          'id': 'tax-2',
          'name': 'Service Tax',
          'type': 'fixed',
          'status': true,
          'amount': 5.0,
          'created_at': '2024-01-02',
          'updated_at': '2024-01-02',
        },
      ];

      when(() => mockClient.from('taxes')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllTaxes();

      expect(result.length, 2);
      expect(result[0].id, 'tax-1');
      expect(result[0].name, 'VAT');
      expect(result[0].type, 'percentage');
      expect(result[0].amount, 15.0);
    });

    test('createTax should return created TaxModel', () async {
      final tax = TaxModel(
        id: '',
        name: 'New Tax',
        type: 'percentage',
        status: true,
        amount: 10.0,
      );

      final mockData = {
        'id': 'tax-new',
        'name': 'New Tax',
        'type': 'percentage',
        'status': true,
        'amount': 10.0,
      };

      when(() => mockClient.from('taxes')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>);
        return callback(mockData);
      });

      final result = await repository.createTax(tax);

      expect(result.id, 'tax-new');
      expect(result.name, 'New Tax');
    });

    test('updateTax should return updated TaxModel', () async {
      final tax = TaxModel(
        id: 'tax-1',
        name: 'Updated VAT',
        type: 'percentage',
        status: true,
        amount: 15.0,
      );

      final mockData = {
        'id': 'tax-1',
        'name': 'Updated VAT',
        'type': 'percentage',
        'status': true,
        'amount': 15.0,
      };

      when(() => mockClient.from('taxes')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>);
        return callback(mockData);
      });

      final result = await repository.updateTax(tax);

      expect(result.name, 'Updated VAT');
    });

    test('deleteTax should return true on success', () async {
      when(() => mockClient.from('taxes')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => true);

      final result = await repository.deleteTax('tax-1');

      expect(result, true);
    });
  });
}
