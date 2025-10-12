// categories_cubit.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/services/cache_helper.dart.dart';
import '../../../../../../../core/services/dio_helper.dart';
import '../../../../../../../core/services/end_point.dart';
import '../../../../../../../core/utils/error_handler.dart';
import '../model/create_category_model.dart';
import 'categories_states.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesInitial());

  static CategoriesCubit get(context) => BlocProvider.of(context);

  CreateCategoryModel? categoryModel;

  Future<void> createCategory({
    required String name,
    required File imageFile,
  }) async {
    emit(CreateCategoryLoading());

    try {
      log('Starting create category request...');

      final token = CacheHelper.getData(key: 'token') as String?;

      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await DioHelper.postData(
        url: EndPoint.createCategory,
        data: {
          'name': name,
          'image': base64Image,
        },
        token: token,
      );

      log('Response received: ${response.statusCode}');
      DioHelper.printResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        categoryModel = CreateCategoryModel.fromJson(response.data);

        if (categoryModel?.success == true) {
          final message = categoryModel?.data?.message ?? 'Category created successfully';
          log('Category created: $message');
          emit(CreateCategorySuccess(message));
        } else {
          final errorMessage = categoryModel?.data?.message ?? 'Failed to create category';
          log('Creation failed: $errorMessage');
          emit(CreateCategoryError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(CreateCategoryError(errorMessage));
      }
    } catch (error) {
      log('Create category error: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(CreateCategoryError(errorMessage));
    }
  }
}