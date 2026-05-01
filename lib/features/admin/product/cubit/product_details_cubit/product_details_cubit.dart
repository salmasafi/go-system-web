// cubit/product_details_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../models/product_details_model.dart';
import 'product_details_state.dart';

import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final ProductRepository _repository;
  ProductDetailsCubit(this._repository) : super(ProductDetailsInitial());

  static ProductDetailsCubit get(context) => BlocProvider.of(context);

  ProductDetailsModel? productDetailsModel;

  Future<void> getProductDetails(String productId) async {
    emit(ProductDetailsLoading());

    try {
      log('Fetching product details for ID: $productId');
      final product = await _repository.getProductById(productId);

      if (product != null) {
        // Map common product to legacy details model
        final legacyJson = {
          'success': true,
          'data': {
            'product': product.toJson(),
            'message': 'Loaded from repository'
          }
        };
        productDetailsModel = ProductDetailsModel.fromJson(legacyJson);
        emit(ProductDetailsSuccess(productDetailsModel!));
      } else {
        emit(ProductDetailsError('Product not found'));
      }
    } catch (error) {
      log('Error: $error');
      emit(ProductDetailsError(error.toString().replaceAll('Exception: ', '')));
    }
  }
}

