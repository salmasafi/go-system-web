import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/adjustment/cubit/adjustment_cubit.dart';
import 'package:GoSystem/features/admin/adjustment/cubit/adjustment_state.dart';
import 'package:GoSystem/features/admin/adjustment/data/repositories/adjustment_repository.dart';

class MockAdjustmentRepository extends Mock implements AdjustmentRepository {}

void main() {
  late MockAdjustmentRepository mockRepo;

  SupabaseAdjustmentModel sampleModel() => SupabaseAdjustmentModel(
        id: 'a1',
        reference: 'REF-1',
        warehouseId: 'w1',
        type: 'increase',
        reason: 'r1',
        totalAmount: 10,
        status: 'completed',
        note: 'n',
        createdAt: DateTime.utc(2024, 1, 1),
        items: [
          SupabaseAdjustmentItem(
            id: 'i1',
            adjustmentId: 'a1',
            productId: 'p1',
            quantity: 2,
            currentStock: 5,
            newStock: 7,
            unitCost: 1,
            totalCost: 2,
          ),
        ],
      );

  setUpAll(() {
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  setUp(() {
    mockRepo = MockAdjustmentRepository();
    AdjustmentCubit.adjustments = [];
    AdjustmentCubit.reasons = [];
  });

  group('AdjustmentCubit', () {
    blocTest<AdjustmentCubit, AdjustmentState>(
      'getAdjustments emits loading then success',
      build: () {
        when(() => mockRepo.getAllAdjustments()).thenAnswer(
          (_) async => [sampleModel()],
        );
        return AdjustmentCubit(mockRepo);
      },
      act: (c) => c.getAdjustments(),
      expect: () => [
        isA<GetAdjustmentsLoading>(),
        isA<GetAdjustmentsSuccess>(),
      ],
    );

    blocTest<AdjustmentCubit, AdjustmentState>(
      'getAdjustments emits error when repository throws',
      build: () {
        when(() => mockRepo.getAllAdjustments()).thenThrow(Exception('db'));
        return AdjustmentCubit(mockRepo);
      },
      act: (c) => c.getAdjustments(),
      expect: () => [
        isA<GetAdjustmentsLoading>(),
        isA<GetAdjustmentsError>(),
      ],
    );

    blocTest<AdjustmentCubit, AdjustmentState>(
      'createAdjustment emits success',
      build: () {
        when(
          () => mockRepo.createAdjustment(
            warehouseId: 'w1',
            type: 'addition',
            reason: 'r1',
            items: [
              {'product_id': 'p1', 'quantity': 2},
            ],
            note: 'n',
            attachmentFile: null,
          ),
        ).thenAnswer((_) async => sampleModel());
        return AdjustmentCubit(mockRepo);
      },
      act: (c) => c.createAdjustment(
        warehouseId: 'w1',
        productId: 'p1',
        quantity: '2',
        reasonId: 'r1',
        note: 'n',
        image: null,
      ),
      expect: () => [
        isA<CreateAdjustmentLoading>(),
        isA<CreateAdjustmentSuccess>(),
      ],
    );

    blocTest<AdjustmentCubit, AdjustmentState>(
      'deleteAdjustment emits success when reverseAdjustment returns true',
      build: () {
        AdjustmentCubit.adjustments = [sampleModel().toLegacyModel()];
        when(() => mockRepo.reverseAdjustment('a1')).thenAnswer((_) async => true);
        return AdjustmentCubit(mockRepo);
      },
      act: (c) => c.deleteAdjustment('a1'),
      expect: () => [
        isA<DeleteAdjustmentLoading>(),
        isA<DeleteAdjustmentSuccess>(),
      ],
    );
  });
}