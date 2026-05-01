import '../../models/product_attribute_model.dart';

abstract class ProductAttributeState {}

class ProductAttributeInitial extends ProductAttributeState {}

class ProductAttributeLoading extends ProductAttributeState {}

class ProductAttributeLoaded extends ProductAttributeState {
  final List<ProductAttribute> productAttributes;

  ProductAttributeLoaded(this.productAttributes);
}

class ProductAttributeError extends ProductAttributeState {
  final String message;

  ProductAttributeError(this.message);
}

class ProductAttributeAssigning extends ProductAttributeState {}

class ProductAttributeAssigned extends ProductAttributeState {
  final String message;

  ProductAttributeAssigned(this.message);
}

class ProductAttributeUpdating extends ProductAttributeState {}

class ProductAttributeUpdated extends ProductAttributeState {
  final String message;

  ProductAttributeUpdated(this.message);
}

class ProductAttributeRemoving extends ProductAttributeState {}

class ProductAttributeRemoved extends ProductAttributeState {
  final String message;

  ProductAttributeRemoved(this.message);
}
