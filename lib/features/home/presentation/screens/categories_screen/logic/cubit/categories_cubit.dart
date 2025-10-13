import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/services/cache_helper.dart.dart';
import '../../../../../../../core/services/dio_helper.dart';
import '../../../../../../../core/services/end_point.dart';
import '../../../../../../../core/utils/error_handler.dart';
import '../model/create_category_model.dart';
import '../model/get_categories_model.dart';
import '../model/get_category_by_id_model.dart';
import 'categories_states.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesInitial());

  static CategoriesCubit get(context) => BlocProvider.of(context);

  CreateCategoryModel? categoryModel;
  List<CategoryItem> allCategories = [];
  List<CategoryItem> parentCategories = [];
  CategoryDetail? selectedCategory;

  Future<void> getCategories() async {
    emit(GetCategoriesLoading());
    try {
      final token = CacheHelper.getData(key: 'token') as String?;
      final response = await DioHelper.getData(url: EndPoint.getCategories, token: token);

      print('📥 API Response: ${response.data}'); // Log the raw response

      if (response.statusCode == 200) {
        final model = GetCategoriesModel.fromJson(response.data);
        if (model.success == true && model.data != null) {
          allCategories = model.data!.categories ?? [];
          // Remove duplicates from parentCategories based on id
          parentCategories = model.data!.parentCategories ?? [];
          parentCategories = parentCategories
              .asMap()
              .entries
              .fold<List<CategoryItem>>([], (uniqueList, entry) {
            if (!uniqueList.any((item) => item.id == entry.value.id)) {
              uniqueList.add(entry.value);
            }
            return uniqueList;
          });
          print('✅ Categories loaded: ${allCategories.length}');
          print('✅ Parent Categories loaded: ${parentCategories.length}');
          print('📋 Parent Categories: ${parentCategories.map((c) => c.id).toList()}'); // Log IDs
          emit(GetCategoriesSuccess(allCategories));
        } else {
          print('❌ Failed to fetch categories: ${model.data?.message}');
          emit(GetCategoriesError('Failed to fetch categories'));
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        emit(GetCategoriesError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      print('❌ Error in getCategories: $e');
      emit(GetCategoriesError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> getCategoryById(String categoryId) async {
    emit(GetCategoryByIdLoading());
    try {
      final token = CacheHelper.getData(key: 'token') as String?;
      final response = await DioHelper.getData(url: EndPoint.getCategoryById(categoryId), token: token);

      if (response.statusCode == 200) {
        final model = GetCategoryByIdModel.fromJson(response.data);
        if (model.success == true && model.data?.category != null) {
          selectedCategory = model.data!.category!;
          emit(GetCategoryByIdSuccess(selectedCategory!));
        } else {
          emit(GetCategoryByIdError('Failed to fetch category'));
        }
      } else {
        emit(GetCategoryByIdError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(GetCategoryByIdError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> createCategory({
    required String name,
    required File imageFile,
    String? parentId,
  }) async {
    emit(CreateCategoryLoading());
    try {
      if (await imageFile.length() > 5 * 1024 * 1024) {
        emit(CreateCategoryError('Image exceeds 5MB'));
        return;
      }

      final token = CacheHelper.getData(key: 'token') as String?;
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final data = {
        'name': name,
        'image': base64Image,
        if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
      };

      print('📤 Sending data: $data');

      final response = await DioHelper.postData(url: EndPoint.createCategory, data: data, token: token);

      if (response.statusCode == 200 || response.statusCode == 201) {
        categoryModel = CreateCategoryModel.fromJson(response.data);
        if (categoryModel?.success == true) {
          print('✅ Category created successfully!');
          await getCategories(); // Reload categories
          emit(CreateCategorySuccess(categoryModel?.data?.message ?? 'Category created successfully'));
        } else {
          emit(CreateCategoryError(categoryModel?.data?.message ?? 'Failed to create category'));
        }
      } else {
        emit(CreateCategoryError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      print('❌ Error in createCategory: $e');
      emit(CreateCategoryError(ErrorHandler.handleError(e)));
    }
  }
}