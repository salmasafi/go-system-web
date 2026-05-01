import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/online_orders_repository.dart';
import '../model/online_order_model.dart';

part 'online_orders_state.dart';

class OnlineOrdersCubit extends Cubit<OnlineOrdersState> {
  final OnlineOrdersRepository _repository = OnlineOrdersRepository();

  OnlineOrdersCubit() : super(OnlineOrdersInitial());

  List<OnlineOrderModel> _all = [];
  List<OnlineOrderModel> _filtered = [];
  String _searchQuery = '';
  String _statusFilter = '';

  List<OnlineOrderModel> get displayed => _filtered;
  int get totalCount => _all.length;

  static const List<String> statuses = [
    'pending',
    'confirmed',
    'processing',
    'out_for_delivery',
    'delivered',
    'returned',
    'failed_to_deliver',
    'canceled',
    'scheduled',
    'refund',
  ];

  Future<void> fetchOrders() async {
    emit(OnlineOrdersLoading());
    try {
      _all = await _repository.getAllOrders();
      _applyFilters();
      emit(OnlineOrdersLoaded(displayed, totalCount));
    } catch (e) {
      log('OnlineOrdersCubit.fetchOrders error: $e');
      _all = [];
      _filtered = [];
      emit(OnlineOrdersLoaded([], 0));
    }
  }

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    emit(OnlineOrdersLoaded(displayed, totalCount));
  }

  void filterByStatus(String status) {
    _statusFilter = status;
    _applyFilters();
    emit(OnlineOrdersLoaded(displayed, totalCount));
  }

  void _applyFilters() {
    _filtered = _all.where((o) {
      final matchSearch = _searchQuery.isEmpty ||
          o.orderNumber.toLowerCase().contains(_searchQuery) ||
          o.customerName.toLowerCase().contains(_searchQuery) ||
          o.branch.toLowerCase().contains(_searchQuery);
      final matchStatus =
          _statusFilter.isEmpty || o.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
  }
}
