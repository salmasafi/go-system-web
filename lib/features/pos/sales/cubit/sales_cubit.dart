import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../model/sale_model.dart';
import 'sales_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());

  // قوائم منفصلة للحفاظ على البيانات عند التنقل
  List<SaleItemModel> cachedSales = [];
  List<PendingSaleModel> cachedPending = [];
  List<DueSaleModel> cachedDues = [];

  // 1. Get All Sales (Completed)
  Future<void> getAllSales() async {
    emit(SalesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllSales);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data']['sales'] ?? [];
        cachedSales = list.map((e) => SaleItemModel.fromJson(e)).toList();
        emit(SalesLoaded(cachedSales));
      } else {
        emit(OrdersError('Failed to load sales'));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  // 2. Get Pending Sales (For Pending Tab)
  Future<void> getPendingSales() async {
    emit(PendingLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getPendingSales);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data']['sales'] ?? [];
        cachedPending = list.map((e) => PendingSaleModel.fromJson(e)).toList();
        emit(PendingLoaded(cachedPending));
      } else {
        emit(OrdersError('Failed to load pending sales'));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  // 3. Get Dues (For Dues Tab)
  Future<void> getAllDues() async {
    emit(DuesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getDueSales);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List list = data['sales'] ?? [];
        double totalDue = (data['total_due'] as num?)?.toDouble() ?? 0.0;

        cachedDues = list.map((e) => DueSaleModel.fromJson(e)).toList();
        emit(DuesLoaded(cachedDues, totalDue));
      } else {
        emit(OrdersError('Failed to load dues'));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  // ... (باقي الكود السابق كما هو)

  // 4. Get Sale Details (For Completed Sales - View Only)
  Future<void> getCompletedSaleDetails(String id) async {
    emit(SaleDetailsLoading());
    try {
      // Endpoint: /api/admin/pos/sales/:id
      // نستخدم getAllSales لأنه الرابط الأساسي للـ sales
      final response = await DioHelper.getData(
        url: "${EndPoint.getAllSales}$id",
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // نستخدم نفس الموديل SaleDetailModel لأنه يطابق هيكلية الرد
        final detailModel = SaleDetailModel.fromJson(response.data['data']);
        emit(SaleDetailsLoaded(detailModel));
      } else {
        emit(
          OrdersError(
            response.data['message'] ?? 'Failed to load sale details',
          ),
        );
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
