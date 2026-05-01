import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/create_category_model.dart';
import '../model/delete_category_model.dart';
import '../model/get_categories_model.dart';
import 'categories_states.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesInitial());

  static CategoriesCubit get(context) => BlocProvider.of(context);

  CreateCategoryModel? categoryModel;
  List<CategoryItem> allCategories = [];
  List<CategoryItem> parentCategories = [];
  CategoryItem? selectedCategory;

  Future<void> getCategories() async {
    emit(GetCategoriesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getCategories);

      if (response.statusCode == 200) {
        final model = CategoryResponse.fromJson(response.data);
        if (model.success == true && model.data.categories.isNotEmpty) {
          allCategories = model.data.categories;
          final uniqueParentsMap = <String, CategoryItem>{};
          for (var category in model.data.parentCategories) {
            uniqueParentsMap[category.id] = category;
          }
          parentCategories = uniqueParentsMap.values.toList();

          emit(GetCategoriesSuccess(allCategories));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCategoriesError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCategoriesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCategoriesError(errorMessage));
    }
  }

  Future<void> getCategoryById(String categoryId) async {
    emit(GetCategoryByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getCategoryById(categoryId),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        if (json['success'] == true && json['data']?['category'] != null) {
          selectedCategory = CategoryItem.fromJson(json['data']['category']);
          emit(GetCategoryByIdSuccess(selectedCategory!));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCategoryByIdError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCategoryByIdError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCategoryByIdError(errorMessage));
    }
  }

  Future<void> createCategory({
    required String name,
    required String arName,
    File? imageFile, // Made optional
    String? parentId,
  }) async {
    emit(CreateCategoryLoading());
    try {
      String? base64Image;
      
      if (imageFile != null) {
        if (await imageFile.length() > 5 * 1024 * 1024) {
          emit(CreateCategoryError('Image exceeds 5MB'));
          return;
        }

        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final data = {
        'name': name,
        'ar_name': arName,
        if (base64Image != null) 'image': base64Image, // Only add if provided
        if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createCategory,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        categoryModel = CreateCategoryModel.fromJson(response.data);
        if (categoryModel?.success == true) {
          await getCategories();
          emit(
            CreateCategorySuccess(
              categoryModel?.data?.message ?? 'Category created successfully',
            ),
          );
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(CreateCategoryError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateCategoryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateCategoryError(errorMessage));
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
      final data = <String, dynamic>{'name': name, 'ar_name': arName};

      if (imageFile != null) {
        if (await imageFile.length() > 5 * 1024 * 1024) {
          emit(UpdateCategoryError('Image exceeds 5MB'));
          return;
        }
        final bytes = await imageFile.readAsBytes();
        data['image'] = base64Encode(bytes);
      }

      if (parentId != null && parentId.isNotEmpty) {
        data['parentId'] = parentId;
      }

      final response = await DioHelper.putData(
        url: EndPoint.updateCategory(categoryId),
        data: data,
      );

      if (response.statusCode == 200) {
        final model = CreateCategoryModel.fromJson(response.data);
        if (model.success == true) {
          await getCategories();
          emit(
            UpdateCategorySuccess(
              model.data?.message ?? 'Category updated successfully',
            ),
          );
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(UpdateCategoryError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateCategoryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateCategoryError(errorMessage));
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    emit(DeleteCategoryLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteCategory(categoryId),
      );

      if (response.statusCode == 200) {
        final model = DeleteCategoryModel.fromJson(response.data);
        if (model.success == true) {
          allCategories.removeWhere((category) => category.id == categoryId);
          parentCategories.removeWhere((category) => category.id == categoryId);

          if (selectedCategory?.id == categoryId) {
            selectedCategory = null;
          }

          emit(
            DeleteCategorySuccess(
              model.data?.message ?? 'Category deleted successfully',
            ),
          );
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(DeleteCategoryError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteCategoryError(errorMessage));
      }
    } catch (e) {
      final errorStr = e.toString();
      // Check for foreign key violation errors
      if (errorStr.contains('foreign key') || 
          errorStr.contains('violates') ||
          errorStr.contains('constraint') ||
          errorStr.contains('referenced')) {
        emit(DeleteCategoryError(
          'Cannot delete category: it is linked to products or other records',
        ));
      } else {
        final errorMessage = ErrorHandler.handleError(e);
        emit(DeleteCategoryError(errorMessage));
      }
    }
  }
}
