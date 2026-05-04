import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/redeem_points/cubit/redeem_points_cubit.dart';
import 'package:GoSystem/features/admin/redeem_points/data/repositories/redeem_points_repository.dart';
import 'package:GoSystem/features/admin/redeem_points/model/redeem_points_model.dart';

class MockRedeemPointsRepository extends Mock implements RedeemPointsRepository {}

RedeemPointsModel sampleRedeemPoints(String id) => RedeemPointsModel(
      id: id,
      amount: 100.0,
      points: 10,
    );

void main() {
  late MockRedeemPointsRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(sampleRedeemPoints('fallback'));
  });

  setUp(() {
    mockRepo = MockRedeemPointsRepository();
  });

  group('RedeemPointsCubit', () {
    blocTest<RedeemPointsCubit, RedeemPointsState>(
      'getRedeemPoints emits loading then success',
      build: () {
        when(() => mockRepo.getRedeemRules()).thenAnswer((_) async => [sampleRedeemPoints('r1')]);
        return RedeemPointsCubit(mockRepo);
      },
      act: (c) => c.getRedeemPoints(),
      expect: () => [
        isA<GetRedeemPointsLoading>(),
        isA<GetRedeemPointsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getRedeemRules()).called(1);
      },
    );

    blocTest<RedeemPointsCubit, RedeemPointsState>(
      'getRedeemPoints emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getRedeemRules()).thenThrow(Exception('network'));
        return RedeemPointsCubit(mockRepo);
      },
      act: (c) => c.getRedeemPoints(),
      expect: () => [
        isA<GetRedeemPointsLoading>(),
        isA<GetRedeemPointsError>(),
      ],
    );

    blocTest<RedeemPointsCubit, RedeemPointsState>(
      'createRedeemPoints emits loading then success',
      build: () {
        when(() => mockRepo.createRedeemRule(any())).thenAnswer((_) async => sampleRedeemPoints('new'));
        when(() => mockRepo.getRedeemRules()).thenAnswer((_) async => [sampleRedeemPoints('r1')]);
        return RedeemPointsCubit(mockRepo);
      },
      act: (c) => c.createRedeemPoints(amount: 100.0, points: 10),
      expect: () => [
        isA<CreateRedeemPointsLoading>(),
        isA<GetRedeemPointsLoading>(),
        isA<GetRedeemPointsSuccess>(),
        isA<CreateRedeemPointsSuccess>(),
      ],
    );
  });
}
