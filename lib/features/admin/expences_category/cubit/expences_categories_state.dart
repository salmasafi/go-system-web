part of 'expences_categories_cubit.dart';


@immutable
abstract class ExpenseCategoryState {}

class ExpenseCategoryInitial extends ExpenseCategoryState {}

class GetExpenseCategoriesLoading extends ExpenseCategoryState {}
class GetExpenseCategoriesSuccess extends ExpenseCategoryState {
  final List<ExpenseCategoryModel> expenseCategories;
  GetExpenseCategoriesSuccess(this.expenseCategories);
}
class GetExpenseCategoriesError extends ExpenseCategoryState {
  final String errorMessage;
  GetExpenseCategoriesError(this.errorMessage);
}

class CreateExpenseCategoryLoading extends ExpenseCategoryState {}
class CreateExpenseCategorySuccess extends ExpenseCategoryState {
  final String successMessage;
  CreateExpenseCategorySuccess(this.successMessage);
}
class CreateExpenseCategoryError extends ExpenseCategoryState {
  final String errorMessage;
  CreateExpenseCategoryError(this.errorMessage);
}

class UpdateExpenseCategoryLoading extends ExpenseCategoryState {}
class UpdateExpenseCategorySuccess extends ExpenseCategoryState {
  final String successMessage;
  UpdateExpenseCategorySuccess(this.successMessage);
}
class UpdateExpenseCategoryError extends ExpenseCategoryState {
  final String errorMessage;
  UpdateExpenseCategoryError(this.errorMessage);
}

class DeleteExpenseCategoryLoading extends ExpenseCategoryState {}
class DeleteExpenseCategorySuccess extends ExpenseCategoryState {
  final String successMessage;
  DeleteExpenseCategorySuccess(this.successMessage);
}
class DeleteExpenseCategoryError extends ExpenseCategoryState {
  final String errorMessage;
  DeleteExpenseCategoryError(this.errorMessage);
}
