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
import 'package:systego/features/admin/revenue/cubit/revenue_cubit.dart';
import 'package:systego/features/admin/revenue/presentation/widgets/revenue_form_dialof.dart';
import 'package:systego/features/admin/revenue/presentation/widgets/revenue_list.dart';
import 'package:systego/generated/locale_keys.g.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  void revenuesInit() async {
    context.read<RevenueCubit>().getRevenues();
  }

  @override
  void initState() {
    super.initState();
    revenuesInit();
  }

  Future<void> _refresh() async {
    revenuesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<RevenueCubit, RevenueState>(
      listener: (context, state) {
        if (state is GetRevenuesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteRevenueError) {
          CustomSnackbar.showError(context, state.error);
          revenuesInit();
        } else if (state is DeleteRevenueSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          revenuesInit();
        } else if (state is CreateRevenueSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          revenuesInit();
        } else if (state is UpdateRevenueSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          revenuesInit();
        }
      },
      buildWhen: (previous, current) {
        return current is GetRevenuesLoading ||
               current is GetRevenuesSuccess ||
               current is GetRevenuesError ||
               current is DeleteRevenueLoading; 
      },
      builder: (context, state) {
        if (state is GetRevenuesLoading || state is DeleteRevenueLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetRevenuesSuccess) {
          final revenues = state.revenues;

          if (revenues.isEmpty) {
            String title = revenues.isEmpty
                ? LocaleKeys.no_revenues.tr()
                : LocaleKeys.no_matching_revenues.tr();
            String message = revenues.isEmpty
                ? LocaleKeys.revenues_all_caught_up.tr()
                : LocaleKeys.revenues_try_adjusting_filters.tr();
            return CustomEmptyState(
              icon: Icons.attach_money_rounded,
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
              child: RevenuesList(revenues: revenues),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.attach_money_rounded,
            title: LocaleKeys.no_revenues.tr(),
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
        title: LocaleKeys.revenues_title.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => RevenueFormDialog(),
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