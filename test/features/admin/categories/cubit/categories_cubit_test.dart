import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/categories/cubit/categories_cubit.dart';
import 'package:GoSystem/features/admin/categories/cubit/categories_states.dart';
import 'package:GoSystem/features/admin/categories/data/repositories/category_repository.dart';
import 'package:GoSystem/features/admin/categories/model/get_categories_model.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository mockRepo;

  setUp(() {
    mockRepo = MockCategoryRepository();
  });

  CategoryItem sampleCategory(String id, {String? parentId}) => CategoryItem.fromJson({
        'id': id,
        'name': 'Category $id',
        'ar_name': 'فئة $id',
        'image': 'cat_$id.jpg',
        'product_quantity': 10,
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        'version': 1,
        if (parentId != null) 'parent': {'id': parentId, 'name': 'Parent', 'ar_name': 'أب'},
      });

  group('CategoriesCubit', () {
    blocTest<CategoriesCubit, CategoriesState>(
      'getCategories emits loading then success',
      build: () {
        when(() => mockRepo.getAllCategories()).thenAnswer((_) async => [sampleCategory('cat1')]);
        return CategoriesCubit(mockRepo);
      },
      act: (c) => c.getCategories(),
      expect: () => [
        isA<GetCategoriesLoading>(),
        isA<GetCategoriesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllCategories()).called(1);
      },
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'getCategories emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllCategories()).thenThrow(Exception('network'));
        return CategoriesCubit(mockRepo);
      },
      act: (c) => c.getCategories(),
      expect: () => [
        isA<GetCategoriesLoading>(),
        isA<GetCategoriesError>(),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'getCategoryById emits success when category exists',
      build: () {
        final category = sampleCategory('cat1');
        when(() => mockRepo.getCategoryById('cat1')).thenAnswer((_) async => category);
        return CategoriesCubit(mockRepo);
      },
      act: (c) => c.getCategoryById('cat1'),
      expect: () => [
        isA<GetCategoryByIdLoading>(),
        isA<GetCategoryByIdSuccess>(),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'getCategoryById emits error when category not found',
      build: () {
        when(() => mockRepo.getCategoryById('x')).thenAnswer((_) async => null);
        return CategoriesCubit(mockRepo);
      },
      act: (c) => c.getCategoryById('x'),
      expect: () => [
        isA<GetCategoryByIdLoading>(),
        isA<GetCategoryByIdError>(),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'createCategory emits loading then success',
      build: () {
        when(() => mockRepo.createCategory(
          name: any(named: 'name'),
          arName: any(named: 'arName'),
          parentId: any(named: 'parentId'),
          imageFile: any(named: 'imageFile'),
        )).thenAnswer((_) async => sampleCategory('new'));
        when(() => mockRepo.getAllCategories()).thenAnswer((_) async => [sampleCategory('cat1')]);
        return CategoriesCubit(mockRepo);
      },
      act: (c) => c.createCategory(name: 'New', arName: 'جديد'),
      expect: () => [
        isA<CreateCategoryLoading>(),
        isA<GetCategoriesLoading>(),
        isA<GetCategoriesSuccess>(),
        isA<CreateCategorySuccess>(),
      ],
    );
  });
}
