import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../model/get_categories_model.dart';
import 'categories_states.dart';

import 'package:systego/features/admin/categories/data/repositories/category_repository.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepository _repository;
  CategoriesCubit(this._repository) : super(CategoriesInitial());

  static CategoriesCubit get(context) => BlocProvider.of(context);

  List<CategoryItem> allCategories = [];
  List<CategoryItem> parentCategories = [];
  CategoryItem? selectedCategory;

  Future<void> getCategories() async {
    emit(GetCategoriesLoading());
    try {
      final categories = await _repository.getAllCategories();
      allCategories = categories;
      
      // Filter unique parents
      final uniqueParentsMap = <String, CategoryItem>{};
      for (var category in categories) {
        if (category.parentId != null) {
          // This is a subcategory, we should probably fetch actual parent objects if not included
          // For now, follow legacy logic if parents were provided separately or inferred
        }
      }
      // In hybrid, we might need a separate call or specific mapping
      // Let's assume allCategories contains everything needed for now
      emit(GetCategoriesSuccess(allCategories));
    } catch (e) {
      emit(GetCategoriesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getCategoryById(String categoryId) async {
    emit(GetCategoryByIdLoading());
    try {
      final category = await _repository.getCategoryById(categoryId);
      if (category != null) {
        selectedCategory = category;
        emit(GetCategoryByIdSuccess(category));
      } else {
        emit(GetCategoryByIdError('Category not found'));
      }
    } catch (e) {
      emit(GetCategoryByIdError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCategory({
    required String name,
    required String arName,
    File? imageFile,
    String? parentId,
  }) async {
    emit(CreateCategoryLoading());
    try {
      await _repository.createCategory(
        name: name,
        arName: arName,
        parentId: parentId,
        imageFile: imageFile,
      );
      await getCategories();
      emit(CreateCategorySuccess(LocaleKeys.success.tr()));
    } catch (e) {
      emit(CreateCategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required String arName,
    File? imageFile,
    String? parentId,
  }) async {
    emit(UpdateCategoryLoading());
    try {
      await _repository.updateCategory(
        id: categoryId,
        name: name,
        arName: arName,
        parentId: parentId,
        imageFile: imageFile,
      );
      await getCategories();
      emit(UpdateCategorySuccess(LocaleKeys.success.tr()));
    } catch (e) {
      emit(UpdateCategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    emit(DeleteCategoryLoading());
    try {
      await _repository.deleteCategory(categoryId);
      allCategories.removeWhere((category) => category.id == categoryId);
      if (selectedCategory?.id == categoryId) selectedCategory = null;
      emit(DeleteCategorySuccess(LocaleKeys.success.tr()));
    } catch (e) {
      emit(DeleteCategoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

