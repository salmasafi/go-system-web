import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:GoSystem/features/admin/expences_category/data/repositories/expense_category_repository.dart';
import 'package:GoSystem/features/admin/expences_category/model/expences_categories_model.dart';

class MockExpenseCategoryRepository extends Mock implements ExpenseCategoryRepository {}

void main() {
  late MockExpenseCategoryRepository mockRepo;

  setUp(() {
    mockRepo = MockExpenseCategoryRepository();
  });

  ExpenseCategoryModel sampleCategory(String id) => ExpenseCategoryModel.fromJson({
        'id': id,
        'name': 'Category $id',
        'status': true,
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        '__v': 1,
      });

  group('ExpenseCategoryCubit', () {
    blocTest<ExpenseCategoryCubit, ExpenseCategoryState>(
      'getExpenseCategories emits loading then success',
      build: () {
        when(() => mockRepo.getExpenseCategories()).thenAnswer((_) async => [sampleCategory('c1')]);
        return ExpenseCategoryCubit(mockRepo);
      },
      act: (c) => c.getExpenseCategories(),
      expect: () => [
        isA<GetExpenseCategoriesLoading>(),
        isA<GetExpenseCategoriesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getExpenseCategories()).called(1);
      },
    );

    blocTest<ExpenseCategoryCubit, ExpenseCategoryState>(
      'getExpenseCategories emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getExpenseCategories()).thenThrow(Exception('network'));
        return ExpenseCategoryCubit(mockRepo);
      },
      act: (c) => c.getExpenseCategories(),
      expect: () => [
        isA<GetExpenseCategoriesLoading>(),
        isA<GetExpenseCategoriesError>(),
      ],
    );

    blocTest<ExpenseCategoryCubit, ExpenseCategoryState>(
      'createExpenseCategory emits loading then success',
      build: () {
        when(() => mockRepo.createExpenseCategory(
          name: any(named: 'name'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getExpenseCategories()).thenAnswer((_) async => [sampleCategory('c1')]);
        return ExpenseCategoryCubit(mockRepo);
      },
      act: (c) => c.createExpenseCategory(
        name: 'New Category',
        status: true,
      ),
      expect: () => [
        isA<CreateExpenseCategoryLoading>(),
        isA<CreateExpenseCategorySuccess>(),
        isA<GetExpenseCategoriesLoading>(),
        isA<GetExpenseCategoriesSuccess>(),
      ],
    );
  });
}
