import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../model/pending_sale_details_model.dart';
import '../model/sale_model.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial());

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
        //cachedSales = cachedSales.reversed.toList();

        emit(SalesLoaded(cachedSales));
      } else {
        emit(HistoryError('Failed to load sales'));
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
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
        // cachedPending = cachedPending.reversed.toList();
        emit(PendingLoaded(cachedPending));
      } else {
        emit(HistoryError('Failed to load pending sales'));
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // 3. Get Dues
  Future<void> getAllDues() async {
    emit(DuesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getDueSales);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List list = data['sales'] ?? [];
        double totalDue = (data['total_due'] as num?)?.toDouble() ?? 0.0;

        cachedDues = list.map((e) => DueSaleModel.fromJson(e)).toList();

        // Group by customer
        final Map<String, List<DueSaleModel>> grouped = {};
        for (final sale in cachedDues) {
          grouped.putIfAbsent(sale.customerId, () => []).add(sale);
        }

        final customers = grouped.entries.map((e) {
          final sales = e.value;
          final first = sales.first;
          final total = sales.fold(0.0, (s, d) => s + d.remainingAmount);
          return CustomerDueModel(
            customerId: first.customerId,
            customerName: first.customerName,
            phone: first.phone,
            totalDue: total,
            sales: sales,
          );
        }).toList();

        emit(DuesLoaded(customers, totalDue));
      } else {
        emit(HistoryError('Failed to load dues'));
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // 3b. Pay Due - supports multiple payment methods
  Future<void> payDue(String saleId, String customerId, double totalAmount, List<Map<String, dynamic>> financials) async {
    emit(DuesPayLoading(saleId));
    try {
      final response = await DioHelper.postData(
        url: EndPoint.payDue,
        data: {
          'sale_id': saleId,
          'customer_id': customerId,
          'amount': totalAmount,
          'financials': financials,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DuesPaySuccess(saleId));
      } else {
        final msg = response.data['message']?.toString() ?? 'Payment failed';
        emit(DuesPayError(msg));
      }
    } catch (e) {
      emit(DuesPayError(e.toString()));
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
        url: "${EndPoint.getAllSales}/$id",
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // نستخدم نفس الموديل SaleDetailModel لأنه يطابق هيكلية الرد
        final detailModel = SaleDetailModel.fromJson(response.data['data']);
        emit(SaleDetailsLoaded(detailModel));
      } else {
        emit(
          HistoryError(
            response.data['message'] ?? 'Failed to load sale details',
          ),
        );
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // 5. Get Pending Sale Details (New Model)
  Future<void> getPendingSaleDetails(String id) async {
    emit(SaleDetailsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPendingSaleDetails(id),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final detailModel = PendingSaleDetailsModel.fromJson(
          response.data['data'],
        );
        emit(PendingDetailsSuccess(detailModel));
      } else {
        emit(
          HistoryError(
            response.data['message'] ?? 'Failed to load pending details',
          ),
        );
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
