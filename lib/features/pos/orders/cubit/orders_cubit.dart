import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';

import '../model/order_model.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());

  // 1. Get List (Summary only)
  Future<void> getOrders({String type = 'all'}) async {
    emit(OrdersLoading());
    String url = EndPoint.getAllSales; // /api/admin/pos/sales/

    if (type == 'pending') {
      url = EndPoint.getPendingSales;
    } else if (type == 'dues') {
      url = EndPoint.getDueSales;
    }

    try {
      final response = await DioHelper.getData(url: url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        List list = [];

        if (data['sales'] != null) {
          list = data['sales'];
        }

        List<OrderModel> orders = list
            .map((e) => OrderModel.fromJson(e))
            // .toList()
            // .reversed
            .toList();

        // ترتيب اختياري
        orders.sort((a, b) => b.date.compareTo(a.date));

        emit(OrdersLoaded(orders, type));
      } else {
        emit(OrdersError(response.data['message'] ?? 'Failed to load orders'));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  // 2. Get Details by ID
  Future<void> getOrderDetails(String saleId) async {
    emit(OrderDetailsLoading());
    try {
      // Endpoint: /api/admin/pos/sales/:id
      // افترضنا أن الرابط الأساسي لجلب الكل هو نفسه لجلب الواحد مع إضافة الـ ID
      // تأكد من EndPoint.getAllSales ينتهي بـ / أو لا وعدل الرابط أدناه
      final response = await DioHelper.getData(
        url: "${EndPoint.getAllSales}/$saleId",
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // نستخدم fromDetailJson لأن الرد يحتوي على sale و items
        final orderDetail = OrderModel.fromDetailJson(response.data['data']);
        emit(OrderDetailsSuccess(orderDetail));
      } else {
        emit(
          OrderDetailsError(
            response.data['message'] ?? 'Failed to load details',
          ),
        );
      }
    } catch (e) {
      emit(OrderDetailsError(e.toString()));
    }
  }
}
