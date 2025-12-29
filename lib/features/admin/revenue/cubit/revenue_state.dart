part of 'revenue_cubit.dart';

class RevenueState {}

final class RevenueInitial extends RevenueState {}

// ---------------------- Get All Revenues ----------------------
final class GetRevenuesLoading extends RevenueState {}

final class GetRevenuesSuccess extends RevenueState {
  final List<RevenueModel> revenues;
  GetRevenuesSuccess(this.revenues);
}

final class GetRevenuesError extends RevenueState {
  final String error;
  GetRevenuesError(this.error);
}

// ---------------------- Get Revenue By ID ----------------------
final class GetRevenueByIdLoading extends RevenueState {}

final class GetRevenueByIdSuccess extends RevenueState {
  final RevenueModel revenue;
  GetRevenueByIdSuccess(this.revenue);
}

final class GetRevenueByIdError extends RevenueState {
  final String error;
  GetRevenueByIdError(this.error);
}

// ---------------------- Create Revenue ----------------------
final class CreateRevenueLoading extends RevenueState {}

final class CreateRevenueSuccess extends RevenueState {
  final String message;
  CreateRevenueSuccess(this.message);
}

final class CreateRevenueError extends RevenueState {
  final String error;
  CreateRevenueError(this.error);
}

// ---------------------- Update Revenue ----------------------
final class UpdateRevenueLoading extends RevenueState {}

final class UpdateRevenueSuccess extends RevenueState {
  final String message;
  UpdateRevenueSuccess(this.message);
}

final class UpdateRevenueError extends RevenueState {
  final String error;
  UpdateRevenueError(this.error);
}

// ---------------------- Delete Revenue ----------------------
final class DeleteRevenueLoading extends RevenueState {}

final class DeleteRevenueSuccess extends RevenueState {
  final String message;
  DeleteRevenueSuccess(this.message);
}

final class DeleteRevenueError extends RevenueState {
  final String error;
  DeleteRevenueError(this.error);
}


// ---------------------- Get Selection Data ----------------------
final class GetSelectionDataLoading extends RevenueState {}

final class GetSelectionDataSuccess extends RevenueState {
   final List<CategorySelection> categories;
   final List<AccountSelection> accounts;
  GetSelectionDataSuccess(this.categories, this.accounts);
}

final class GetSelectionDataError extends RevenueState {
  final String error;
  GetSelectionDataError(this.error);
}