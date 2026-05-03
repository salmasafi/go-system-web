import 'package:flutter_bloc/flutter_bloc.dart';
import '../../sales/data/repositories/sale_repository.dart';
import '../model/sale_model.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final SaleRepository _saleRepository;

  HistoryCubit({SaleRepository? saleRepository}) 
      : _saleRepository = saleRepository ?? SaleRepository(),
        super(HistoryInitial());

  // قوائم منفصلة للحفاظ على البيانات عند التنقل
  List<SaleItemModel> cachedSales = [];
  List<PendingSaleModel> cachedPending = [];
  List<DueSaleModel> cachedDues = [];

  // 1. Get All Sales (Completed)
  Future<void> getAllSales() async {
    emit(SalesLoading());
    try {
      final sales = await _saleRepository.getAllSales();
      cachedSales = sales;
      emit(SalesLoaded(cachedSales));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // 2. Get Pending Sales (For Pending Tab)
  Future<void> getPendingSales() async {
    emit(PendingLoading());
    try {
      final sales = await _saleRepository.getPendingSales();
      cachedPending = sales;
      emit(PendingLoaded(cachedPending));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // 3. Get Dues
  Future<void> getAllDues() async {
    emit(DuesLoading());
    try {
      final sales = await _saleRepository.getDueSales();
      cachedDues = sales;

      double totalDue = cachedDues.fold(0.0, (sum, item) => sum + item.remainingAmount);

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
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // 3b. Pay Due - supports multiple payment methods
  Future<void> payDue(String saleId, String customerId, double totalAmount, List<Map<String, dynamic>> financials) async {
    emit(DuesPayLoading(saleId));
    try {
      final success = await _saleRepository.payDue(saleId, customerId, totalAmount, financials);
      if (success) {
        emit(DuesPaySuccess(saleId));
      } else {
        emit(DuesPayError('Payment failed'));
      }
    } catch (e) {
      emit(DuesPayError(e.toString()));
    }
  }

  // 4. Get Sale Details (For Completed Sales - View Only)
  Future<void> getCompletedSaleDetails(String id) async {
    emit(SaleDetailsLoading());
    try {
      final detailModel = await _saleRepository.getSaleById(id);
      if (detailModel != null) {
        emit(SaleDetailsLoaded(detailModel));
      } else {
        emit(HistoryError('Failed to load sale details'));
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // 5. Get Pending Sale Details (New Model)
  Future<void> getPendingSaleDetails(String id) async {
    emit(SaleDetailsLoading());
    try {
      final detailModel = await _saleRepository.getPendingSaleDetails(id);
      if (detailModel != null) {
        emit(PendingDetailsSuccess(detailModel));
      } else {
        emit(HistoryError('Failed to load pending details'));
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
