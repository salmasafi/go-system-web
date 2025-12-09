// cubit/product_details_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../models/product_details_model.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit() : super(ProductDetailsInitial());

  static ProductDetailsCubit get(context) => BlocProvider.of(context);

  ProductDetailsModel? productDetailsModel;

  Future<void> getProductDetails(String productId) async {
    emit(ProductDetailsLoading());

    try {
      log('Fetching product details for ID: $productId');

      final response = await DioHelper.getData(
        url: EndPoint.getProductById(productId),
      );

      log('Response Status Code: ${response.statusCode}');
      log('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        productDetailsModel = ProductDetailsModel.fromJson(response.data);

        log('product details: ${productDetailsModel?.toJson()}');

        if (productDetailsModel?.success == true &&
            productDetailsModel?.data != null) {
          log('Product details loaded successfully');
          emit(ProductDetailsSuccess(productDetailsModel!));
        } else {
          final errorMessage =
              productDetailsModel?.data?.message ??
              'Failed to load product details';
          log('Failed to load product: $errorMessage');
          emit(ProductDetailsError(errorMessage));
        }
      } else {
        log('Failed with status: ${response.statusCode}');
        emit(
          ProductDetailsError(
            'Failed to load product details: ${response.statusCode}',
          ),
        );
      }
    } catch (error) {
      log('Error: $error');
      emit(ProductDetailsError(error.toString()));
    }
  }
}
