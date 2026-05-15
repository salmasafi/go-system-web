import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/admin/expences/data/repositories/expense_repository.dart';
import 'package:GoSystem/features/admin/expense_admin/model/expense_admin_model.dart';

part 'expences_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpenseRepository _repository;
  ExpensesCubit(this._repository) : super(ExpensesInitial());

  List<ExpenseAdminModel> allExpenses = [];

  Future<void> getExpenses() async {
    emit(GetExpensesLoading());
    try {
      final list = await _repository.getAllExpenses();
      allExpenses = list;
      emit(GetExpensesSuccess(list));
    } catch (e) {
      log('ExpensesCubit: getExpenses error - $e');
      emit(GetExpensesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createExpense({
    required String name,
    required double amount,
    required String categoryId,
    required String financialAccountId,
    required String note,
  }) async {
    emit(CreateExpenseLoading());
    try {
      await _repository.createExpense(
        name: name,
        amount: amount,
        categoryId: categoryId,
        financialAccountId: financialAccountId,
        note: note,
      );
      emit(CreateExpenseSuccess('success'.tr()));
      await getExpenses();
    } catch (e) {
      log('ExpensesCubit: createExpense error - $e');
      emit(CreateExpenseError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateExpense({
    required String id,
    required String name,
    required double amount,
    required String categoryId,
    required String financialAccountId,
    required String note,
  }) async {
    emit(UpdateExpenseLoading());
    try {
      await _repository.updateExpense(
        id: id,
        name: name,
        amount: amount,
        categoryId: categoryId,
        financialAccountId: financialAccountId,
        note: note,
      );
      emit(UpdateExpenseSuccess('success'.tr()));
      await getExpenses();
    } catch (e) {
      log('ExpensesCubit: updateExpense error - $e');
      emit(UpdateExpenseError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteExpense(String id) async {
    emit(DeleteExpenseLoading());
    try {
      await _repository.deleteExpense(id);
      emit(DeleteExpenseSuccess('success'.tr()));
      await getExpenses();
    } catch (e) {
      log('ExpensesCubit: deleteExpense error - $e');
      emit(DeleteExpenseError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
