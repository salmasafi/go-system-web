import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../model/expense_admin_model.dart';
import 'expense_admin_state.dart';

import 'package:systego/features/admin/expences/data/repositories/expense_repository.dart';

class ExpenseAdminCubit extends Cubit<ExpenseAdminState> {
  final ExpenseRepository _repository;
  ExpenseAdminCubit(this._repository) : super(ExpenseAdminInitial());

  List<ExpenseAdminModel> expenses = [];
  List<ExpenseAdminModel> _filtered = [];
  String _searchQuery = '';

  List<ExpenseAdminModel> get displayed =>
      _searchQuery.isEmpty ? expenses : _filtered;

  Future<void> getExpenses() async {
    emit(GetExpensesAdminLoading());
    try {
      final list = await _repository.getAllExpenses();
      expenses = list;
      _applySearch();
      emit(GetExpensesAdminSuccess(displayed));
    } catch (e) {
      emit(GetExpensesAdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createExpense({
    required String name,
    required double amount,
    required String categoryId,
    required String financialAccountId,
    required String note,
  }) async {
    emit(CreateExpenseAdminLoading());
    try {
      await _repository.createExpense(
        name: name,
        amount: amount,
        categoryId: categoryId,
        financialAccountId: financialAccountId,
        note: note,
      );
      emit(CreateExpenseAdminSuccess('Expense created successfully'));
      await getExpenses();
    } catch (e) {
      emit(CreateExpenseAdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }


  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    emit(GetExpensesAdminSuccess(displayed));
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filtered = [];
      return;
    }
    _filtered = expenses.where((e) {
      return e.name.toLowerCase().contains(_searchQuery) ||
          (e.financialAccountName?.toLowerCase().contains(_searchQuery) ??
              false) ||
          e.note.toLowerCase().contains(_searchQuery);
    }).toList();
  }
}
