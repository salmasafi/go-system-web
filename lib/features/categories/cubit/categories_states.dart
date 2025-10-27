import '../model/get_categories_model.dart';

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
  final CategoryItem category;
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

// Update Category
class UpdateCategoryLoading extends CategoriesState {}

class UpdateCategorySuccess extends CategoriesState {
  final String message;
  UpdateCategorySuccess(this.message);
}

class UpdateCategoryError extends CategoriesState {
  final String error;
  UpdateCategoryError(this.error);
}

// Delete Category
class DeleteCategoryLoading extends CategoriesState {}

class DeleteCategorySuccess extends CategoriesState {
  final String message;
  DeleteCategorySuccess(this.message);
}

class DeleteCategoryError extends CategoriesState {
  final String error;
  DeleteCategoryError(this.error);
}