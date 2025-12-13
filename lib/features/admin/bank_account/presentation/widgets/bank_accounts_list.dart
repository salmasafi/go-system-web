import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:systego/features/admin/bank_account/model/bank_account_model.dart';
import 'package:systego/features/admin/bank_account/presentation/widgets/bank_accounts_form_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import 'animated_bank_account_card.dart';

class BankAccountsList extends StatefulWidget {
  final List<BankAccountModel> accounts;


  const BankAccountsList({super.key, required this.accounts});

  @override
  State<BankAccountsList> createState() => _BankAccountsListState();
}

class _BankAccountsListState extends State<BankAccountsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: widget.accounts.length,
      itemBuilder: (context, index) {

        return AnimatedBankAccountCard(
          account: widget.accounts[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, widget.accounts[index]),
          onEdit: () => _showEditDialog(context, widget.accounts[index]),
          // onTap: () => _showSelectDialog(context, widget.accounts[index]),
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, BankAccountModel account) {
    showDialog(
      context: context,
      builder: (context) => BankAccountFormDialog(
        account: account,
        existingImageUrl: account.image,
      ),
    );
  }

  // void _showSelectDialog(BuildContext context, BankAccountModel account) {
  //   if (account.id.isEmpty) {
  //     CustomSnackbar.showError(context, LocaleKeys.invalid_bank_account_id.tr());
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => CustomDeleteDialog(
  //       title: LocaleKeys.select_bank_account.tr(),
  //       message:
  //           '${LocaleKeys.select_bank_account_message.tr()} ${account.name}',
  //       icon: Icons.check_circle_rounded,
  //       iconColor: AppColors.primaryBlue,
  //       deleteText: LocaleKeys.select.tr(),
  //       onDelete: () {
  //         Navigator.pop(dialogContext);
  //         context.read<BankAccountCubit>().selectBankAccount(account.id, account.name);
  //       },
  //     ),
  //   );
  // }

  void _showDeleteDialog(BuildContext context, BankAccountModel account) {
    if (account.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_account_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_bank_account.tr(),
        message:
            '${LocaleKeys.delete_bank_account_message.tr()} ${account.name}',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<BankAccountCubit>().deleteBankAccount(account.id);
        },
      ),
    );
  }

  
}
