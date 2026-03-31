import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../model/online_order_model.dart';

part 'online_orders_state.dart';

class OnlineOrdersCubit extends Cubit<OnlineOrdersState> {
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
      final response = await DioHelper.getData(url: EndPoint.getOnlineOrders);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data']['orders'] as List? ?? [];
        _all = list.map((e) => OnlineOrderModel.fromJson(e)).toList();
        _applyFilters();
        emit(OnlineOrdersLoaded(displayed, totalCount));
      } else {
        _all = [];
        _filtered = [];
        emit(OnlineOrdersLoaded([], 0));
      }
    } catch (e) {
      log('OnlineOrdersCubit.fetchOrders error: $e');
      // 404 = endpoint not ready yet — show empty state gracefully
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
