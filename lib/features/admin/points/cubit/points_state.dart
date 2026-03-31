import '../model/points_model.dart';

abstract class PointsState {}

class PointsInitial extends PointsState {}

class GetPointsLoading extends PointsState {}

class GetPointsSuccess extends PointsState {
  final List<PointsModel> points;

  GetPointsSuccess(this.points);
}

class GetPointsError extends PointsState {
  final String error;

  GetPointsError(this.error);
}

class CreatePointsLoading extends PointsState {}

class CreatePointsSuccess extends PointsState {
  final String message;

  CreatePointsSuccess(this.message);
}

class CreatePointsError extends PointsState {
  final String error;

  CreatePointsError(this.error);
}

class UpdatePointsLoading extends PointsState {}

class UpdatePointsSuccess extends PointsState {
  final String message;

  UpdatePointsSuccess(this.message);
}

class UpdatePointsError extends PointsState {
  final String error;

  UpdatePointsError(this.error);
}

class DeletePointsLoading extends PointsState {}

class DeletePointsSuccess extends PointsState {
  final String message;

  DeletePointsSuccess(this.message);
}

class DeletePointsError extends PointsState {
  final String error;

  DeletePointsError(this.error);
}
