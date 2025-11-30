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

class TaxesScreen extends StatefulWidget {
  const TaxesScreen({super.key});

  @override
  State<TaxesScreen> createState() => _TaxesScreenState();
}

class _TaxesScreenState extends State<TaxesScreen> {
  void countriesInit() async {
    context.read<TaxesCubit>().getTaxes();
  }

  @override
  void initState() {
    super.initState();
    countriesInit();
  }

  Future<void> _refresh() async {
    countriesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<TaxesCubit, TaxesState>(
      listener: (context, state) {
        if (state is GetTaxesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteTaxError) {
          CustomSnackbar.showError(context, state.error);
          countriesInit();
        } else if (state is DeleteTaxSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
        } else if (state is ChangeTaxStatusError) {
          CustomSnackbar.showError(context, state.error);
          countriesInit();
        } else if (state is ChangeTaxStatusSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
        } else if (state is CreateTaxSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
        } else if (state is UpdateTaxSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
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
            String title = taxes.isEmpty
                ? 'No taxes'
                : 'No Matching taxes';
            String message = taxes.isEmpty
                ? 'You\'re all caught up!'
                : 'Try adjusting your filters';
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: 'Retry',
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
            title: 'No taxes',
            message: 'Pull to refresh or check your connection',
            onRefresh: _refresh,
            actionLabel: 'Retry',
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
        title: 'Taxes',
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
