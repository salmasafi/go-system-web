// categories_states.dart
import '../model/get_categories_model.dart';
import '../model/get_category_by_id_model.dart';

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

// Get All Categories
class GetCategoriesLoading extends CategoriesState {}

class GetCategoriesSuccess extends CategoriesState {
  final List<CategoryItem> categories;
  GetCategoriesSuccess(this.categories);
}

class GetCategoriesError extends CategoriesState {
  final String error;
  GetCategoriesError(this.error);
}

// Get Category By ID
class GetCategoryByIdLoading extends CategoriesState {}

class GetCategoryByIdSuccess extends CategoriesState {
  final CategoryDetail category;
  GetCategoryByIdSuccess(this.category);
}

class GetCategoryByIdError extends CategoriesState {
  final String error;
  GetCategoryByIdError(this.error);
}

// Create Category
class CreateCategoryLoading extends CategoriesState {}

class CreateCategorySuccess extends CategoriesState {
  final String message;
  CreateCategorySuccess(this.message);
}

class CreateCategoryError extends CategoriesState {
  final String error;
  CreateCategoryError(this.error);
}