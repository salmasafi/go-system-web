import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:GoSystem/features/admin/purchase/data/repositories/purchase_repository.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  late MockPurchaseRepository mockRepo;

  setUp(() {
    mockRepo = MockPurchaseRepository();
  });

  PurchaseData samplePurchaseData() => PurchaseData.fromJson({
        'stats': {
          'total_purchases': 1,
          'full_count': 1,
          'later_count': 0,
          'partial_count': 0,
          'total_amount': 1000,
          'full_amount': 1000,
          'later_amount': 0,
          'partial_amount': 0,
        },
        'purchases': {
          'full': [],
          'later': [],
          'partial': [],
        },
      });

  group('PurchaseCubit', () {
    blocTest<PurchaseCubit, PurchaseState>(
      'getAllPurchases emits loading then success',
      build: () {
        when(() => mockRepo.getAllPurchases()).thenAnswer((_) async => samplePurchaseData());
        return PurchaseCubit(mockRepo);
      },
      act: (c) => c.getAllPurchases(),
      expect: () => [
        isA<GetPurchasesLoading>(),
        isA<GetPurchasesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllPurchases()).called(1);
      },
    );

    blocTest<PurchaseCubit, PurchaseState>(
      'getAllPurchases emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllPurchases()).thenThrow(Exception('network'));
        return PurchaseCubit(mockRepo);
      },
      act: (c) => c.getAllPurchases(),
      expect: () => [
        isA<GetPurchasesLoading>(),
        isA<GetPurchasesError>(),
      ],
    );
  });
}
