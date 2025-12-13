// cubit/product_state.dart
import 'package:systego/features/admin/product/models/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsSuccess extends ProductsState {
  final List<Product> products;

  ProductsSuccess(this.products);
}


class WareHouseProductsSuccess extends ProductsState {
  final List<Product> products;

  WareHouseProductsSuccess(this.products);
}

class ProductDeleteSuccess extends ProductsState {
  final String message;

  ProductDeleteSuccess(this.message);
}

class ProductAddSuccess extends ProductsState {
  final String message;
  ProductAddSuccess(this.message);
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}
