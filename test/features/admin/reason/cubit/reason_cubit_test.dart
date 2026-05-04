import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/reason/cubit/reason_cubit.dart';
import 'package:GoSystem/features/admin/reason/cubit/reason_state.dart';
import 'package:GoSystem/features/admin/reason/data/repositories/reason_repository.dart';
import 'package:GoSystem/features/admin/reason/model/reason_model.dart';

class MockReasonRepository extends Mock implements ReasonRepository {}

void main() {
  late MockReasonRepository mockRepo;

  setUp(() {
    mockRepo = MockReasonRepository();
  });

  ReasonModel sampleReason(String id) => ReasonModel.fromJson({
        'id': id,
        'reason': 'Reason $id',
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        '__v': 1,
      });

  group('ReasonCubit', () {
    blocTest<ReasonCubit, ReasonState>(
      'getReasons emits loading then success',
      build: () {
        when(() => mockRepo.getAllReasons()).thenAnswer((_) async => [sampleReason('r1')]);
        return ReasonCubit(mockRepo);
      },
      act: (c) => c.getReasons(),
      expect: () => [
        isA<GetReasonsLoading>(),
        isA<GetReasonsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllReasons()).called(1);
      },
    );

    blocTest<ReasonCubit, ReasonState>(
      'getReasons emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllReasons()).thenThrow(Exception('network'));
        return ReasonCubit(mockRepo);
      },
      act: (c) => c.getReasons(),
      expect: () => [
        isA<GetReasonsLoading>(),
        isA<GetReasonsError>(),
      ],
    );

    blocTest<ReasonCubit, ReasonState>(
      'createReason emits loading then success',
      build: () {
        when(() => mockRepo.createReason(any())).thenAnswer((_) async => {});
        when(() => mockRepo.getAllReasons()).thenAnswer((_) async => [sampleReason('r1')]);
        return ReasonCubit(mockRepo);
      },
      act: (c) => c.createReason(reason: 'New Reason'),
      expect: () => [
        isA<CreateReasonLoading>(),
        isA<CreateReasonSuccess>(),
        isA<GetReasonsLoading>(),
        isA<GetReasonsSuccess>(),
      ],
    );
  });
}
