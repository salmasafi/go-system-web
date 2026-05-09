import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../cubit/redeem_points_cubit.dart';
import '../widgets/add_redeem_points_dialog.dart';
import '../widgets/redeem_points_card.dart';

class RedeemPointsScreen extends StatefulWidget {
  const RedeemPointsScreen({super.key});

  @override
  State<RedeemPointsScreen> createState() => _RedeemPointsScreenState();
}

class _RedeemPointsScreenState extends State<RedeemPointsScreen> {
  void _init() {
    context.read<RedeemPointsCubit>().getRedeemPoints();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _refresh() async {
    _init();
  }

  Widget _buildContent() {
    return BlocConsumer<RedeemPointsCubit, RedeemPointsState>(
      listener: (context, state) {
        if (state is GetRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is CreateRedeemPointsSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          _init();
        } else if (state is CreateRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is UpdateRedeemPointsSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          _init();
        } else if (state is UpdateRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteRedeemPointsSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          _init();
        } else if (state is DeleteRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is GetRedeemPointsLoading ||
            state is DeleteRedeemPointsLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        }

        if (state is GetRedeemPointsSuccess) {
          if (state.redeemPoints.isEmpty) {
            return CustomEmptyState(
              icon: Icons.redeem_rounded,
              title: LocaleKeys.redeem_points_title.tr(),
              message: LocaleKeys.empty_message_connection.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: ListView.builder(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              itemCount: state.redeemPoints.length,
              itemBuilder: (context, index) => RedeemPointsCard(
                redeemPoint: state.redeemPoints[index],
                index: index,
              ),
            ),
          );
        }

        return CustomEmptyState(
          icon: Icons.redeem_rounded,
          title: LocaleKeys.redeem_points_title.tr(),
          message: LocaleKeys.pull_to_refresh_or_check_connection.tr(),
          onRefresh: _refresh,
          actionLabel: LocaleKeys.retry.tr(),
          onAction: _refresh,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.redeem_points_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddRedeemPointsDialog(),
          );
        },
      ),
      body: SafeArea(child: _buildContent()),
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }
}
