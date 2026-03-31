import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/units/cubit/units_cubit.dart';
import 'package:systego/features/admin/units/presentation/widgets/units_list.dart';
import 'package:systego/features/admin/units/presentation/widgets/unit_form_dialog.dart';
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
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: 'Units',
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => UnitFormDialog(),
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
