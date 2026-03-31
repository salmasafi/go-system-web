part of 'online_orders_cubit.dart';

abstract class OnlineOrdersState {}

class OnlineOrdersInitial extends OnlineOrdersState {}

class OnlineOrdersLoading extends OnlineOrdersState {}

class OnlineOrdersLoaded extends OnlineOrdersState {
  final List<OnlineOrderModel> orders;
  final int totalCount;
  OnlineOrdersLoaded(this.orders, this.totalCount);
}

class OnlineOrdersError extends OnlineOrdersState {
  final String message;
  OnlineOrdersError(this.message);
}
