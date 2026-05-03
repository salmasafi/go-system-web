import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/discount/data/repositories/discount_repository.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<PostgrestMap> {}

void main() {
  late DiscountRepository repository;
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
    repository = DiscountRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('DiscountRepository Unit Tests', () {
    test('getAllDiscounts should return list of DiscountModel', () async {
      final mockData = [
        {
          'id': 'discount-1',
          'name': 'Summer Sale',
          'amount': 20.0,
          'type': 'percentage',
          'status': true,
          'created_at': '2024-01-01',
          'updated_at': '2024-01-01',
        },
        {
          'id': 'discount-2',
          'name': 'Fixed Discount',
          'amount': 50.0,
          'type': 'fixed',
          'status': true,
          'created_at': '2024-01-02',
          'updated_at': '2024-01-02',
        },
      ];

      when(() => mockClient.from('discounts')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllDiscounts();

      expect(result.length, 2);
      expect(result[0].id, 'discount-1');
      expect(result[0].name, 'Summer Sale');
      expect(result[0].type, 'percentage');
      expect(result[0].amount, 20.0);
    });

    test('createDiscount should return created DiscountModel', () async {
      final discount = DiscountModel(
        id: '',
        name: 'New Discount',
        amount: 15.0,
        type: 'percentage',
        status: true,
        createdAt: '',
        updatedAt: '',
        version: 0,
      );

      final mockData = {
        'id': 'discount-new',
        'name': 'New Discount',
        'amount': 15.0,
        'type': 'percentage',
        'status': true,
        'created_at': '2024-01-03',
        'updated_at': '2024-01-03',
      };

      when(() => mockClient.from('discounts')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>);
        return callback(mockData);
      });

      final result = await repository.createDiscount(discount);

      expect(result.id, 'discount-new');
      expect(result.name, 'New Discount');
    });

    test('updateDiscount should return updated DiscountModel', () async {
      final discount = DiscountModel(
        id: 'discount-1',
        name: 'Updated Discount',
        amount: 25.0,
        type: 'percentage',
        status: true,
        createdAt: '',
        updatedAt: '',
        version: 0,
      );

      final mockData = {
        'id': 'discount-1',
        'name': 'Updated Discount',
        'amount': 25.0,
        'type': 'percentage',
        'status': true,
        'created_at': '2024-01-01',
        'updated_at': '2024-01-03',
      };

      when(() => mockClient.from('discounts')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>);
        return callback(mockData);
      });

      final result = await repository.updateDiscount(discount);

      expect(result.name, 'Updated Discount');
      expect(result.amount, 25.0);
    });

    test('deleteDiscount should return true on success', () async {
      when(() => mockClient.from('discounts')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      final result = await repository.deleteDiscount('discount-1');

      expect(result, true);
    });
  });
}
