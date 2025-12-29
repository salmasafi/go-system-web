import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';

// تأكد من استيراد ملف الموديل الجديد الذي أنشأناه بالأعلى
import 'package:systego/features/pos/cashier/model/cashier_model.dart'; 

part 'pos_cashier_state.dart';

class PosCashierCubit extends Cubit<PosCashierState> {
  PosCashierCubit() : super(PosCashierInitial());

  List<CashierModel> allCashiers = [];
  CashierModel? selectedCashier;

  Future<void> getCashiers() async {
    emit(PosGetCashiersLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllCashiers);
      log("Cashiers Response: ${response.data.toString()}");

      if (response.statusCode == 200) {
        // التأكد من أن الرد يحتوي على success: true
        if (response.data['success'] == true) {
          final model = CashierResponse.fromJson(response.data);
          
          allCashiers = model.data.cashiers;
          
          if (allCashiers.isEmpty) {
            log("No cashiers found in the list");
          }

          emit(PosGetCashiersSuccess(allCashiers));
        } else {
          // في حال كان الرد 200 ولكن success: false
          emit(PosGetCashiersError(response.data['message'] ?? "Unknown Error"));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(PosGetCashiersError(errorMessage));
      }
    } catch (e) {
      log("Error fetching cashiers: $e");
      // التعامل مع الخطأ بشكل عام
      // إذا كان الخطأ من نوع DioError يمكن استخدام ErrorHandler
      // هنا نرسل النص مباشرة للتبسيط
      emit(PosGetCashiersError(e.toString()));
    }
  }

  void selectCashier(CashierModel cashier) {
    selectedCashier = cashier;
    emit(PosCashierSelected(cashier));
  }
}