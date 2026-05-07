import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/features/admin/cashier/model/cashirer_model.dart';
import 'package:GoSystem/features/admin/cashier/data/repositories/cashier_repository.dart';

part 'cashier_state.dart';

class CashierCubit extends Cubit<CashierState> {
  final CashierRepository _repository;
  CashierCubit(this._repository) : super(CashierInitial());

  List<CashierModel> allCashiers = [];

  Future<void> getCashiers() async {
    emit(GetCashiersLoading());
    try {
      final cashiersList = await _repository.getAllCashiers();
      allCashiers = cashiersList;
      emit(GetCashiersSuccess(cashiersList));
    } catch (e) {
      emit(GetCashiersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCashier({
    required String name,
    String? warehouseId,
    required bool status,
  }) async {
    emit(CreateCashierLoading());
    try {
      await _repository.createCashier(
        name: name,
        warehouseId: warehouseId,
        status: status,
      );
      emit(CreateCashierSuccess(LocaleKeys.cashier_created_success.tr()));
      await getCashiers();
    } catch (e) {
      emit(CreateCashierError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCashier({
    required String cashierId,
    required String name,
    String? warehouseId,
    required bool status,
  }) async {
    emit(UpdateCashierLoading());
    try {
      await _repository.updateCashier(
        id: cashierId,
        name: name,
        warehouseId: warehouseId,
        status: status,
      );
      emit(UpdateCashierSuccess(LocaleKeys.cashier_updated_success.tr()));
      await getCashiers();
    } catch (e) {
      emit(UpdateCashierError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCashier(String cashierId) async {
    emit(DeleteCashierLoading());
    try {
      await _repository.deleteCashier(cashierId);
      emit(DeleteCashierSuccess(LocaleKeys.cashier_deleted_success.tr()));
      await getCashiers();
    } catch (e) {
      emit(DeleteCashierError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

  // // Additional method to toggle cashier active status
  // Future<void> toggleCashierStatus({
  //   required String cashierId,
  //   required bool isActive,
  // }) async {
  //   emit(ToggleCashierStatusLoading());

  //   try {
  //     final data = {
  //       "cashier_active": isActive,
  //     };

  //     final response = await DioHelper.patchData(
  //       url: EndPoint.toggleCashierStatus(cashierId),
  //       data: data,
  //     );

  //     if (response.statusCode == 200) {
  //       // Update the local cashier list
  //       final index = allCashiers.indexWhere((c) => c.id == cashierId);
  //       if (index != -1) {
  //         allCashiers[index] = allCashiers[index].copyWith(
  //           cashierActive: isActive,
  //           updatedAt: DateTime.now().toIso8601String(),
  //         );
  //       }
  //       emit(ToggleCashierStatusSuccess(isActive));
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(ToggleCashierStatusError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(ToggleCashierStatusError(errorMessage));
  //   }
  // }

  // // Optional: Add methods to manage users and bank accounts for cashiers
  // Future<void> assignUserToCashier({
  //   required String cashierId,
  //   required String userId,
  // }) async {
  //   emit(AssignUserLoading());

  //   try {
  //     final data = {
  //       "user_id": userId,
  //     };

  //     final response = await DioHelper.postData(
  //       url: EndPoint.assignUserToCashier(cashierId),
  //       data: data,
  //     );

  //     if (response.statusCode == 200) {
  //       emit(AssignUserSuccess(LocaleKeys.user_assigned_success.tr()));
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(AssignUserError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(AssignUserError(errorMessage));
  //   }
  // }

  // Future<void> removeUserFromCashier({
  //   required String cashierId,
  //   required String userId,
  // }) async {
  //   emit(RemoveUserLoading());

  //   try {
  //     final response = await DioHelper.deleteData(
  //       url: EndPoint.removeUserFromCashier(cashierId, userId),
  //     );

  //     if (response.statusCode == 200) {
  //       emit(RemoveUserSuccess(LocaleKeys.user_removed_success.tr()));
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(RemoveUserError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(RemoveUserError(errorMessage));
  //   }
  // }
//}
