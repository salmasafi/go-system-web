import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'expences_categories_state.dart';

class ExpenseCategoryCubit extends Cubit<ExpenseCategoryState> {
  ExpenseCategoryCubit() : super(ExpenseCategoryInitial());

  List<ExpenseCategoryModel> allExpenseCategories = [];

  Future<void> getExpenseCategories() async {
    emit(GetExpenseCategoriesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllexpencesCategories);
      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = ExpenseCategoryResponse.fromJson(response.data);

        if (model.success == true) {
          allExpenseCategories = model.data.expenseCategories;
          emit(GetExpenseCategoriesSuccess(model.data.expenseCategories));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetExpenseCategoriesError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetExpenseCategoriesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetExpenseCategoriesError(errorMessage));
    }
  }

  Future<void> createExpenseCategory({
    required String name,
    required String arName,
    required bool status,
  }) async {
    emit(CreateExpenseCategoryLoading());

    try {
      final data = {
        "name": name,
        "ar_name": arName,
        "status": status,
      };

      final response =
          await DioHelper.postData(url: EndPoint.addExpencesCategory, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateExpenseCategorySuccess(
          LocaleKeys.expense_category_created_success.tr()
        ));
        // Refresh the list after successful creation
        await getExpenseCategories();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateExpenseCategoryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateExpenseCategoryError(errorMessage));
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
      final data = {
        "name": name,
        "ar_name": arName,
        "status": status,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateExpencesCategory(categoryId),
        data: data,
      );

      log("data updating: ${data}");

      if (response.statusCode == 200) {
        emit(UpdateExpenseCategorySuccess(LocaleKeys.expense_category_updated_success.tr()));
        // Refresh the list after successful update
        await getExpenseCategories();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateExpenseCategoryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateExpenseCategoryError(errorMessage));
    }
  }

  Future<void> deleteExpenseCategory(String categoryId) async {
    emit(DeleteExpenseCategoryLoading());

    try {
      final response =
          await DioHelper.deleteData(url: EndPoint.deleteExpencesCategory(categoryId));

      if (response.statusCode == 200) {
        allExpenseCategories.removeWhere((c) => c.id == categoryId);
        emit(DeleteExpenseCategorySuccess(LocaleKeys.expense_category_deleted_success.tr()));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteExpenseCategoryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteExpenseCategoryError(errorMessage));
    }
  }

}