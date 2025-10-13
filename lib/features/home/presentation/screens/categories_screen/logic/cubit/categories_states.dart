// categories_states.dart
abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CreateCategoryLoading extends CategoriesState {}

class CreateCategorySuccess extends CategoriesState {
  final String message;
  CreateCategorySuccess(this.message);
}

class CreateCategoryError extends CategoriesState {
  final String error;
  CreateCategoryError(this.error);
}