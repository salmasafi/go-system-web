part of 'permissions_cubit.dart';

@immutable
sealed class PermissionsState {}

final class PermissionsInitial extends PermissionsState {}

final class PermissionsLoading extends PermissionsState {}

final class PermissionsLoaded extends PermissionsState {
  final AdminPermissionsModel permissions;
  PermissionsLoaded(this.permissions);
}

final class PermissionsUpdating extends PermissionsState {}

final class PermissionsUpdateSuccess extends PermissionsState {
  final String message;
  PermissionsUpdateSuccess(this.message);
}

final class PermissionsUpdateError extends PermissionsState {
  final String error;
  PermissionsUpdateError(this.error);
}

final class PermissionsError extends PermissionsState {
  final String error;
  PermissionsError(this.error);
}
