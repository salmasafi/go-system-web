
// States
import '../model/sale_model.dart';

abstract class OrdersState {}
class OrdersInitial extends OrdersState {}

class SalesLoading extends OrdersState {}
class SalesLoaded extends OrdersState {
  final List<SaleItemModel> sales;
  SalesLoaded(this.sales);
}

class PendingLoading extends OrdersState {}
class PendingLoaded extends OrdersState {
  final List<PendingSaleModel> pendingSales;
  PendingLoaded(this.pendingSales);
}

class DuesLoading extends OrdersState {}
class DuesLoaded extends OrdersState {
  final List<DueSaleModel> dueSales;
  final double totalDueAmount;
  DuesLoaded(this.dueSales, this.totalDueAmount);
}

class SaleDetailsLoading extends OrdersState {}
class SaleDetailsLoaded extends OrdersState {
  final SaleDetailModel details;
  SaleDetailsLoaded(this.details);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

