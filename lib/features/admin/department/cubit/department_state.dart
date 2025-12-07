part of 'department_cubit.dart';

@immutable
sealed class DepartmentState {}

final class DepartmentInitial extends DepartmentState {}

final class GetDepartmentsLoading extends DepartmentState {}

final class GetDepartmentsSuccess extends DepartmentState {
  final List<DepartmentModel> departments;
  GetDepartmentsSuccess(this.departments);
}

final class GetDepartmentsError extends DepartmentState {
  final String error;
  GetDepartmentsError(this.error);
}

/// =======================
///   Get Department By ID
/// =======================
final class GetDepartmentByIdLoading extends DepartmentState {}

final class GetDepartmentByIdSuccess extends DepartmentState {
  final DepartmentModel department;
  GetDepartmentByIdSuccess(this.department);
}

final class GetDepartmentByIdError extends DepartmentState {
  final String error;
  GetDepartmentByIdError(this.error);
}

/// =======================
///     Create Department
/// =======================
final class CreateDepartmentLoading extends DepartmentState {}

final class CreateDepartmentSuccess extends DepartmentState {
  final String message;
  CreateDepartmentSuccess(this.message);
}

final class CreateDepartmentError extends DepartmentState {
  final String error;
  CreateDepartmentError(this.error);
}

/// =======================
///     Update Department
/// =======================
final class UpdateDepartmentLoading extends DepartmentState {}

final class UpdateDepartmentSuccess extends DepartmentState {
  final String message;
  UpdateDepartmentSuccess(this.message);
}

final class UpdateDepartmentError extends DepartmentState {
  final String error;
  UpdateDepartmentError(this.error);
}

/// =======================
///     Delete Department
/// =======================
final class DeleteDepartmentLoading extends DepartmentState {}

final class DeleteDepartmentSuccess extends DepartmentState {
  final String message;
  DeleteDepartmentSuccess(this.message);
}

final class DeleteDepartmentError extends DepartmentState {
  final String error;
  DeleteDepartmentError(this.error);
}
