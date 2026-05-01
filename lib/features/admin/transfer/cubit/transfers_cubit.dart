import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../model/transfer_model.dart'; 
import 'package:systego/features/admin/transfer/data/repositories/transfer_repository.dart';

part 'transfers_state.dart';

class TransfersCubit extends Cubit<TransfersState> {
  final TransferRepository _repository;
  TransfersCubit(this._repository) : super(TransfersInitial());

  // 1. Get All Transfers (History Tab)
  Future<void> getAllTransfers() async {
    emit(GetTransfersLoading());
    try {
      final transfers = await _repository.getAllTransfers();
      final legacyModels = transfers.map((e) => e.toLegacyModel()).toList();
      emit(GetTransfersSuccess(legacyModels));
    } catch (e) {
      emit(GetTransfersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // 2. Get Incoming Transfers (Incoming Tab)
  Future<void> getIncomingTransfers(String warehouseId) async {
    emit(GetIncomingLoading());
    try {
      final transfers = await _repository.getIncomingTransfers(warehouseId);
      final legacyModels = transfers.map((e) => e.toLegacyModel()).toList();
      emit(GetIncomingSuccess(legacyModels));
    } catch (e) {
      emit(GetIncomingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // 3. Get Outgoing Transfers (Outgoing Tab)
  Future<void> getOutgoingTransfers(String warehouseId) async {
    emit(GetOutgoingLoading());
    try {
      final transfers = await _repository.getOutgoingTransfers(warehouseId);
      final legacyModels = transfers.map((e) => e.toLegacyModel()).toList();
      emit(GetOutgoingSuccess(legacyModels));
    } catch (e) {
      emit(GetOutgoingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // 4. Create Transfer
  Future<void> createTransfer({
    required String fromId,
    required String toId,
    required List<Map<String, dynamic>> products,
  }) async {
    emit(CreateTransferLoading());
    try {
      await _repository.createTransfer(
        fromWarehouseId: fromId,
        toWarehouseId: toId,
        items: products,
      );
      emit(CreateTransferSuccess(LocaleKeys.transfer_created_success.tr()));
    } catch (e) {
      emit(CreateTransferError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // 5. Approve/Receive Transfer
  Future<void> approveTransfer(String transferId) async {
    emit(UpdateTransferStatusLoading());
    try {
      final success = await _repository.approveTransfer(transferId);
      if (success) {
        emit(UpdateTransferStatusSuccess(LocaleKeys.transfer_received_success.tr()));
        getAllTransfers();
      } else {
        emit(UpdateTransferStatusError('Failed to approve transfer'));
      }
    } catch (e) {
      emit(UpdateTransferStatusError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // 6. Mark as Received (UI alias for approveTransfer)
  Future<void> markAsReceived({
    required String transferId,
    required String warehouseId,
  }) async {
    await approveTransfer(transferId);
  }
}
