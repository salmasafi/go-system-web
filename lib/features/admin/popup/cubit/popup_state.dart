part of 'popup_cubit.dart';

@immutable
sealed class PopupState {}

final class PopupInitial extends PopupState {}


final class GetPopupsLoading extends PopupState {}

final class GetPopupsSuccess extends PopupState {
  final List<PopupModel> popups;
  GetPopupsSuccess(this.popups);
}

final class GetPopupsError extends PopupState {
  final String error;
  GetPopupsError(this.error);
}

final class GetPopupByIdLoading extends PopupState {}

final class GetPopupByIdSuccess extends PopupState {
  final PopupModel popup;
  GetPopupByIdSuccess(this.popup);
}

final class GetPopupByIdError extends PopupState {
  final String error;
  GetPopupByIdError(this.error);
}


final class CreatePopupLoading extends PopupState {}

final class CreatePopupSuccess extends PopupState {
  final String message;
  CreatePopupSuccess(this.message);
}

final class CreatePopupError extends PopupState {
  final String error;
  CreatePopupError(this.error);
}


final class UpdatePopupLoading extends PopupState {}

final class UpdatePopupSuccess extends PopupState {
  final String message;
  UpdatePopupSuccess(this.message);
}

final class UpdatePopupError extends PopupState {
  final String error;
  UpdatePopupError(this.error);
}


final class DeletePopupLoading extends PopupState {}

final class DeletePopupSuccess extends PopupState {
  final String message;
  DeletePopupSuccess(this.message);
}

final class DeletePopupError extends PopupState {
  final String error;
  DeletePopupError(this.error);
}
