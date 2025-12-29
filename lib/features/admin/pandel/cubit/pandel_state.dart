part of 'pandel_cubit.dart';

@immutable
sealed class PandelState {}

final class PandelInitial extends PandelState {}

final class GetPandelsLoading extends PandelState {}

final class GetPandelsSuccess extends PandelState {
  final List<PandelModel> pandels;
  GetPandelsSuccess(this.pandels);
}

final class GetPandelsError extends PandelState {
  final String error;
  GetPandelsError(this.error);
}

final class GetPandelByIdLoading extends PandelState {}

final class GetPandelByIdSuccess extends PandelState {
  final PandelModel pandel;
  GetPandelByIdSuccess(this.pandel);
}

final class GetPandelByIdError extends PandelState {
  final String error;
  GetPandelByIdError(this.error);
}

final class CreatePandelLoading extends PandelState {}

final class CreatePandelSuccess extends PandelState {
  final String message;
  CreatePandelSuccess(this.message);
}

final class CreatePandelError extends PandelState {
  final String error;
  CreatePandelError(this.error);
}

final class UpdatePandelLoading extends PandelState {}

final class UpdatePandelSuccess extends PandelState {
  final String message;
  UpdatePandelSuccess(this.message);
}

final class UpdatePandelError extends PandelState {
  final String error;
  UpdatePandelError(this.error);
}

final class DeletePandelLoading extends PandelState {}

final class DeletePandelSuccess extends PandelState {
  final String message;
  DeletePandelSuccess(this.message);
}

final class DeletePandelError extends PandelState {
  final String error;
  DeletePandelError(this.error);
}