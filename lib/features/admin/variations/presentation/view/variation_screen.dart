import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/variations/cubit/variation_cubit.dart';
import 'package:systego/features/admin/variations/presentation/view/create_variation_screen.dart';
import 'package:systego/features/admin/variations/presentation/widgets/variation_list.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class VariationScreen extends StatefulWidget {
  const VariationScreen({super.key});

  @override
  State<VariationScreen> createState() => _VariationScreenState();
}

class _VariationScreenState extends State<VariationScreen> {
  void variationsInit() async {
    context.read<VariationCubit>().getAllVariations();
  }

  @override
  void initState() {
    super.initState();
    variationsInit();
  }

  Future<void> _refresh() async {
    variationsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<VariationCubit, VariationState>(
      listener: (context, state) {
        if (state is GetVariationsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteVariationError) {
          CustomSnackbar.showError(context, state.error);
          variationsInit();
        } else if (state is DeleteVariationSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          variationsInit();
        } else if (state is CreateVariationSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          variationsInit();
        } else if (state is UpdateVariationSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          variationsInit();
        }
      },
      builder: (context, state) {
        if (state is GetVariationsLoading || state is DeleteVariationLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetVariationsSuccess) {
          final variations = state.variations;

          if (variations.isEmpty) {
            return CustomEmptyState(
              icon: Icons.list_alt,
              title: LocaleKeys.no_variations_title.tr(),
              message: LocaleKeys.no_variations_message.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: VariationsList(variations: variations),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.list_alt,
            title: LocaleKeys.no_variations_alt_title.tr(),
            message: LocaleKeys.no_variations_alt_message.tr(),
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
        title: LocaleKeys.variations_title.tr(),
        showActions: true,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateVariationScreen()),
          );
          if (result == true && mounted) {
            variationsInit();
          }
        },
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
