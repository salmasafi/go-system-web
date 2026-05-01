// cubit/product_filters_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/endpoints.dart';
import '../../../../../../core/services/dio_helper.dart';
import '../../../../../../core/utils/error_handler.dart';
import '../../models/filter_models.dart';
import '../product_filter_state.dart';

import 'package:systego/features/admin/product/data/repositories/product_repository.dart';

class ProductFiltersCubit extends Cubit<ProductFiltersState> {
  final ProductRepository _repository;
  ProductFiltersCubit(this._repository) : super(ProductFiltersInitial());

  static ProductFiltersCubit get(context) => BlocProvider.of(context);

  List<VariationFilter> variations = [];

  Future<void> getFilters() async {
    emit(ProductFiltersLoading());

    try {
      log('ProductFiltersCubit: Fetching filters');
      final data = await _repository.getProductFilters();

      if (data['success'] == true && data['data'] != null) {
        final filtersModel = ProductFiltersModel.fromJson(data);
        variations = filtersModel.data?.variations ?? [];
        emit(ProductFiltersSuccess(filtersModel));
      } else {
        emit(ProductFiltersError('Failed to fetch filters'));
      }
    } catch (error) {
      log('ProductFiltersCubit: Error fetching filters - $error');
      emit(ProductFiltersError(error.toString().replaceAll('Exception: ', '')));
    }
  }
}

