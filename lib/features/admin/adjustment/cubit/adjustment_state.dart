import '../model/adjustment_model.dart';

abstract class AdjustmentState {}

class AdjustmentInitial extends AdjustmentState {}

// Get All Adjustments
class GetAdjustmentsLoading extends AdjustmentState {}
class GetAdjustmentsSuccess extends AdjustmentState {
  final AdjustmentData adjustmentData;
  GetAdjustmentsSuccess(this.adjustmentData);
}
class GetAdjustmentsError extends AdjustmentState {
  final String error;
  GetAdjustmentsError(this.error);
}

// Create Adjustment
class CreateAdjustmentLoading extends AdjustmentState {}
class CreateAdjustmentSuccess extends AdjustmentState {
  final String message;
  CreateAdjustmentSuccess(this.message);
}
class CreateAdjustmentError extends AdjustmentState {
  final String error;
  CreateAdjustmentError(this.error);
}

// Update Adjustment
class UpdateAdjustmentLoading extends AdjustmentState {}
class UpdateAdjustmentSuccess extends AdjustmentState {
  final String message;
  UpdateAdjustmentSuccess(this.message);
}
class UpdateAdjustmentError extends AdjustmentState {
  final String error;
  UpdateAdjustmentError(this.error);
}

// Delete Adjustment
class DeleteAdjustmentLoading extends AdjustmentState {}
class DeleteAdjustmentSuccess extends AdjustmentState {
  final String message;
  DeleteAdjustmentSuccess(this.message);
}
class DeleteAdjustmentError extends AdjustmentState {
  final String error;
  DeleteAdjustmentError(this.error);
}