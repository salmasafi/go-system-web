import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import '../model/purchase_return_model.dart';

import 'package:systego/features/admin/purchase_returns/data/repositories/purchase_return_repository.dart';

part 'purchase_return_state.dart';


class PurchaseReturnCubit extends Cubit<PurchaseReturnState> {
  final PurchaseReturnRepository _repository;
  PurchaseReturnCubit(this._repository) : super(PurchaseReturnInitial());

  List<PurchaseReturnModel> returns = [];

  Future<void> getReturns() async {
    emit(GetReturnsLoading());
    try {
      final list = await _repository.getAllReturns();
      returns = list;
      final data = PurchaseReturnData(returns: list, totalReturns: list.length, totalAmount: 0.0);
      emit(GetReturnsSuccess(data));
    } catch (e) {
      emit(GetReturnsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> searchPurchaseByReference(String reference) async {
    emit(SearchPurchaseLoading());
    try {
      final purchase = await _repository.getPurchaseByReference(reference.trim());
      if (purchase == null) {
        emit(SearchPurchaseError('No purchase found with reference: $reference'));
        return;
      }
      emit(SearchPurchaseSuccess(purchase));
    } catch (e) {
      emit(SearchPurchaseError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createReturn({
    required String purchaseId,
    required String note,
    required String refundMethod,
    required String refundAccountId,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(CreateReturnLoading());
    try {
      await _repository.createReturn(
        purchaseId: purchaseId,
        note: note,
        refundMethod: refundMethod,
        refundAccountId: refundAccountId,
        items: items,
      );
      emit(CreateReturnSuccess('Return created successfully'));
      await getReturns();
    } catch (e) {
      emit(CreateReturnError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateReturn({
    required String id,
    required String note,
    required String refundMethod,
  }) async {
    emit(UpdateReturnLoading());
    try {
      await _repository.updateReturn(
        id: id,
        note: note,
        refundMethod: refundMethod,
      );
      emit(UpdateReturnSuccess('Return updated successfully'));
      await getReturns();
    } catch (e) {
      emit(UpdateReturnError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteReturn(String id) async {
    emit(DeleteReturnLoading());
    try {
      await _repository.deleteReturn(id);
      returns.removeWhere((r) => r.id == id);
      emit(DeleteReturnSuccess('Return deleted successfully'));
      await getReturns();
    } catch (e) {
      emit(DeleteReturnError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
