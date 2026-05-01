import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/pos/expenses/model/expense_model.dart';
import 'package:GoSystem/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit() : super(ExpenseInitial());

  List<ExpenseCategoryModel> categories = [];
  List<ExpenseModel> expenses = [];

  Future<void> getCategories() async {
    emit(ExpenseCategoriesLoading());
    try {
      final response =
          await DioHelper.getData(url: EndPoint.getAllexpencesCategories);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list =
            response.data['data']['expenseCategories'] as List? ?? [];
        categories =
            list.map((e) => ExpenseCategoryModel.fromJson(e)).toList();
        emit(ExpenseCategoriesLoaded(categories));
      } else {
        emit(ExpenseError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> getExpenses() async {
    emit(ExpensesLoading());
    try {
      final response =
          await DioHelper.getData(url: EndPoint.getPosExpenses);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data']['expenses'] as List? ?? [];
        expenses = list.map((e) => ExpenseModel.fromJson(e)).toList();
        emit(ExpensesLoaded(expenses));
      } else {
        emit(ExpenseError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> addExpense({
    required String name,
    required String categoryId,
    required String amount,
    required String note,
    required String financialAccountId,
  }) async {
    emit(ExpenseSubmitting());
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addPosExpense,
        data: {
          'name': name,
          'Category_id': categoryId,
          'amount': amount,
          'note': note,
          'financial_accountId': financialAccountId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ExpenseSuccess());
        await getExpenses();
      } else {
        emit(ExpenseError(
            response.data['message']?.toString() ?? LocaleKeys.failed_to_add_expense.tr()));
      }
    } catch (e) {
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> updateExpense({
    required String id,
    required String name,
    required String categoryId,
    required String amount,
    required String note,
    required String financialAccountId,
  }) async {
    emit(ExpenseSubmitting());
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updatePosExpense(id),
        data: {
          'name': name,
          'Category_id': categoryId,
          'amount': amount,
          'note': note,
          'financial_accountId': financialAccountId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ExpenseSuccess());
        await getExpenses();
      } else {
        emit(ExpenseError(
            response.data['message']?.toString() ?? LocaleKeys.failed_to_update_expense.tr()));
      }
    } catch (e) {
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }
}
