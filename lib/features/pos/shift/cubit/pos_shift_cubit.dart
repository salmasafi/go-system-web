import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/POS/shift/model/cashier_model.dart'; // تأكد من المسار
import '../model/shift_model.dart'; // تأكد من المسار

part 'pos_shift_state.dart';

class PosShiftCubit extends Cubit<PosShiftState> {
  PosShiftCubit() : super(PosShiftInitial());

  // Data
  List<CashierModel> cashiersList = [];
  CashierModel? selectedCashier;
  ShiftModel? currentShift;
  bool isShiftOpen = false;

  // 1. Get All Cashiers
  Future<void> getCashiers() async {
    emit(PosGetCashiersLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllCashiers);
      
      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final model = CashierResponse.fromJson(response.data);
          cashiersList = model.data.cashiers;
          emit(PosGetCashiersSuccess(cashiersList));
        } else {
          emit(PosGetCashiersError(response.data['message'] ?? "Unknown Error"));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(PosGetCashiersError(errorMessage));
      }
    } catch (e) {
      log("Error fetching cashiers: $e");
      emit(PosGetCashiersError(e.toString()));
    }
  }

  // 2. Select Cashier
  Future<void> selectCashier(CashierModel cashier) async {
    emit(PosSelectCashierLoading());
    try {
      final response = await DioHelper.postData(
        url: EndPoint.selectCashier,
        data: {"cashier_id": cashier.id},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          selectedCashier = cashier;
          emit(PosCashierSelected(cashier));
        } else {
          emit(PosSelectCashierError(response.data['message'] ?? "Failed to select cashier"));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(PosSelectCashierError(errorMessage));
      }
    } catch (e) {
      log("Error selecting cashier: $e");
      emit(PosSelectCashierError(e.toString()));
    }
  }

  // 3. Start Shift
  Future<void> startShift() async {
    if (selectedCashier == null) return;
    
    emit(PosShiftActionLoading()); // استخدمنا State عام للتحميل

    try {
      final response = await DioHelper.postData(
        url: EndPoint.startShift,
        data: {'cashier_id': selectedCashier!.id},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        currentShift = ShiftModel.fromJson(response.data['data']['shift']);
        isShiftOpen = true;
        
        // ❌ حذفنا await loadPosData(); لأنها في الكيوبت الآخر
        // ✅ نرسل State نجاح، والواجهة ستستجيب
        emit(PosShiftStarted(currentShift!)); 
      } else {
        emit(PosShiftActionError(response.data['message'] ?? 'Failed to start shift'));
      }
    } catch (e) {
      log("Start Shift Error: $e");
      emit(PosShiftActionError(e.toString()));
    }
  }

  // 4. End Shift
  Future<Map<String, dynamic>?> endShift() async {
    emit(PosShiftActionLoading());
    try {
      final response = await DioHelper.putData(
        url: EndPoint.endShift,
        data: {}, // أضف cash_in_drawer هنا إذا لزم الأمر
      );

      if (response.statusCode == 200) {
        isShiftOpen = false;
        currentShift = null;
        selectedCashier = null; // إعادة تعيين الكاشير

        emit(PosShiftEnded());
        return response.data; // إرجاع البيانات لاستخدامها في UI (تقرير)
      } else {
        emit(PosShiftActionError('Failed to end shift'));
      }
    } catch (e) {
      emit(PosShiftActionError(e.toString()));
    }
    return null;
  }

  // 5. Logout Shift
  Future<void> logoutShift() async {
    emit(PosShiftActionLoading());
    try {
      await DioHelper.postData(url: EndPoint.logoutShift, data: {});
      emit(PosLoggedOut());
    } catch (e) {
      emit(PosShiftActionError(e.toString()));
    }
  }
}