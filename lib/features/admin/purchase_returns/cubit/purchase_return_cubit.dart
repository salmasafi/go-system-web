import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import '../model/purchase_return_model.dart';

part 'purchase_return_state.dart';

class PurchaseReturnCubit extends Cubit<PurchaseReturnState> {
  PurchaseReturnCubit() : super(PurchaseReturnInitial());

  List<PurchaseReturnModel> returns = [];

  Future<void> getReturns() async {
    emit(GetReturnsLoading());
    try {
      final response =
          await DioHelper.getData(url: EndPoint.getAllPurchaseReturns);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = PurchaseReturnData.fromJson(response.data['data']);
        returns = data.returns;
        emit(GetReturnsSuccess(data));
      } else {
        emit(GetReturnsError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(GetReturnsError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> searchPurchaseByReference(String reference) async {
    emit(SearchPurchaseLoading());
    try {
      final response = await DioHelper.getData(
          url: EndPoint.getPurchaseByReference(reference.trim()));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        // purchases come in full/later/partial lists - merge all
        final allPurchases = [
          ...(data['purchases']?['full'] as List? ?? []),
          ...(data['purchases']?['later'] as List? ?? []),
          ...(data['purchases']?['partial'] as List? ?? []),
        ];
        if (allPurchases.isEmpty) {
          emit(SearchPurchaseError('No purchase found with reference: $reference'));
          return;
        }
        final purchase = allPurchases.first as Map<String, dynamic>;
        emit(SearchPurchaseSuccess(purchase));
      } else {
        emit(SearchPurchaseError(
            response.data['message']?.toString() ?? 'Purchase not found'));
      }
    } catch (e) {
      emit(SearchPurchaseError(ErrorHandler.handleError(e)));
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
      final response = await DioHelper.postData(
        url: EndPoint.createPurchaseReturn,
        data: {
          'purchase_id': purchaseId,
          'note': note,
          'refund_method': refundMethod,
          'refund_account_id': refundAccountId,
          'items': items,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateReturnSuccess('Return created successfully'));
        await getReturns();
      } else {
        emit(CreateReturnError(
            response.data['message']?.toString() ?? 'Failed'));
      }
    } catch (e) {
      emit(CreateReturnError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> updateReturn({
    required String id,
    required String note,
    required String refundMethod,
  }) async {
    emit(UpdateReturnLoading());
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updatePurchaseReturn(id),
        data: {'note': note, 'refund_method': refundMethod},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UpdateReturnSuccess('Return updated successfully'));
        await getReturns();
      } else {
        emit(UpdateReturnError(
            response.data['message']?.toString() ?? 'Failed'));
      }
    } catch (e) {
      emit(UpdateReturnError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> deleteReturn(String id) async {
    emit(DeleteReturnLoading());
    try {
      final response =
          await DioHelper.deleteData(url: EndPoint.deletePurchaseReturn(id));
      if (response.statusCode == 200) {
        returns.removeWhere((r) => r.id == id);
        emit(DeleteReturnSuccess('Return deleted successfully'));
        await getReturns();
      } else {
        emit(DeleteReturnError(
            response.data['message']?.toString() ?? 'Failed'));
      }
    } catch (e) {
      emit(DeleteReturnError(ErrorHandler.handleError(e)));
    }
  }
}
