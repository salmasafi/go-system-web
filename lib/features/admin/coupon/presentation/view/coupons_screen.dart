import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/coupon/cubit/coupon_cubit.dart';
import 'package:systego/features/admin/coupon/presentation/widgets/coupon_form_dialog.dart';
import 'package:systego/features/admin/coupon/presentation/widgets/coupons_list.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  void couponsInit() async {
    context.read<CouponsCubit>().getCoupons();
  }

  @override
  void initState() {
    super.initState();
    couponsInit();
  }

  Future<void> _refresh() async {
    couponsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<CouponsCubit, CouponsState>(
      listener: (context, state) {
        if (state is GetCouponsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteCouponError) {
          CustomSnackbar.showError(context, state.error);
          couponsInit();
        } else if (state is DeleteCouponSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          couponsInit();
        } else if (state is CreateCouponSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          couponsInit();
        } else if (state is UpdateCouponSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          couponsInit();
        }
      },
      builder: (context, state) {
        if (state is GetCouponsLoading ||
            state is DeleteCouponLoading 
            ) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetCouponsSuccess) {
          final coupons = state.coupons;

          if (coupons.isEmpty) {
            String title = coupons.isEmpty
                ? LocaleKeys.no_coupons.tr()
                : LocaleKeys.no_matching_coupons.tr();
            String message = coupons.isEmpty
                ? LocaleKeys.cities_all_caught_up.tr()
                : LocaleKeys.coupons_try_adjusting_filters.tr();
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
              child: CouponsList(coupons: coupons),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: LocaleKeys.no_coupons.tr(),
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
        title: LocaleKeys.coupons_title.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CouponFormDialog(),
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
