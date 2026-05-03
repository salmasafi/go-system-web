import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/coupon/data/repositories/coupon_repository.dart';
import 'package:GoSystem/features/admin/coupon/model/coupon_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<PostgrestMap> {}

void main() {
  late CouponRepository repository;
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
    repository = CouponRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('CouponRepository Unit Tests', () {
    test('getAllCoupons should return list of CouponModel', () async {
      final mockData = [
        {
          'id': 'coupon-1',
          'code': 'SUMMER20',
          'name': 'Summer Sale',
          'discount_type': 'percentage',
          'discount_value': 20.0,
          'min_purchase': 100.0,
          'usage_limit': 100,
          'usage_count': 0,
          'end_date': '2024-12-31',
          'status': true,
        },
        {
          'id': 'coupon-2',
          'code': 'WELCOME50',
          'name': 'Welcome Discount',
          'discount_type': 'fixed',
          'discount_value': 50.0,
          'min_purchase': 200.0,
          'usage_limit': 50,
          'usage_count': 10,
          'end_date': '2024-12-31',
          'status': true,
        },
      ];

      when(() => mockClient.from('coupons')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllCoupons();

      expect(result.length, 2);
      expect(result[0].id, 'coupon-1');
      expect(result[0].couponCode, 'SUMMER20');
      expect(result[0].amount, 20.0);
    });

    test('validateCoupon should return CouponModel for valid coupon', () async {
      final mockData = {
        'id': 'coupon-1',
        'code': 'SUMMER20',
        'name': 'Summer Sale',
        'discount_type': 'percentage',
        'discount_value': 20.0,
        'min_purchase': 100.0,
        'usage_limit': 100,
        'usage_count': 0,
        'end_date': '2025-12-31',
        'status': true,
        'is_active': true,
      };

      when(() => mockClient.from('coupons')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('code', 'SUMMER20')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('status', true)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.gte(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockData);
      });

      final result = await repository.validateCoupon('SUMMER20');

      expect(result, isNotNull);
      expect(result!.couponCode, 'SUMMER20');
      expect(result.amount, 20.0);
    });

    test('validateCoupon should return null for invalid coupon', () async {
      when(() => mockClient.from('coupons')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('code', 'INVALID')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('status', true)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.gte(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(null);
      });

      final result = await repository.validateCoupon('INVALID');

      expect(result, isNull);
    });

    test('createCoupon should return created CouponModel', () async {
      final coupon = CouponModel(
        id: '',
        couponCode: 'NEWCOUPON',
        type: 'percentage',
        amount: 15.0,
        minimumAmount: 50.0,
        quantity: 100,
        available: 100,
        expiredDate: '2024-12-31',
        status: true,
        createdAt: '',
        updatedAt: '',
        version: 0,
      );

      final mockData = {
        'id': 'coupon-new',
        'code': 'NEWCOUPON',
        'name': 'NEWCOUPON',
        'discount_type': 'percentage',
        'discount_value': 15.0,
        'min_purchase': 50.0,
        'usage_limit': 100,
        'usage_count': 0,
        'end_date': '2024-12-31',
        'status': true,
      };

      when(() => mockClient.from('coupons')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>);
        return callback(mockData);
      });

      final result = await repository.createCoupon(coupon);

      expect(result.id, 'coupon-new');
      expect(result.couponCode, 'NEWCOUPON');
    });

    test('deleteCoupon should return true on success', () async {
      when(() => mockClient.from('coupons')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      final result = await repository.deleteCoupon('coupon-1');

      expect(result, true);
    });
  });
}
