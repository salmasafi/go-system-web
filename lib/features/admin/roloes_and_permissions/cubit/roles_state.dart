part of 'roles_cubit.dart';

@immutable
sealed class RolesState {}

final class RolesInitial extends RolesState {}

final class RolesLoading extends RolesState {}

final class RoleLoading extends RolesState {}

final class RolesLoaded extends RolesState {
  final List<RoleModel> roles;
  RolesLoaded(this.roles);
}

final class RoleLoaded extends RolesState {
  final RoleModel role;
  RoleLoaded(this.role);
}

final class RolesUpdating extends RolesState {}

final class RolesUpdateSuccess extends RolesState {
  final String message;
  RolesUpdateSuccess(this.message);
}

final class RolesUpdateError extends RolesState {
  final String error;
  RolesUpdateError(this.error);
}

final class RolesError extends RolesState {
  final String error;
  RolesError(this.error);
}

final class RolesCreating extends RolesState {}

final class RolesCreateSuccess extends RolesState {
  final String message;
  RolesCreateSuccess(this.message);
}

final class RolesCreateError extends RolesState {
  final String error;
  RolesCreateError(this.error);
}

final class RolesDeleting extends RolesState {}

final class RolesDeleteSuccess extends RolesState {
  final String message;
  RolesDeleteSuccess(this.message);
}

final class RolesDeleteError extends RolesState {
  final String error;
  RolesDeleteError(this.error);
}