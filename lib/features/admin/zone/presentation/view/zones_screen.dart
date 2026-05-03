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
import 'package:GoSystem/features/admin/city/cubit/city_cubit.dart';
import 'package:GoSystem/features/admin/zone/cubit/zone_cubit.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
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
            
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
              title: LocaleKeys.no_zones_title.tr(),
              message: LocaleKeys.no_zones_message.tr(),
              onRefresh: _refresh,
              actionLabel:  LocaleKeys.retry.tr(),
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
            title:  LocaleKeys.no_zones_title.tr(),
            message:  LocaleKeys.empty_state_message_connection.tr(),
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
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.zones_screen_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ZoneFormDialog(),
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
