import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/coupon/cubit/coupon_cubit.dart';
import 'package:GoSystem/features/admin/coupon/data/repositories/coupon_repository.dart';
import 'package:GoSystem/features/admin/coupon/model/coupon_model.dart';

class MockCouponRepository extends Mock implements CouponRepository {}

void main() {
  late MockCouponRepository mockRepo;

  setUp(() {
    mockRepo = MockCouponRepository();
  });

  CouponModel sampleCoupon(String id) => CouponModel.fromJson({
        'id': id,
        'coupon_code': 'COUPON$id',
        'type': 'fixed',
        'amount': 50.0,
        'minimum_amount': 100.0,
        'quantity': 10,
        'available': 5,
        'expired_date': '2024-12-31',
        'status': true,
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        '__v': 1,
      });

  group('CouponsCubit', () {
    blocTest<CouponsCubit, CouponsState>(
      'getCoupons emits loading then success',
      build: () {
        when(() => mockRepo.getAllCoupons()).thenAnswer((_) async => [sampleCoupon('c1')]);
        return CouponsCubit(mockRepo);
      },
      act: (c) => c.getCoupons(),
      expect: () => [
        isA<GetCouponsLoading>(),
        isA<GetCouponsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllCoupons()).called(1);
      },
    );

    blocTest<CouponsCubit, CouponsState>(
      'getCoupons emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllCoupons()).thenThrow(Exception('network'));
        return CouponsCubit(mockRepo);
      },
      act: (c) => c.getCoupons(),
      expect: () => [
        isA<GetCouponsLoading>(),
        isA<GetCouponsError>(),
      ],
    );

    blocTest<CouponsCubit, CouponsState>(
      'createCoupon emits loading then success',
      build: () {
        when(() => mockRepo.createCoupon(any(that: isA<CouponModel>()))).thenAnswer((_) async => sampleCoupon('new'));
        return CouponsCubit(mockRepo);
      },
      act: (c) => c.createCoupon(
        couponCode: 'NEWCODE',
        type: 'fixed',
        amount: 50.0,
        minimumAmount: 100.0,
        quantity: 10,
        expiredDate: '2024-12-31',
        available: 10,
      ),
      expect: () => [
        isA<CreateCouponLoading>(),
        isA<CreateCouponSuccess>(),
      ],
    );
  });
}
