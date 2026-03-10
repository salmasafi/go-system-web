import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../model/transfer_model.dart'; // Import your model

part 'transfers_state.dart';

class TransfersCubit extends Cubit<TransfersState> {
  TransfersCubit() : super(TransfersInitial());

  // 1. Get All Transfers (History Tab)
  Future<void> getAllTransfers() async {
    emit(GetTransfersLoading());
    try {
      final response = await DioHelper.getData(url: '/api/admin/transfer'); // Use EndPoint.allTransfers
      
      if (response.statusCode == 200) {
        final model = TransferResponse.fromJson(response.data);
        if (model.success) {
          emit(GetTransfersSuccess(model.data.allTransfers));
        } else {
          emit(GetTransfersError(model.data.message));
        }
      } else {
        emit(GetTransfersError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(GetTransfersError(ErrorHandler.handleError(e)));
    }
  }

  // 2. Get Incoming Transfers (Incoming Tab)
  Future<void> getIncomingTransfers(String warehouseId) async {
    emit(GetIncomingLoading());
    try {
      // Assuming EndPoint structure: /api/admin/transfer/gettransferin/$id
      final response = await DioHelper.getData(
        url: '/api/admin/transfer/gettransferin/$warehouseId', 
      );
      
      if (response.statusCode == 200) {
        final model = TransferResponse.fromJson(response.data);
        if (model.success) {
          // We combine pending and done for display, or you can separate them in UI
          emit(GetIncomingSuccess(model.data.combinedFiltered)); 
        } else {
          emit(GetIncomingError(model.data.message));
        }
      } else {
        emit(GetIncomingError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(GetIncomingError(ErrorHandler.handleError(e)));
    }
  }

  // 3. Get Outgoing Transfers (Outgoing Tab)
  Future<void> getOutgoingTransfers(String warehouseId) async {
    emit(GetOutgoingLoading());
    try {
       // Assuming EndPoint structure: /api/admin/transfer/gettransferout/$id
      final response = await DioHelper.getData(
        url: '/api/admin/transfer/gettransferout/$warehouseId',
      );
      
      if (response.statusCode == 200) {
        final model = TransferResponse.fromJson(response.data);
        if (model.success) {
          emit(GetOutgoingSuccess(model.data.combinedFiltered));
        } else {
          emit(GetOutgoingError(model.data.message));
        }
      } else {
        emit(GetOutgoingError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(GetOutgoingError(ErrorHandler.handleError(e)));
    }
  }

  // 4. Create Transfer
  Future<void> createTransfer({
    required String fromId,
    required String toId,
    required List<Map<String, dynamic>> products, // [{productId: "...", quantity: 5}]
  }) async {
    emit(CreateTransferLoading());
    try {
      final data = {
        'fromWarehouseId': fromId,
        'toWarehouseId': toId,
        'products': products,
        // Add other required fields if necessary
      };

      final response = await DioHelper.postData(
        url: '/api/admin/transfer',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateTransferSuccess(LocaleKeys.transfer_created_success.tr()));
      } else {
        emit(CreateTransferError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(CreateTransferError(ErrorHandler.handleError(e)));
    }
  }

  // 5. Mark Transfer as Received (PUT)
  Future<void> markAsReceived({
    required String transferId,
    required String warehouseId, // The ID of the warehouse receiving the items
  }) async {
    emit(UpdateTransferStatusLoading());
    try {
      final data = {
        "warehouseId": warehouseId,
        "status": "received" // API expects this
      };

      final response = await DioHelper.putData(
        url: '/api/admin/transfer/$transferId', 
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateTransferStatusSuccess(LocaleKeys.transfer_received_success.tr()));
        // Trigger a refresh of incoming list after success
        getIncomingTransfers(warehouseId);
      } else {
        emit(UpdateTransferStatusError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(UpdateTransferStatusError(ErrorHandler.handleError(e)));
    }
  }
}