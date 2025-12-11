import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/generated/locale_keys.g.dart';

import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:systego/features/admin/bank_account/presentation/widgets/bank_accounts_form_dialog.dart';
import 'package:systego/features/admin/bank_account/presentation/widgets/bank_accounts_list.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  void accountsInit() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankAccountCubit>().getBankAccounts();   // ✅ correct
    });
    // context.read<BankAccountCubit>().getBankAccounts();
  }

  @override
  void initState() {
    super.initState();
    accountsInit();
  }

  Future<void> _refresh() async {
    accountsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<BankAccountCubit, BankAccountState>(
      listener: (context, state) {
        if (state is GetBankAccountsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteBankAccountError) {
          CustomSnackbar.showError(context, state.error);
          accountsInit();
        } else if (state is DeleteBankAccountSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          accountsInit();
        } else if (state is SelectBankAccountError) {
          CustomSnackbar.showError(context, state.error);
          accountsInit();
        } else if (state is SelectBankAccountSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          accountsInit();
        } else if (state is CreateBankAccountSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          accountsInit();
        } else if (state is UpdateBankAccountSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          accountsInit();
        }
      },
      builder: (context, state) {
        if (state is GetBankAccountsLoading ||
            state is DeleteBankAccountLoading ||
            state is SelectBankAccountLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetBankAccountsSuccess) {
          final accounts = state.accounts;

          if (accounts.isEmpty) {
            return CustomEmptyState(
              icon: Icons.account_balance_rounded,
              title: LocaleKeys.bank_accounts_no_accounts.tr(),
              message: LocaleKeys.bank_accounts_no_accounts_message.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  // _buildTotalBalanceCard(context, totalBalance),
                  Expanded(child: BankAccountsList(accounts: accounts)),
                ],
              ),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.account_balance_rounded,
            title: LocaleKeys.bank_accounts_no_accounts.tr(),
            message: LocaleKeys.empty_message_connection.tr(),
            onRefresh: _refresh,
            actionLabel: LocaleKeys.retry.tr(),
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: "Financial Accounts",
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => BankAccountFormDialog(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: AnimatedElement(
            delay: const Duration(milliseconds: 200),
            child: _buildListContent(),
          ),
        ),
      ),
    );
  }
}
