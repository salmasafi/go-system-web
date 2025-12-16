import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:systego/features/admin/taxes/presentation/widgets/taxes_list.dart';
import 'package:systego/features/admin/taxes/presentation/widgets/tax_form_dialog.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../generated/locale_keys.g.dart';

class TaxesScreen extends StatefulWidget {
  const TaxesScreen({super.key});

  @override
  State<TaxesScreen> createState() => _TaxesScreenState();
}

class _TaxesScreenState extends State<TaxesScreen> {
  void taxesInit() async {
    context.read<TaxesCubit>().getTaxes();
  }

  @override
  void initState() {
    super.initState();
    taxesInit();
  }

  Future<void> _refresh() async {
    taxesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<TaxesCubit, TaxesState>(
      listener: (context, state) {
        if (state is GetTaxesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteTaxError) {
          CustomSnackbar.showError(context, state.error);
          taxesInit();
        } else if (state is DeleteTaxSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          taxesInit();
        } else if (state is ChangeTaxStatusError) {
          CustomSnackbar.showError(context, state.error);
          taxesInit();
        } else if (state is ChangeTaxStatusSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          taxesInit();
        } else if (state is CreateTaxSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          taxesInit();
        } else if (state is UpdateTaxSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          taxesInit();
        }
      },
      builder: (context, state) {
        if (state is GetTaxesLoading ||
            state is DeleteTaxLoading ||
            state is ChangeTaxStatusLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetTaxesSuccess) {
          final taxes = state.taxes;

          if (taxes.isEmpty) {
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
              title: LocaleKeys.no_taxes.tr(),
              message: LocaleKeys.adjustments_all_caught_up.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: TaxesList(taxes: taxes),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: LocaleKeys.no_taxes.tr(),
            message: LocaleKeys.pull_to_refresh_or_check_connection.tr(),
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
        title: LocaleKeys.taxes.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => TaxFormDialog(),
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
