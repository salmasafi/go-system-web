import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/brands/cubit/brand_cubit.dart';
import 'package:GoSystem/features/admin/brands/cubit/brand_states.dart';
import 'package:GoSystem/features/admin/brands/data/repositories/brand_repository.dart';
import 'package:GoSystem/features/admin/brands/model/get_brands_model.dart';

class MockBrandRepository extends Mock implements BrandRepository {}

void main() {
  late MockBrandRepository mockRepo;

  setUp(() {
    mockRepo = MockBrandRepository();
  });

  Brands sampleBrand(String id) => Brands.fromJson({
        'id': id,
        'name': 'Nike',
        'ar_name': 'nike_ar',
        'logo': '',
        'created_at': '',
        'updated_at': '',
        'version': 1,
      });

  group('BrandsCubit', () {
    blocTest<BrandsCubit, BrandsState>(
      'getBrands emits loading then success',
      build: () {
        when(() => mockRepo.getAllBrands()).thenAnswer((_) async => [sampleBrand('b1')]);
        return BrandsCubit(mockRepo);
      },
      act: (c) => c.getBrands(),
      expect: () => [
        isA<GetBrandsLoading>(),
        isA<GetBrandsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllBrands()).called(1);
      },
    );

    blocTest<BrandsCubit, BrandsState>(
      'getBrands emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllBrands()).thenThrow(Exception('network'));
        return BrandsCubit(mockRepo);
      },
      act: (c) => c.getBrands(),
      expect: () => [
        isA<GetBrandsLoading>(),
        isA<GetBrandsError>(),
      ],
    );

    blocTest<BrandsCubit, BrandsState>(
      'getBrandById emits success when brand exists',
      build: () {
        when(() => mockRepo.getBrandById('b1')).thenAnswer((_) async => sampleBrand('b1'));
        return BrandsCubit(mockRepo);
      },
      act: (c) => c.getBrandById('b1'),
      expect: () => [
        isA<GetBrandByIdLoading>(),
        isA<GetBrandByIdSuccess>(),
      ],
    );

    blocTest<BrandsCubit, BrandsState>(
      'getBrandById emits error when brand missing',
      build: () {
        when(() => mockRepo.getBrandById('x')).thenAnswer((_) async => null);
        return BrandsCubit(mockRepo);
      },
      act: (c) => c.getBrandById('x'),
      expect: () => [
        isA<GetBrandByIdLoading>(),
        isA<GetBrandByIdError>(),
      ],
    );
  });
}