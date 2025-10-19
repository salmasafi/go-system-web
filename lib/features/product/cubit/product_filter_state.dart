// cubit/product_filters_state.dart
import 'package:systego/features/product/data/models/filter_models.dart';

abstract class ProductFiltersState {}

class ProductFiltersInitial extends ProductFiltersState {}

class ProductFiltersLoading extends ProductFiltersState {}

class ProductFiltersSuccess extends ProductFiltersState {
  final ProductFiltersModel filters;

  ProductFiltersSuccess(this.filters);
}

class ProductFiltersError extends ProductFiltersState {
  final String message;

  ProductFiltersError(this.message);
}