import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/city/cubit/city_cubit.dart';
import 'package:systego/features/admin/zone/cubit/zone_cubit.dart';
import '../../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
import '../../cubit/zone_state.dart';
import '../widgets/zone_form_dialog.dart';
import '../widgets/zones_list.dart';

class ZonesScreen extends StatefulWidget {
  const ZonesScreen({super.key});

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  void zonesInit() async {
    context.read<CityCubit>().getCities();
    context.read<ZoneCubit>().getZones();
  }

  @override
  void initState() {
    super.initState();
    zonesInit();
  }

  Future<void> _refresh() async {
    zonesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<ZoneCubit, ZoneState>(
      listener: (context, state) {
        if (state is GetZonesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteZoneError) {
          CustomSnackbar.showError(context, state.error);
          zonesInit();
        } else if (state is DeleteZoneSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          zonesInit();
        } else if (state is SelectZoneError) {
          CustomSnackbar.showError(context, state.error);
          zonesInit();
        } else if (state is SelectZoneSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          zonesInit();
        } else if (state is CreateZoneSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          zonesInit();
        } else if (state is UpdateZoneSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          zonesInit();
        }
      },
      builder: (context, state) {
        if (state is GetZonesLoading ||
            state is DeleteZoneLoading ||
            state is SelectZoneLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetZonesSuccess) {
          final zones = state.zones;

          if (zones.isEmpty) {
            String title = zones.isEmpty ? 'No Zones' : 'No Matching Zones';
            String message = zones.isEmpty
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
              child: ZonesList(zones: zones),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: 'No Zones',
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
        title: 'Zones',
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => ZoneFormDialog(),
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
