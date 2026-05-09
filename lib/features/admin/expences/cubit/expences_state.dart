part of 'expences_cubit.dart';

abstract class ExpensesState {}

class ExpensesInitial extends ExpensesState {}

class GetExpensesLoading extends ExpensesState {}
class GetExpensesSuccess extends ExpensesState {
  final List<ExpenseAdminModel> expenses;
  GetExpensesSuccess(this.expenses);
}
class GetExpensesError extends ExpensesState {
  final String error;
  GetExpensesError(this.error);
}

class CreateExpenseLoading extends ExpensesState {}
class CreateExpenseSuccess extends ExpensesState {
  final String message;
  CreateExpenseSuccess(this.message);
}
class CreateExpenseError extends ExpensesState {
  final String error;
  CreateExpenseError(this.error);
}

class DeleteExpenseLoading extends ExpensesState {}
class DeleteExpenseSuccess extends ExpensesState {
  final String message;
  DeleteExpenseSuccess(this.message);
}
class DeleteExpenseError extends ExpensesState {
  final String error;
  DeleteExpenseError(this.error);
}
