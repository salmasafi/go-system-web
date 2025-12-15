import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/adjustment/presentation/widgets/adjustment_list.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../cubit/adjustment_cubit.dart';
import '../../cubit/adjustment_state.dart';
import '../widgets/adjustment_form_dialog.dart';

class AdjustmentsScreen extends StatefulWidget {
  const AdjustmentsScreen({super.key});

  @override
  State<AdjustmentsScreen> createState() => _AdjustmentsScreenState();
}

class _AdjustmentsScreenState extends State<AdjustmentsScreen> {
  void adjustmentsInit() async {
    context.read<AdjustmentCubit>().getAdjustments();
  }

  @override
  void initState() {
    super.initState();
    adjustmentsInit();
  }

  Future<void> _refresh() async {
    adjustmentsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<AdjustmentCubit, AdjustmentState>(
      listener: (context, state) {
        if (state is GetAdjustmentsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteAdjustmentError) {
          CustomSnackbar.showError(context, state.error);
          adjustmentsInit();
        } else if (state is DeleteAdjustmentSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          adjustmentsInit();
        } else if (state is CreateAdjustmentSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          adjustmentsInit();
        } else if (state is UpdateAdjustmentSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          adjustmentsInit();
        }
      },
      builder: (context, state) {
        if (state is GetAdjustmentsLoading ||
            state is DeleteAdjustmentLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetAdjustmentsSuccess) {
          final adjustments = state.adjustmentData.adjustments;
          if (adjustments.isEmpty) {
            String title = adjustments.isEmpty ? LocaleKeys.no_adjustments.tr() : LocaleKeys.no_matching_adjustments.tr();
            String message = adjustments.isEmpty
                ? LocaleKeys.adjustments_all_caught_up.tr()
                : LocaleKeys.try_adjusting_search.tr();
            return CustomEmptyState(
              icon: Icons.inventory_rounded,
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
              child: AdjustmentsList(adjustments: adjustments),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.inventory_rounded,
            title: LocaleKeys.no_adjustments.tr(),
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
        title: LocaleKeys.adjustments.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AdjustmentFormDialog(),
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