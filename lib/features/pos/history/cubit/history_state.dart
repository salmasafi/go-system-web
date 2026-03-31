// States
import '../model/pending_sale_details_model.dart';
import '../model/sale_model.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class SalesLoading extends HistoryState {}

class SalesLoaded extends HistoryState {
  final List<SaleItemModel> sales;
  SalesLoaded(this.sales);
}

class PendingLoading extends HistoryState {}

class PendingLoaded extends HistoryState {
  final List<PendingSaleModel> pendingSales;
  PendingLoaded(this.pendingSales);
}

class DuesLoading extends HistoryState {}

class DuesLoaded extends HistoryState {
  final List<CustomerDueModel> customers;
  final double totalDueAmount;
  DuesLoaded(this.customers, this.totalDueAmount);
}

class DuesPayLoading extends HistoryState {
  final String saleId;
  DuesPayLoading(this.saleId);
}

class DuesPaySuccess extends HistoryState {
  final String saleId;
  DuesPaySuccess(this.saleId);
}

class DuesPayError extends HistoryState {
  final String message;
  DuesPayError(this.message);
}

class SaleDetailsLoading extends HistoryState {}

class SaleDetailsLoaded extends HistoryState {
  final SaleDetailModel details;
  SaleDetailsLoaded(this.details);
}

class PendingDetailsSuccess extends HistoryState {
  final PendingSaleDetailsModel details;
  PendingDetailsSuccess(this.details);
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}
