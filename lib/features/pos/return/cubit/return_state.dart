import '../models/return_item_model.dart';
import '../models/return_sale_model.dart';

abstract class ReturnState {}

class ReturnInitial extends ReturnState {}

class ReturnSearchLoading extends ReturnState {}

class ReturnSaleLoaded extends ReturnState {
  final ReturnSaleModel sale;
  final List<ReturnItemModel> items;
  ReturnSaleLoaded({required this.sale, required this.items});
}

class ReturnSearchError extends ReturnState {
  final String message;
  ReturnSearchError(this.message);
}

class ReturnSubmitting extends ReturnState {
  final ReturnSaleModel sale;
  final List<ReturnItemModel> items;
  ReturnSubmitting({required this.sale, required this.items});
}

class ReturnSubmitSuccess extends ReturnState {}

class ReturnSubmitError extends ReturnState {
  final ReturnSaleModel sale;
  final List<ReturnItemModel> items;
  final String message;
  ReturnSubmitError({required this.sale, required this.items, required this.message});
}
