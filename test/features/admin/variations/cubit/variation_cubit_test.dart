import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/variations/cubit/variation_cubit.dart';
import 'package:GoSystem/features/admin/variations/data/repositories/variation_repository.dart';
import 'package:GoSystem/features/admin/variations/model/variation_model.dart';

class MockVariationRepository extends Mock implements VariationRepository {}

VariationModel sampleVariation(String id) => VariationModel.fromJson({
        'id': id,
        'name': 'Variation $id',
        'ar_name': 'تنويعة $id',
        'createdAt': '2024-01-01',
        'updatedAt': '2024-01-01',
        '__v': 1,
        'options': [],
      });

void main() {
  late MockVariationRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(sampleVariation('fallback'));
  });

  setUp(() {
    mockRepo = MockVariationRepository();
  });

  group('VariationCubit', () {
    blocTest<VariationCubit, VariationState>(
      'getAllVariations emits loading then success',
      build: () {
        when(() => mockRepo.getAllVariations()).thenAnswer((_) async => [sampleVariation('v1')]);
        return VariationCubit(mockRepo);
      },
      act: (c) => c.getAllVariations(),
      expect: () => [
        isA<GetVariationsLoading>(),
        isA<GetVariationsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllVariations()).called(1);
      },
    );

    blocTest<VariationCubit, VariationState>(
      'getAllVariations emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllVariations()).thenThrow(Exception('network'));
        return VariationCubit(mockRepo);
      },
      act: (c) => c.getAllVariations(),
      expect: () => [
        isA<GetVariationsLoading>(),
        isA<GetVariationsError>(),
      ],
    );

    blocTest<VariationCubit, VariationState>(
      'addVariation emits loading then success',
      build: () {
        when(() => mockRepo.createVariation(any())).thenAnswer((_) async => sampleVariation('new'));
        return VariationCubit(mockRepo);
      },
      act: (c) => c.addVariation(name: 'New Variation', arName: 'تنويعة جديدة', options: []),
      expect: () => [
        isA<CreateVariationLoading>(),
        isA<CreateVariationSuccess>(),
      ],
    );
  });
}
