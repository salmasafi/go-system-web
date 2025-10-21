// cubit/product_filters_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/endpoints.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/utils/error_handler.dart';
import '../data/models/filter_models.dart';
import 'product_filter_state.dart';

class ProductFiltersCubit extends Cubit<ProductFiltersState> {
  ProductFiltersCubit() : super(ProductFiltersInitial());

  static ProductFiltersCubit get(context) => BlocProvider.of(context);

  Future<void> getFilters() async {
    emit(ProductFiltersLoading());

    try {
      log('Starting filters request...');

      final response = await DioHelper.getData(url: EndPoint.productSelect);

      log('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final filtersModel = ProductFiltersModel.fromJson(data);
          log('Filters fetch successful');
          emit(ProductFiltersSuccess(filtersModel));
        } else {
          final errorMessage = data['message'] ?? 'Failed to fetch filters';
          log('Filters fetch failed: $errorMessage');
          emit(ProductFiltersError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(ProductFiltersError(errorMessage));
      }
    } catch (error) {
      log('Filters fetch error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(ProductFiltersError(errorMessage));
    }
  }
}