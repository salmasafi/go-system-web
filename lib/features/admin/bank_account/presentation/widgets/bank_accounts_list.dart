import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:systego/features/admin/bank_account/model/bank_account_model.dart';
import 'package:systego/features/admin/bank_account/presentation/widgets/bank_accounts_form_dialog.dart';
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
          onTap: () => _showSelectDialog(context, widget.accounts[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, BankAccountModel account) {
    showDialog(
      context: context,
      builder: (context) => BankAccountFormDialog(
        account: account,
        existingImageUrl: account.icon,
      ),
    );
  }

  void _showSelectDialog(BuildContext context, BankAccountModel account) {
    if (account.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid Bank Account ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Select Bank Account',
        message:
            'Are you sure you want to select this bank Account as the default?\n"${account.name}"',
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.primaryBlue,
        deleteText: 'Select',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<BankAccountCubit>().selectBankAccount(account.id, account.name);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BankAccountModel account) {
    if (account.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid Account ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Bank Account',
        message:
            'Are you sure you want to delete this account?\n"${account.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<BankAccountCubit>().deleteBankAccount(account.id);
        },
      ),
    );
  }

  
}
