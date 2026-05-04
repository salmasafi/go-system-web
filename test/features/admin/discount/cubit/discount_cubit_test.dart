import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/discount/cubit/discount_cubit.dart';
import 'package:GoSystem/features/admin/discount/data/repositories/discount_repository.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';

class MockDiscountRepository extends Mock implements DiscountRepository {}

DiscountModel sampleDiscount(String id) => DiscountModel.fromJson({
      '_id': id,
      'name': 'Discount $id',
      'amount': 10.0,
      'type': 'fixed',
      'status': true,
      'createdAt': '2024-01-01',
      'updatedAt': '2024-01-01',
      '__v': 1,
    });

void main() {
  late MockDiscountRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(sampleDiscount('fallback'));
  });

  setUp(() {
    mockRepo = MockDiscountRepository();
  });

  group('DiscountsCubit', () {
    blocTest<DiscountsCubit, DiscountsState>(
      'getDiscounts emits loading then success',
      build: () {
        when(() => mockRepo.getAllDiscounts()).thenAnswer((_) async => [sampleDiscount('d1')]);
        return DiscountsCubit(mockRepo);
      },
      act: (c) => c.getDiscounts(),
      expect: () => [
        isA<GetDiscountsLoading>(),
        isA<GetDiscountsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllDiscounts()).called(1);
      },
    );

    blocTest<DiscountsCubit, DiscountsState>(
      'getDiscounts emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllDiscounts()).thenThrow(Exception('network'));
        return DiscountsCubit(mockRepo);
      },
      act: (c) => c.getDiscounts(),
      expect: () => [
        isA<GetDiscountsLoading>(),
        isA<GetDiscountsError>(),
      ],
    );

    blocTest<DiscountsCubit, DiscountsState>(
      'createDiscount emits loading then success',
      build: () {
        when(() => mockRepo.createDiscount(any())).thenAnswer((_) async => sampleDiscount('new'));
        return DiscountsCubit(mockRepo);
      },
      act: (c) => c.createDiscount(
        name: 'New Discount',
        type: 'fixed',
        amount: 50.0,
        status: true,
      ),
      expect: () => [
        isA<CreateDiscountLoading>(),
        isA<CreateDiscountSuccess>(),
      ],
    );
  });
}
