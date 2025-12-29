import 'package:systego/features/POS/orders/model/order_model.dart';

// States
abstract class OrdersState {}
class OrdersInitial extends OrdersState {}

// States for List
class OrdersLoading extends OrdersState {}
class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final String type;
  OrdersLoaded(this.orders, this.type);
}
class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

// States for Details
class OrderDetailsLoading extends OrdersState {}
class OrderDetailsSuccess extends OrdersState {
  final OrderModel order;
  OrderDetailsSuccess(this.order);
}
class OrderDetailsError extends OrdersState {
  final String message;
  OrderDetailsError(this.message);
}
