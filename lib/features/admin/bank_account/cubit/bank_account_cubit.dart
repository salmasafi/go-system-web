import 'dart:developer' as dev;
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:GoSystem/features/admin/bank_account/data/repositories/bank_account_repository.dart';
import 'package:GoSystem/features/admin/bank_account/model/bank_account_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

part 'bank_accounts_state.dart';

class BankAccountCubit extends Cubit<BankAccountState> {
  final BankAccountRepository _repository;

  BankAccountCubit(BankAccountRepository bankAccountRepository)
    : _repository = bankAccountRepository,
      super(BankAccountInitial());

  List<BankAccountModel> allAccounts = [];
  int totalBalance = 0;

  Future<void> getBankAccounts() async {
    emit(GetBankAccountsLoading());
    try {
      final accounts = await _repository.getAllBankAccounts();
      allAccounts = accounts.map((e) => e.toLegacyModel()).toList();
      emit(GetBankAccountsSuccess(allAccounts));
    } catch (e) {
      emit(GetBankAccountsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> selectBankAccount(String accountId, String name) async {
    emit(SelectBankAccountLoading());
    try {
      await _repository.selectBankAccount(accountId);
      emit(
        SelectBankAccountSuccess(
          '$name ${LocaleKeys.default_bank_account_message.tr()}',
        ),
      );
    } catch (e) {
      emit(SelectBankAccountError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addBankAccount({
    required String name,
    required String wareHouseId,
    required String description,
    required double balance,
    required File? image,
    required bool status,
    required bool inPos,
  }) async {
    emit(CreateBankAccountLoading());
    try {
      await _repository.createBankAccount(
        name: name,
        balance: balance,
        status: status,
        inPos: inPos,
        description: description,
        wareHouseId: wareHouseId,
        imagePath: image?.path,
      );
      emit(
        CreateBankAccountSuccess(
          LocaleKeys.financial_account_created_successfully.tr(),
        ),
      );
      await getBankAccounts();
    } catch (e) {
      emit(CreateBankAccountError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateBankAccount({
    required String accountId,
    required String name,
    required String wareHouseId,
    required String description,
    required double balance,
    required File? image,
    required bool status,
    required bool inPos,
  }) async {
    emit(UpdateBankAccountLoading());
    try {
      await _repository.updateBankAccount(
        id: accountId,
        name: name,
        balance: balance,
        status: status,
        inPos: inPos,
        description: description,
        wareHouseId: wareHouseId,
        imagePath: image?.path,
      );
      emit(
        UpdateBankAccountSuccess(
          LocaleKeys.financial_account_updated_successfully.tr(),
        ),
      );
      await getBankAccounts();
    } catch (e) {
      emit(UpdateBankAccountError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteBankAccount(String accountId) async {
    emit(DeleteBankAccountLoading());
    try {
      await _repository.deleteBankAccount(accountId);
      allAccounts.removeWhere((account) => account.id == accountId);
      emit(
        DeleteBankAccountSuccess(
          LocaleKeys.financial_account_deleted_successfully.tr(),
        ),
      );
    } catch (e) {
      emit(DeleteBankAccountError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
