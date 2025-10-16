// cubit/product_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/end_point.dart';
import '../../../../core/services/cache_helper.dart.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/product_model.dart';
import 'product_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  static ProductsCubit get(context) => BlocProvider.of(context);

  Future<void> getProducts() async {
    emit(ProductsLoading());

    try {
      log('Starting products request...');

     // String? token = CacheHelper.getData(key: 'token') as String?;

      final response = await DioHelper.getData(
        url: EndPoint.getProducts, 
        //token: token,
      );

      log('Response received: ${response.statusCode}');
      DioHelper.printResponse(response);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final productsJson = data['data']['products'] as List<dynamic>? ?? [];
          final products = productsJson
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
          log('Products fetch successful');
          emit(ProductsSuccess(products));
        } else {
          final errorMessage = data['message'] ?? 'Failed to fetch products';
          log('Products fetch failed: $errorMessage');
          emit(ProductsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(ProductsError(errorMessage));
      }
    } catch (error) {
      log('Products fetch error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(ProductsError(errorMessage));
    }
  }

  // Get cached products
  List<Product> getCachedProducts() {
    final cached = CacheHelper.getModel<List<Product>>(
      key: 'products',
      fromJson: (jsonList) => (jsonList as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
    return cached ?? [];
  }
}