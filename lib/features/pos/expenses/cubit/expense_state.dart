part of 'expense_cubit.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseCategoriesLoading extends ExpenseState {}

class ExpenseCategoriesLoaded extends ExpenseState {
  final List<ExpenseCategoryModel> categories;
  ExpenseCategoriesLoaded(this.categories);
}

class ExpensesLoading extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  ExpensesLoaded(this.expenses);
}

class ExpenseSubmitting extends ExpenseState {}

class ExpenseSuccess extends ExpenseState {}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}
