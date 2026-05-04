import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/points/cubit/points_cubit.dart';
import 'package:GoSystem/features/admin/points/cubit/points_state.dart';
import 'package:GoSystem/features/admin/points/data/repositories/points_repository.dart';
import 'package:GoSystem/features/admin/points/model/points_model.dart';

class MockPointsRepository extends Mock implements PointsRepository {}

PointsModel samplePoints(String id) => PointsModel.fromJson({
      'id': id,
      'amount': 100.0,
      'points': 10,
      'created_at': '2024-01-01',
    });

void main() {
  late MockPointsRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(samplePoints('fallback'));
  });

  setUp(() {
    mockRepo = MockPointsRepository();
  });

  group('PointsCubit', () {
    blocTest<PointsCubit, PointsState>(
      'getPoints emits loading then success',
      build: () {
        when(() => mockRepo.getPointsRules()).thenAnswer((_) async => [samplePoints('p1')]);
        return PointsCubit(mockRepo);
      },
      act: (c) => c.getPoints(),
      expect: () => [
        isA<GetPointsLoading>(),
        isA<GetPointsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getPointsRules()).called(1);
      },
    );

    blocTest<PointsCubit, PointsState>(
      'getPoints emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getPointsRules()).thenThrow(Exception('network'));
        return PointsCubit(mockRepo);
      },
      act: (c) => c.getPoints(),
      expect: () => [
        isA<GetPointsLoading>(),
        isA<GetPointsError>(),
      ],
    );

    blocTest<PointsCubit, PointsState>(
      'createPoints emits loading then success',
      build: () {
        when(() => mockRepo.createPointsRule(any())).thenAnswer((_) async => samplePoints('new'));
        when(() => mockRepo.getPointsRules()).thenAnswer((_) async => [samplePoints('p1')]);
        return PointsCubit(mockRepo);
      },
      act: (c) => c.createPoints(amount: 100.0, points: 10),
      expect: () => [
        isA<CreatePointsLoading>(),
        isA<CreatePointsSuccess>(),
        isA<GetPointsLoading>(),
        isA<GetPointsSuccess>(),
      ],
    );
  });
}
