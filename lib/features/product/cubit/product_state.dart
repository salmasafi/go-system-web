// cubit/product_state.dart
import 'package:systego/features/product/data/models/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsSuccess extends ProductsState {
  final List<Product> products;

  ProductsSuccess(this.products);
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}