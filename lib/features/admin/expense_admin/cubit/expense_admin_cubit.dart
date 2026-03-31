import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../model/expense_admin_model.dart';
import 'expense_admin_state.dart';

class ExpenseAdminCubit extends Cubit<ExpenseAdminState> {
  ExpenseAdminCubit() : super(ExpenseAdminInitial());

  List<ExpenseAdminModel> expenses = [];
  List<ExpenseAdminModel> _filtered = [];
  String _searchQuery = '';

  List<ExpenseAdminModel> get displayed =>
      _searchQuery.isEmpty ? expenses : _filtered;

  Future<void> getExpenses() async {
    emit(GetExpensesAdminLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllExpenseAdmin);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = ExpenseAdminResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        expenses = data.data.expenses;
        _applySearch();
        emit(GetExpensesAdminSuccess(displayed));
      } else {
        emit(GetExpensesAdminError(
          response.data['message']?.toString() ?? 'Failed to load expenses',
        ));
      }
    } catch (e) {
      emit(GetExpensesAdminError(e.toString()));
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
      final response = await DioHelper.postData(
        url: EndPoint.addPosExpense,
        data: {
          'name': name,
          'amount': amount,
          'Category_id': categoryId,
          'financial_accountId': financialAccountId,
          'note': note,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateExpenseAdminSuccess('Expense created successfully'));
        await getExpenses();
      } else {
        emit(CreateExpenseAdminError(
          response.data['message']?.toString() ?? 'Failed to create expense',
        ));
      }
    } catch (e) {
      emit(CreateExpenseAdminError(e.toString()));
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
