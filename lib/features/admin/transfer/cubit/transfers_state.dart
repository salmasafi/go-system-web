part of 'transfers_cubit.dart';

@immutable
sealed class TransfersState {}

final class TransfersInitial extends TransfersState {}

// --- All Transfers States ---
final class GetTransfersLoading extends TransfersState {}
final class GetTransfersSuccess extends TransfersState {
  final List<TransferModel> transfers;
  GetTransfersSuccess(this.transfers);
}
final class GetTransfersError extends TransfersState {
  final String error;
  GetTransfersError(this.error);
}

// --- Incoming States ---
final class GetIncomingLoading extends TransfersState {}
final class GetIncomingSuccess extends TransfersState {
  final List<TransferModel> transfers;
  GetIncomingSuccess(this.transfers);
}
final class GetIncomingError extends TransfersState {
  final String error;
  GetIncomingError(this.error);
}

// --- Outgoing States ---
final class GetOutgoingLoading extends TransfersState {}
final class GetOutgoingSuccess extends TransfersState {
  final List<TransferModel> transfers;
  GetOutgoingSuccess(this.transfers);
}
final class GetOutgoingError extends TransfersState {
  final String error;
  GetOutgoingError(this.error);
}

// --- Action States (Create / Update) ---
final class CreateTransferLoading extends TransfersState {}
final class CreateTransferSuccess extends TransfersState {
  final String message;
  CreateTransferSuccess(this.message);
}
final class CreateTransferError extends TransfersState {
  final String error;
  CreateTransferError(this.error);
}

final class UpdateTransferStatusLoading extends TransfersState {}
final class UpdateTransferStatusSuccess extends TransfersState {
  final String message;
  UpdateTransferStatusSuccess(this.message);
}
final class UpdateTransferStatusError extends TransfersState {
  final String error;
  UpdateTransferStatusError(this.error);
}
