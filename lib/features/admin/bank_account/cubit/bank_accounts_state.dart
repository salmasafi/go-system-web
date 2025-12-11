part of 'bank_account_cubit.dart';


@immutable
sealed class BankAccountState {}

final class BankAccountInitial extends BankAccountState {}

final class GetBankAccountsLoading extends BankAccountState {}

final class GetBankAccountsSuccess extends BankAccountState {
  final List<BankAccountModel> accounts;
  GetBankAccountsSuccess(this.accounts);
}

final class GetBankAccountsError extends BankAccountState {
  final String error;
  GetBankAccountsError(this.error);
}

final class GetBankAccountByIdLoading extends BankAccountState {}

final class GetBankAccountByIdSuccess extends BankAccountState {
  final BankAccountModel account;
  GetBankAccountByIdSuccess(this.account);
}

final class GetBankAccountByIdError extends BankAccountState {
  final String error;
  GetBankAccountByIdError(this.error);
}

final class CreateBankAccountLoading extends BankAccountState {}

final class CreateBankAccountSuccess extends BankAccountState {
  final String message;
  CreateBankAccountSuccess(this.message);
}

final class CreateBankAccountError extends BankAccountState {
  final String error;
  CreateBankAccountError(this.error);
}

final class UpdateBankAccountLoading extends BankAccountState {}

final class UpdateBankAccountSuccess extends BankAccountState {
  final String message;
  UpdateBankAccountSuccess(this.message);
}

final class UpdateBankAccountError extends BankAccountState {
  final String error;
  UpdateBankAccountError(this.error);
}

final class DeleteBankAccountLoading extends BankAccountState {}

final class DeleteBankAccountSuccess extends BankAccountState {
  final String message;
  DeleteBankAccountSuccess(this.message);
}

final class DeleteBankAccountError extends BankAccountState {
  final String error;
  DeleteBankAccountError(this.error);
}

final class SelectBankAccountLoading extends BankAccountState {}

final class SelectBankAccountSuccess extends BankAccountState {
  final String message;
  SelectBankAccountSuccess(this.message);
}

final class SelectBankAccountError extends BankAccountState {
  final String error;
  SelectBankAccountError(this.error);
}
