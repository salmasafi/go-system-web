import '../model/reason_model.dart';

abstract class ReasonState {}

class ReasonInitial extends ReasonState {}

// Get All Reasons
class GetReasonsLoading extends ReasonState {}

class GetReasonsSuccess extends ReasonState {
  final ReasonData reasonData;
  GetReasonsSuccess(this.reasonData);
}

class GetReasonsError extends ReasonState {
  final String error;
  GetReasonsError(this.error);
}

// Create Reason
class CreateReasonLoading extends ReasonState {}

class CreateReasonSuccess extends ReasonState {
  final String message;
  CreateReasonSuccess(this.message);
}

class CreateReasonError extends ReasonState {
  final String error;
  CreateReasonError(this.error);
}

// Update Reason
class UpdateReasonLoading extends ReasonState {}

class UpdateReasonSuccess extends ReasonState {
  final String message;
  UpdateReasonSuccess(this.message);
}

class UpdateReasonError extends ReasonState {
  final String error;
  UpdateReasonError(this.error);
}

// Delete Reason
class DeleteReasonLoading extends ReasonState {}

class DeleteReasonSuccess extends ReasonState {
  final String message;
  DeleteReasonSuccess(this.message);
}

class DeleteReasonError extends ReasonState {
  final String error;
  DeleteReasonError(this.error);
}