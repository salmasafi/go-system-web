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
import 'package:GoSystem/features/admin/units/cubit/units_cubit.dart';
import 'package:GoSystem/features/admin/units/presentation/widgets/units_list.dart';
import 'package:GoSystem/features/admin/units/presentation/widgets/unit_form_dialog.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  void unitsInit() async {
    context.read<UnitsCubit>().getUnits();
  }

  @override
  void initState() {
    super.initState();
    unitsInit();
  }

  Future<void> _refresh() async {
    unitsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<UnitsCubit, UnitsState>(
      listener: (context, state) {
        if (state is GetUnitsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteUnitError) {
          CustomSnackbar.showError(context, state.error);
          unitsInit();
        } else if (state is DeleteUnitSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          unitsInit();
        } else if (state is ChangeUnitStatusError) {
          CustomSnackbar.showError(context, state.error);
          unitsInit();
        } else if (state is ChangeUnitStatusSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          unitsInit();
        } else if (state is CreateUnitSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          unitsInit();
        } else if (state is UpdateUnitSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          unitsInit();
        }
      },
      builder: (context, state) {
        if (state is GetUnitsLoading ||
            state is DeleteUnitLoading ||
            state is ChangeUnitStatusLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetUnitsSuccess) {
          final units = state.units;

          if (units.isEmpty) {
            return CustomEmptyState(
              icon: Icons.straighten_rounded,
              title: 'No Units',
              message: 'No units found. Add your first unit to get started.',
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: UnitsList(units: units),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.straighten_rounded,
            title: 'No Units',
            message: 'Pull to refresh or check connection',
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
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.units_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const UnitFormDialog(),
          );
        },
      ),
      body: SafeArea(
        child: _buildListContent(),
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
