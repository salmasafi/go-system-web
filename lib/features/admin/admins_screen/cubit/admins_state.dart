// part of 'admins_cubit.dart';

// @immutable
// sealed class AdminsState {}

// final class AdminsInitial extends AdminsState {}

// // ================= GET ADMINS =================
// final class GetAdminsLoading extends AdminsState {}

// final class GetAdminsSuccess extends AdminsState {
//   final List<AdminModel> admins;
//   GetAdminsSuccess(this.admins);
// }

// final class GetAdminsError extends AdminsState {
//   final String error;
//   GetAdminsError(this.error);
// }

// // ================= GET ADMIN BY ID =================
// final class GetAdminByIdLoading extends AdminsState {}

// final class GetAdminByIdSuccess extends AdminsState {
//   final AdminModel admin;
//   GetAdminByIdSuccess(this.admin);
// }

// final class GetAdminByIdError extends AdminsState {
//   final String error;
//   GetAdminByIdError(this.error);
// }

// // ================= CREATE ADMIN =================
// final class CreateAdminLoading extends AdminsState {}

// final class CreateAdminSuccess extends AdminsState {
//   final String message;
//   CreateAdminSuccess(this.message);
// }

// final class CreateAdminError extends AdminsState {
//   final String error;
//   CreateAdminError(this.error);
// }

// // ================= UPDATE ADMIN =================
// final class UpdateAdminLoading extends AdminsState {}

// final class UpdateAdminSuccess extends AdminsState {
//   final String message;
//   UpdateAdminSuccess(this.message);
// }

// final class UpdateAdminError extends AdminsState {
//   final String error;
//   UpdateAdminError(this.error);
// }

// // ================= DELETE ADMIN =================
// final class DeleteAdminLoading extends AdminsState {}

// final class DeleteAdminSuccess extends AdminsState {
//   final String message;
//   DeleteAdminSuccess(this.message);
// }

// final class DeleteAdminError extends AdminsState {
//   final String error;
//   DeleteAdminError(this.error);
// }

// final class PermissionsInitial extends AdminsState {}

// // ================= LOADING =================
// final class PermissionsLoading extends AdminsState {}

// // ================= LOADED =================
// final class PermissionsLoaded extends AdminsState {
//   final AdminPermissionsModel permissions;
//   PermissionsLoaded(this.permissions);
// }

// // ================= UPDATING =================
// final class PermissionsUpdating extends AdminsState {}

// final class PermissionsUpdateSuccess extends AdminsState {
//   // final AdminPermissionsModel permissions;
//   final String message;
//   PermissionsUpdateSuccess(this.message);
// }

// final class PermissionsUpdateError extends AdminsState {
//   final String error;
//   PermissionsUpdateError(this.error);
// }

// // ================= ERROR =================
// final class PermissionsError extends AdminsState {
//   final String error;
//   PermissionsError(this.error);
// }


part of 'admins_cubit.dart';

@immutable
sealed class AdminsState {}

final class AdminsInitial extends AdminsState {}

// GET ADMINS
final class GetAdminsLoading extends AdminsState {}
final class GetAdminsSuccess extends AdminsState {
  final List<AdminModel> admins;
  GetAdminsSuccess(this.admins);
}
final class GetAdminsError extends AdminsState {
  final String error;
  GetAdminsError(this.error);
}

// GET ADMIN BY ID
final class GetAdminByIdLoading extends AdminsState {}
final class GetAdminByIdSuccess extends AdminsState {
  final AdminModel admin;
  GetAdminByIdSuccess(this.admin);
}
final class GetAdminByIdError extends AdminsState {
  final String error;
  GetAdminByIdError(this.error);
}

// CREATE
final class CreateAdminLoading extends AdminsState {}
final class CreateAdminSuccess extends AdminsState {
  final String message;
  CreateAdminSuccess(this.message);
}
final class CreateAdminError extends AdminsState {
  final String error;
  CreateAdminError(this.error);
}

// UPDATE
final class UpdateAdminLoading extends AdminsState {}
final class UpdateAdminSuccess extends AdminsState {
  final String message;
  UpdateAdminSuccess(this.message);
}
final class UpdateAdminError extends AdminsState {
  final String error;
  UpdateAdminError(this.error);
}

// DELETE
final class DeleteAdminLoading extends AdminsState {}
final class DeleteAdminSuccess extends AdminsState {
  final String message;
  DeleteAdminSuccess(this.message);
}
final class DeleteAdminError extends AdminsState {
  final String error;
  DeleteAdminError(this.error);
}
