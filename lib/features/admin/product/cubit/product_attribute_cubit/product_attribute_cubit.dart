import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_attribute_model.dart';
import '../../data/repositories/attribute_repository.dart';
import 'product_attribute_state.dart';

class ProductAttributeCubit extends Cubit<ProductAttributeState> {
  final ProductAttributeRepository _repository;
  String _currentProductId = '';

  ProductAttributeCubit(this._repository) : super(ProductAttributeInitial());

  List<ProductAttribute> get productAttributes => state is ProductAttributeLoaded
      ? (state as ProductAttributeLoaded).productAttributes
      : [];

  String get currentProductId => _currentProductId;

  static ProductAttributeCubit get(context) => BlocProvider.of(context);

  Future<void> loadProductAttributes(String productId) async {
    _currentProductId = productId;
    emit(ProductAttributeLoading());
    try {
      final attributes = await _repository.getAttributesByProduct(productId);
      emit(ProductAttributeLoaded(attributes));
    } catch (e) {
      emit(ProductAttributeError(e.toString()));
    }
  }

  Future<void> assignAttributeToProduct({
    required String productId,
    required String attributeTypeId,
    required List<String> attributeValueIds,
  }) async {
    emit(ProductAttributeAssigning());
    try {
      final productAttribute = ProductAttribute(
        id: '',
        productId: productId,
        attributeTypeId: attributeTypeId,
        attributeValueIds: attributeValueIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.assignAttributeToProduct(productAttribute);
      await loadProductAttributes(productId);
      emit(ProductAttributeAssigned('Attribute assigned to product successfully'));
    } catch (e) {
      final errorStr = e.toString();
      // Check for constraint violation (product with different_price)
      if (errorStr.contains('different_price') ||
          errorStr.contains('price variation') ||
          errorStr.contains('constraint') ||
          errorStr.contains('violates')) {
        emit(ProductAttributeError(
          'Cannot assign attributes: product has price variations enabled',
        ));
      } else {
        emit(ProductAttributeError(e.toString()));
      }
    }
  }

  Future<void> updateProductAttribute({
    required String id,
    required List<String> attributeValueIds,
  }) async {
    emit(ProductAttributeUpdating());
    try {
      final currentAttributes = productAttributes;
      final current = currentAttributes.firstWhere((a) => a.id == id);

      final updated = current.copyWith(
        attributeValueIds: attributeValueIds,
      );

      await _repository.updateProductAttribute(id, updated);
      await loadProductAttributes(_currentProductId);
      emit(ProductAttributeUpdated('Product attribute updated successfully'));
    } catch (e) {
      emit(ProductAttributeError(e.toString()));
    }
  }

  Future<void> removeAttributeFromProduct(String id) async {
    emit(ProductAttributeRemoving());
    try {
      await _repository.removeProductAttribute(id);
      await loadProductAttributes(_currentProductId);
      emit(ProductAttributeRemoved('Attribute removed from product successfully'));
    } catch (e) {
      emit(ProductAttributeError(e.toString()));
    }
  }

  Future<void> removeAllAttributesFromProduct(String productId) async {
    emit(ProductAttributeRemoving());
    try {
      await _repository.removeAttributesByProduct(productId);
      await loadProductAttributes(productId);
      emit(ProductAttributeRemoved('All attributes removed from product successfully'));
    } catch (e) {
      emit(ProductAttributeError(e.toString()));
    }
  }
}
