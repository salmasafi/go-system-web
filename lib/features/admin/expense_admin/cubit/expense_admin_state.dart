import '../model/expense_admin_model.dart';

abstract class ExpenseAdminState {}

class ExpenseAdminInitial extends ExpenseAdminState {}

class GetExpensesAdminLoading extends ExpenseAdminState {}

class GetExpensesAdminSuccess extends ExpenseAdminState {
  final List<ExpenseAdminModel> expenses;
  GetExpensesAdminSuccess(this.expenses);
}

class GetExpensesAdminError extends ExpenseAdminState {
  final String error;
  GetExpensesAdminError(this.error);
}

class CreateExpenseAdminLoading extends ExpenseAdminState {}

class CreateExpenseAdminSuccess extends ExpenseAdminState {
  final String message;
  CreateExpenseAdminSuccess(this.message);
}

class CreateExpenseAdminError extends ExpenseAdminState {
  final String error;
  CreateExpenseAdminError(this.error);
}
