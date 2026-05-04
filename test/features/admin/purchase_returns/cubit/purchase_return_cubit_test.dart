import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/purchase_returns/cubit/purchase_return_cubit.dart';
import 'package:GoSystem/features/admin/purchase_returns/data/repositories/purchase_return_repository.dart';

class MockPurchaseReturnRepository extends Mock implements PurchaseReturnRepository {}

void main() {
  late MockPurchaseReturnRepository mockRepo;

  setUp(() {
    mockRepo = MockPurchaseReturnRepository();
  });

  group('PurchaseReturnCubit', () {
    blocTest<PurchaseReturnCubit, PurchaseReturnState>(
      'getReturns emits loading then success',
      build: () {
        when(() => mockRepo.getAllReturns()).thenAnswer((_) async => []);
        return PurchaseReturnCubit(mockRepo);
      },
      act: (c) => c.getReturns(),
      expect: () => [
        isA<GetReturnsLoading>(),
        isA<GetReturnsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllReturns()).called(1);
      },
    );

    blocTest<PurchaseReturnCubit, PurchaseReturnState>(
      'getReturns emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllReturns()).thenThrow(Exception('network'));
        return PurchaseReturnCubit(mockRepo);
      },
      act: (c) => c.getReturns(),
      expect: () => [
        isA<GetReturnsLoading>(),
        isA<GetReturnsError>(),
      ],
    );

    blocTest<PurchaseReturnCubit, PurchaseReturnState>(
      'searchPurchaseByReference emits success when found',
      build: () {
        when(() => mockRepo.getPurchaseByReference('REF-001')).thenAnswer((_) async => {'reference': 'REF-001'});
        return PurchaseReturnCubit(mockRepo);
      },
      act: (c) => c.searchPurchaseByReference('REF-001'),
      expect: () => [
        isA<SearchPurchaseLoading>(),
        isA<SearchPurchaseSuccess>(),
      ],
    );
  });
}
