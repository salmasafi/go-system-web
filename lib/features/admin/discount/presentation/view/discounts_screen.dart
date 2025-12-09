import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/discount/cubit/discount_cubit.dart';
import 'package:systego/features/admin/discount/presentation/widgets/discounts_form_dialog.dart';
import 'package:systego/features/admin/discount/presentation/widgets/discounts_list.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  void discountsInit() async {
    context.read<DiscountsCubit>().getDiscounts();
  }

  @override
  void initState() {
    super.initState();
    discountsInit();
  }

  Future<void> _refresh() async {
    discountsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<DiscountsCubit, DiscountsState>(
      listener: (context, state) {
        if (state is GetDiscountsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteDiscountError) {
          CustomSnackbar.showError(context, state.error);
          discountsInit();
        } else if (state is DeleteDiscountSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          discountsInit();
        } else if (state is CreateDiscountSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          discountsInit();
        } else if (state is UpdateDiscountSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          discountsInit();
        }
      },
      builder: (context, state) {
        if (state is GetDiscountsLoading || state is DeleteDiscountLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetDiscountsSuccess) {
          final discounts = state.discounts;

          if (discounts.isEmpty) {
            String title = discounts.isEmpty
                ? LocaleKeys.no_discounts.tr()
                : LocaleKeys.no_matching_discounts.tr();
            String message = discounts.isEmpty
                ? LocaleKeys.cities_all_caught_up.tr()
                : LocaleKeys.cities_try_adjusting_filters.tr();
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
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
              child: DiscountsList(discounts: discounts),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: LocaleKeys.no_discounts.tr(),
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
        title: LocaleKeys.discounts_title.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => DiscountFormDialog(),
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
