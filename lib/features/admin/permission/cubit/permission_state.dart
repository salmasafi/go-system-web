part of 'permission_cubit.dart';

@immutable
sealed class PermissionState {}

final class PermissionInitial extends PermissionState {}


final class GetPermissionsLoading extends PermissionState {}

final class GetPermissionsSuccess extends PermissionState {
  final List<PermissionModel> permissions;
  GetPermissionsSuccess(this.permissions);
}

final class GetPermissionsError extends PermissionState {
  final String error;
  GetPermissionsError(this.error);
}


final class GetPermissionByIdLoading extends PermissionState {}

final class GetPermissionByIdSuccess extends PermissionState {
  final PermissionModel permision;
  GetPermissionByIdSuccess(this.permision);
}

final class GetPermissionByIdError extends PermissionState {
  final String error;
  GetPermissionByIdError(this.error);
}


final class CreatePermissionLoading extends PermissionState {}

final class CreatePermissionSuccess extends PermissionState {
  final String message;
  CreatePermissionSuccess(this.message);
}

final class CreatePermissionError extends PermissionState {
  final String error;
  CreatePermissionError(this.error);
}


final class UpdatePermissionLoading extends PermissionState {}

final class UpdatePermissionSuccess extends PermissionState {
  final String message;
  UpdatePermissionSuccess(this.message);
}

final class UpdatePermissionError extends PermissionState {
  final String error;
  UpdatePermissionError(this.error);
}


final class DeletePermissionLoading extends PermissionState {}

final class DeletePermissionSuccess extends PermissionState {
  final String message;
  DeletePermissionSuccess(this.message);
}

final class DeletePermissionError extends PermissionState {
  final String error;
  DeletePermissionError(this.error);
}
