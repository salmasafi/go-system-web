// cubit/product_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/features/admin/product/models/product_to_add.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../models/product_model.dart';
import 'product_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  static ProductsCubit get(context) => BlocProvider.of(context);

  Future<void> getProducts() async {
    emit(ProductsLoading());

    try {
      log('Starting products request...');

      final response = await DioHelper.getData(url: EndPoint.getProducts);

      log('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final productsJson = data['data']['products'] as List<dynamic>? ?? [];
          final products = productsJson
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList()
              .reversed
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

  Future<void> addProductWithData({
    required String name,
    required String arName,
    required String description,
    required String arDescription,
    required String image,
    required List<String> categoryIds,
    required String brandId,
    required String unit,
    required double price,
    required bool expAbility,
    required int minimumQuantitySale,
    required int lowStock,
    required double wholePrice,
    required int startQuantity,
    required String taxesId,
    required bool productHasImei,
    required bool differentPrice,
    required bool showQuantity,
    required int maximumToShow,
    required List<String> galleryProduct,
    required List<Map<String, dynamic>> prices,
  }) async {
    emit(ProductsLoading());

    // Build the request body according to API spec
    final Map<String, dynamic> requestBody = {
      'name': name,
      'ar_name': arName,
      'description': description,
      'ar_description': arDescription,
      'image': image,
      'categoryId': categoryIds,
      'brandId': brandId,
      'unit': unit,
      'price': price,
      'exp_ability': expAbility,
      'minimum_quantity_sale': minimumQuantitySale,
      'low_stock': lowStock,
      'whole_price': wholePrice,
      'start_quantaty': startQuantity, // Note: API has typo "quantaty"
      'taxesId': taxesId,
      'product_has_imei': productHasImei,
      'different_price': differentPrice,
      'show_quantity': showQuantity,
      'maximum_to_show': maximumToShow,
      'gallery_product': galleryProduct,
      'prices': prices,
    };

    try {
      log('Starting product add request...');
      log('Request body: $requestBody');

      final response = await DioHelper.postData(
        url: EndPoint.createProduct,
        data: requestBody,
      );

      log('Response received: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          final message = data['message'] ?? 'Product added successfully';
          log('Product add successful');
          emit(ProductAddSuccess(message));
        } else {
          final errorMessage = data['message']?.toString() ?? 'Failed to add product';
          log('Product add failed: $errorMessage');
          emit(ProductsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(ProductsError(errorMessage));
      }
    } catch (error) {
      log('Product add error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(ProductsError(errorMessage));
    }
  }

  Future<void> addProduct() async {
    // Keep old method for backward compatibility
    emit(ProductsLoading());

    final priceItem1 = PriceItem(
      price: 1299.99,
      code: 'S25-BLACK-TEST-202510212',
      quantity: 20,
      gallery: ['iVBORw0KGgoAAAANSUhEUgAAAAUA'],
      options: ['68e4c8ab15fdfe5fb68b1dd3', '68e4c8ab15fdfe5fb68b1dd3'],
    );

    final priceItem2 = PriceItem(
      price: 1349.99,
      code: 'S20005-GREEN-TEST-202510212',
      quantity: 15,
      gallery: ['iVBORw0KGgoAAAANSUhEUgAAAAUA'],
      options: ['68e4c8ab15fdfe5fb68b1dd3'],
    );

    final product = ProductToAdd(
      name: 'Salma \'s Test Product',
      image: 'iVBORw0KGgoAAAANSUhEUgAA',
      categoryId: ['68edf2195189fa198fc25ff3'],
      brandId: '68e4e1dfd9f407698ecee520',
      unit: 'piece',
      price: 0.0,
      description: 'Test Samsung Galaxy smartphone with cutting-edge features.',
      expAbility: false,
      minimumQuantitySale: 1,
      lowStock: 10,
      wholePrice: 1200.0,
      startQuantity: 0,
      taxesId: '67056d0a3b233c5c1b36a7ae',
      productHasImei: true,
      differentPrice: true,
      showQuantity: true,
      maximumToShow: 100,
      galleryProduct: ['iVBORw0KGgo'],
      prices: [priceItem1, priceItem2],
    );

    try {
      log('Starting product add request...');

      final response = await DioHelper.postData(
        url: EndPoint.createProduct,
        data: product.toJson(),
      );

      log('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final message = data['message'] ?? 'Product added successfully';
          log('Product add successful');
          emit(ProductAddSuccess(message));
        } else {
          final errorMessage = data['message']?.toString() ?? 'Failed to add product';
          log('Product add failed: $errorMessage');
          emit(ProductsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(ProductsError(errorMessage));
      }
    } catch (error) {
      log('Product add error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(ProductsError(errorMessage));
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(ProductsLoading());

    try {
      log('Starting product delete request...');

      final response = await DioHelper.deleteData(
        url: EndPoint.deleteProduct(productId.toString()),
      );

      log('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final message = data['data']['message'] as String? ?? '';
          log('product delete successful');
          emit(ProductDeleteSuccess(message));
        } else {
          final errorMessage = data['message'] ?? 'Failed to delete product';
          log('Product delete failed: $errorMessage');
          emit(ProductsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(ProductsError(errorMessage));
      }
    } catch (error) {
      log('Product delete error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(ProductsError(errorMessage));
    }
  }
}