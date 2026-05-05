import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../cubit/reason_cubit.dart';
import '../../cubit/reason_state.dart';
import '../widgets/reasons_list.dart';
import '../widgets/reason_form_dialog.dart';

class ReasonsScreen extends StatefulWidget {
  const ReasonsScreen({super.key});

  @override
  State<ReasonsScreen> createState() => _ReasonsScreenState();
}

class _ReasonsScreenState extends State<ReasonsScreen> {
  void reasonsInit() async {
    context.read<ReasonCubit>().getReasons();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reasonsInit();
    });
  }

  Future<void> _refresh() async {
    reasonsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<ReasonCubit, ReasonState>(
      listener: (context, state) {
        if (state is GetReasonsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteReasonError) {
          CustomSnackbar.showError(context, state.error);
          reasonsInit();
        } else if (state is DeleteReasonSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          reasonsInit();
        } else if (state is CreateReasonSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          reasonsInit();
        } else if (state is UpdateReasonSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          reasonsInit();
        }
      },
      builder: (context, state) {
        // Handle loading states
        if (state is GetReasonsLoading || state is DeleteReasonLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        }

        // Handle success state
        if (state is GetReasonsSuccess) {
          final reasons = state.reasonData.reasons;

          if (reasons.isEmpty) {
            return CustomEmptyState(
              icon: Icons.receipt_long_rounded,
              title: LocaleKeys.no_reasons.tr(),
              message: LocaleKeys.no_reasons_available.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          }

          // Filter out any null items
          final validReasons = reasons.where((r) => r.id.isNotEmpty).toList();
          
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: ReasonsList(reasons: validReasons),
          );
        }

        // Handle error state
        if (state is GetReasonsError) {
          return CustomEmptyState(
            icon: Icons.error_outline_rounded,
            title: LocaleKeys.error_occurred.tr(),
            message: state.error,
            onRefresh: _refresh,
            actionLabel: LocaleKeys.retry.tr(),
            onAction: _refresh,
          );
        }

        // Initial state - show loading shimmer
        return RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primaryBlue,
          child: CustomLoadingShimmer(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.reasons.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ReasonFormDialog(),
          );
        },
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'Reasons Screen - Under Development',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
