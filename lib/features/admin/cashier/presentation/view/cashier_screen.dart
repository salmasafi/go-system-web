import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:systego/features/admin/cashier/presentation/widgets/cashier_form_dialog.dart';
import 'package:systego/features/admin/cashier/presentation/widgets/cashier_list.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CashiersScreen extends StatefulWidget {
  const CashiersScreen({super.key});

  @override
  State<CashiersScreen> createState() => _CashiersScreenState();
}

class _CashiersScreenState extends State<CashiersScreen> {
  void cashiersInit() async {
    context.read<CashierCubit>().getCashiers();
  }

  @override
  void initState() {
    super.initState();
    cashiersInit();
  }

  Future<void> _refresh() async {
    cashiersInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<CashierCubit, CashierState>(
      listener: (context, state) {
        if (state is GetCashiersError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteCashierError) {
          CustomSnackbar.showError(context, state.error);
          cashiersInit();
        } else if (state is DeleteCashierSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          cashiersInit();
        } else if (state is CreateCashierSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          cashiersInit();
        } else if (state is UpdateCashierSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          cashiersInit();
        } else if (state is ToggleCashierStatusError) {
          CustomSnackbar.showError(context, state.error);
          cashiersInit();
        } else if (state is ToggleCashierStatusSuccess) {
          final status = state.isActive ? 
              LocaleKeys.cashier_activated.tr(): 
            LocaleKeys.cashier_deactivated.tr();
          CustomSnackbar.showSuccess(context, status);
        }
      },
      builder: (context, state) {
        if (state is GetCashiersLoading || state is DeleteCashierLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetCashiersSuccess) {
          final cashiers = state.cashiers;

          if (cashiers.isEmpty) {
            String title = cashiers.isEmpty
                ? LocaleKeys.no_cashiers.tr()
                : LocaleKeys.no_matching_cashiers.tr();
            String message = cashiers.isEmpty
                ? LocaleKeys.cashiers_all_caught_up.tr()
                : LocaleKeys.cashiers_try_adjusting_filters.tr();
            return CustomEmptyState(
              icon: Icons.person_outline_rounded,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: CashierList(cashiers: cashiers),
            );
          }
        } else if (state is GetCashiersError) {
          return CustomEmptyState(
            icon: Icons.person_outline_rounded,
            title: LocaleKeys.no_cashiers.tr(),
            message: state.error,
            onRefresh: _refresh,
            actionLabel: LocaleKeys.retry.tr(),
            onAction: _refresh,
          );
        } else {
          return CustomEmptyState(
            icon: Icons.person_outline_rounded,
            title: LocaleKeys.no_cashiers.tr(),
            message: LocaleKeys.empty_connection.tr(),
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
        title: LocaleKeys.cashiers_title.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const CashierFormDialog(),
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