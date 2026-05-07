import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/services/cache_helper.dart';
import 'package:GoSystem/features/pos/shift/model/cashier_model.dart';
import '../data/repositories/shift_repository.dart';
import '../model/shift_model.dart';

part 'pos_shift_state.dart';

class PosShiftCubit extends Cubit<PosShiftState> {
  final ShiftRepository _repository = ShiftRepository();

  PosShiftCubit() : super(PosShiftInitial()) {
    _restoreSession();
  }

  static const _cashierKey = 'pos_selected_cashier';
  static const _shiftKey = 'pos_current_shift';

  // Data
  List<CashierModel> cashiersList = [];
  CashierModel? selectedCashier;
  ShiftModel? currentShift;
  bool isShiftOpen = false;

  // استعادة الجلسة - أولاً من الكاش، ثم من قاعدة البيانات لو الكاش فاضي
  Future<void> _restoreSession() async {
    final cashier = CacheHelper.getModel<CashierModel>(
      key: _cashierKey,
      fromJson: CashierModel.fromJson,
    );
    final shift = CacheHelper.getModel<ShiftModel>(
      key: _shiftKey,
      fromJson: ShiftModel.fromJson,
    );

    if (cashier != null && shift != null && shift.status == 'open') {
      selectedCashier = cashier;
      currentShift = shift;
      isShiftOpen = true;
      emit(PosShiftStarted(shift));
      return;
    }

    // الكاش فاضي (مثلاً بعد تسجيل خروج) - نبحث في DB عن شيفت مفتوح للمستخدم الحالي
    emit(PosRestoringSession());
    try {
      final activeShift = await _repository.getMyActiveShift();
      if (activeShift == null) {
        emit(PosShiftInitial());
        return;
      }

      final cashierData = await _repository.getCashierById(activeShift.cashierId);
      if (cashierData == null) {
        emit(PosShiftInitial());
        return;
      }

      selectedCashier = cashierData;
      currentShift = activeShift.toLegacyModel();
      isShiftOpen = true;
      await _saveSession();
      emit(PosShiftStarted(currentShift!));
    } catch (e) {
      log('Restore session from server failed: $e');
      emit(PosShiftInitial());
    }
  }

  Future<void> _saveSession() async {
    if (selectedCashier != null) {
      await CacheHelper.saveModel<CashierModel>(
        key: _cashierKey,
        model: selectedCashier!,
        toJson: (c) => c.toJson(),
      );
    }
    if (currentShift != null) {
      await CacheHelper.saveModel<ShiftModel>(
        key: _shiftKey,
        model: currentShift!,
        toJson: (s) => s.toJson(),
      );
    }
  }

  Future<void> _clearSession() async {
    await CacheHelper.removeData(key: _cashierKey);
    await CacheHelper.removeData(key: _shiftKey);
  }

  // 1. Get All Cashiers
  Future<void> getCashiers() async {
    emit(PosGetCashiersLoading());
    try {
      cashiersList = await _repository.getCashiers();
      emit(PosGetCashiersSuccess(cashiersList));
    } catch (e) {
      log("Get Cashiers Error: $e");
      emit(PosGetCashiersError(e.toString()));
    }
  }

  // 2. Select Cashier - TODO: Implement with Supabase when cashier table is ready
  Future<void> selectCashier(CashierModel cashier) async {
    selectedCashier = cashier;
    await CacheHelper.saveModel<CashierModel>(
      key: _cashierKey,
      model: cashier,
      toJson: (c) => c.toJson(),
    );
    emit(PosCashierSelected(cashier));
  }

  // 3. Start Shift
  Future<void> startShift() async {
    if (selectedCashier == null) return;
    
    emit(PosShiftActionLoading());

    try {
      final shift = await _repository.startShift(
        cashierId: selectedCashier!.id,
        openingAmount: 0.0,
      );
      
      currentShift = shift.toLegacyModel();
      isShiftOpen = true;
      await _saveSession();
      
      emit(PosShiftStarted(currentShift!)); 
    } catch (e) {
      log("Start Shift Error: $e");
      emit(PosShiftActionError(e.toString()));
    }
  }

  // 4. End Shift
  Future<Map<String, dynamic>?> endShift() async {
    if (currentShift == null) return null;
    
    emit(PosShiftActionLoading());
    try {
      await _repository.endShift(
        shiftId: currentShift!.id,
        actualAmount: 0.0,
      );

      isShiftOpen = false;
      currentShift = null;
      selectedCashier = null;
      await _clearSession();

      emit(PosShiftEnded());
      return {};
    } catch (e) {
      emit(PosShiftActionError(e.toString()));
    }
    return null;
  }

  // 5. Logout Shift
  Future<void> logoutShift() async {
    emit(PosShiftActionLoading());
    try {
      // No API call needed for logout in Supabase
      emit(PosLoggedOut());
    } catch (e) {
      emit(PosShiftActionError(e.toString()));
    }
  }
}
