// cubit/product_cubit.dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../models/product_model.dart';
import 'product_state.dart';

import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _repository;
  ProductsCubit(this._repository) : super(ProductsInitial());

  static ProductsCubit get(context) => BlocProvider.of(context);

  Future<void> getProducts() async {
    log('ProductsCubit: Starting getProducts');
    emit(ProductsLoading());
    try {
      final products = await _repository.getAllProducts();
      log('ProductsCubit: getProducts success - ${products.length} products');
      emit(ProductsSuccess(products));
    } catch (error, stackTrace) {
      log('ProductsCubit: getProducts error - $error');
      log('ProductsCubit: stackTrace - $stackTrace');
      emit(ProductsError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<String> generateCode() async {
    try {
      final code = await _repository.generateProductCode();
      return code ?? '';
    } catch (error) {
      return '';
    }
  }

  Future<void> addProductWithData({
    required String name,
    required String arName,
    required String description,
    required String arDescription,
    String? image,
    required String? code,
    required List<String> categoryIds,
    required String brandId,
    required String productUnit,
    required String purchaseUnit,
    required String saleUnit,
    required double price,
    required bool expAbility,
    required DateTime? expiryDate,
    required int minimumQuantitySale,
    required int lowStock,
    required double wholePrice,
    required int startQuantity,
    required int quantity,
    required String taxesId,
    required bool productHasImei,
    required bool showQuantity,
    required bool isFeatured,
    required int maximumToShow,
    required List<String> galleryProduct,
  }) async {
    emit(ProductsLoading());
    try {
      final product = Product(
        id: '',
        name: name,
        arName: arName,
        description: description,
        arDescription: arDescription,
        image: image ?? '',
        categoryId: categoryIds
            .map(
              (id) => Category(
                id: id,
                name: '',
                image: '',
                productQuantity: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList(),
        brandId: Brand(
          id: brandId,
          name: '',
          logo: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        unit: productUnit,
        price: price,
        expAbility: expAbility,
        dateOfExpiry: expiryDate,
        minimumQuantitySale: minimumQuantitySale,
        lowStock: lowStock,
        wholePrice: wholePrice,
        startQuantaty: startQuantity,
        quantity: quantity,
        taxesId: taxesId,
        productHasImei: productHasImei,
        showQuantity: showQuantity,
        isFeatured: isFeatured,
        maximumToShow: maximumToShow,
        galleryProduct: galleryProduct,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createProduct(product);
      emit(ProductAddSuccess('Product created successfully'));
    } catch (error) {
      emit(ProductsError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateProductWithData({
    required String id,
    required String name,
    required String arName,
    required String description,
    required String arDescription,
    String? image,
    required String? code,
    required List<String> categoryIds,
    required String brandId,
    required String unit,
    required double price,
    required bool expAbility,
    required DateTime? expiryDate,
    required int minimumQuantitySale,
    required int lowStock,
    required double wholePrice,
    required int startQuantity,
    required int quantity,
    required String taxesId,
    required bool productHasImei,
    required bool showQuantity,
    required bool isFeatured,
    required int maximumToShow,
    required List<String> galleryProduct,
  }) async {
    emit(ProductsLoading());
    try {
      final product = Product(
        id: id,
        name: name,
        arName: arName,
        description: description,
        arDescription: arDescription,
        image: image ?? '',
        categoryId: categoryIds
            .map(
              (id) => Category(
                id: id,
                name: '',
                image: '',
                productQuantity: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList(),
        brandId: Brand(
          id: brandId,
          name: '',
          logo: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        unit: unit,
        price: price,
        expAbility: expAbility,
        dateOfExpiry: expiryDate,
        minimumQuantitySale: minimumQuantitySale,
        lowStock: lowStock,
        wholePrice: wholePrice,
        startQuantaty: startQuantity,
        quantity: quantity,
        taxesId: taxesId,
        productHasImei: productHasImei,
        showQuantity: showQuantity,
        isFeatured: isFeatured,
        maximumToShow: maximumToShow,
        galleryProduct: galleryProduct,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.updateProduct(id, product);
      emit(ProductAddSuccess('Product updated successfully'));
    } catch (error) {
      emit(ProductsError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(ProductsLoading());
    try {
      await _repository.deleteProduct(productId);
      emit(ProductDeleteSuccess('Product deleted successfully'));
      await getProducts();
    } catch (error) {
      emit(ProductsError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getWareHouseProducts(String wareHouseID) async {
    emit(ProductsLoading());
    try {
      final products = await _repository.getProductsByWarehouse(wareHouseID);
      emit(ProductsSuccess(products));
    } catch (error) {
      emit(ProductsError(error.toString().replaceAll('Exception: ', '')));
    }
  }
}
