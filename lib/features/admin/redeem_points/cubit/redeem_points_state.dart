part of 'redeem_points_cubit.dart';

abstract class RedeemPointsState {}

class RedeemPointsInitial extends RedeemPointsState {}

class GetRedeemPointsLoading extends RedeemPointsState {}

class GetRedeemPointsSuccess extends RedeemPointsState {
  final List<RedeemPointsModel> redeemPoints;

  GetRedeemPointsSuccess(this.redeemPoints);
}

class GetRedeemPointsError extends RedeemPointsState {
  final String error;

  GetRedeemPointsError(this.error);
}

class CreateRedeemPointsLoading extends RedeemPointsState {}

class CreateRedeemPointsSuccess extends RedeemPointsState {
  final String message;

  CreateRedeemPointsSuccess(this.message);
}

class CreateRedeemPointsError extends RedeemPointsState {
  final String error;

  CreateRedeemPointsError(this.error);
}

class UpdateRedeemPointsLoading extends RedeemPointsState {}

class UpdateRedeemPointsSuccess extends RedeemPointsState {
  final String message;

  UpdateRedeemPointsSuccess(this.message);
}

class UpdateRedeemPointsError extends RedeemPointsState {
  final String error;

  UpdateRedeemPointsError(this.error);
}

class DeleteRedeemPointsLoading extends RedeemPointsState {}

class DeleteRedeemPointsSuccess extends RedeemPointsState {
  final String message;

  DeleteRedeemPointsSuccess(this.message);
}

class DeleteRedeemPointsError extends RedeemPointsState {
  final String error;

  DeleteRedeemPointsError(this.error);
}
