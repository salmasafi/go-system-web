import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:systego/features/admin/expences_category/data/repositories/expense_category_repository.dart';

part 'expences_categories_state.dart';

class ExpenseCategoryCubit extends Cubit<ExpenseCategoryState> {
  final ExpenseCategoryRepository _repository;
  ExpenseCategoryCubit(this._repository) : super(ExpenseCategoryInitial());

  List<ExpenseCategoryModel> allExpenseCategories = [];

  Future<void> getExpenseCategories() async {
    emit(GetExpenseCategoriesLoading());
    try {
      final categories = await _repository.getExpenseCategories();
      allExpenseCategories = categories;
      emit(GetExpenseCategoriesSuccess(categories));
    } catch (e) {
      emit(
        GetExpenseCategoriesError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> createExpenseCategory({
    required String name,
    required String arName,
    required bool status,
  }) async {
    emit(CreateExpenseCategoryLoading());
    try {
      await _repository.createExpenseCategory(
        name: name,
        arName: arName,
        status: status,
      );
      emit(
        CreateExpenseCategorySuccess(
          LocaleKeys.expense_category_created_success.tr(),
        ),
      );
      getExpenseCategories();
    } catch (e) {
      emit(
        CreateExpenseCategoryError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> updateExpenseCategory({
    required String categoryId,
    required String name,
    required String arName,
    required bool status,
  }) async {
    emit(UpdateExpenseCategoryLoading());
    try {
      await _repository.updateExpenseCategory(
        categoryId: categoryId,
        name: name,
        arName: arName,
        status: status,
      );
      emit(
        UpdateExpenseCategorySuccess(
          LocaleKeys.expense_category_updated_success.tr(),
        ),
      );
      getExpenseCategories();
    } catch (e) {
      emit(
        UpdateExpenseCategoryError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> deleteExpenseCategory(String categoryId) async {
    emit(DeleteExpenseCategoryLoading());
    try {
      await _repository.deleteExpenseCategory(categoryId);
      allExpenseCategories.removeWhere((c) => c.id == categoryId);
      emit(
        DeleteExpenseCategorySuccess(
          LocaleKeys.expense_category_deleted_success.tr(),
        ),
      );
    } catch (e) {
      emit(
        DeleteExpenseCategoryError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
