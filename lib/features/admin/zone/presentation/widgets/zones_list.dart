import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import '../../cubit/zone_cubit.dart';
import '../../model/zone_model.dart';
import 'animated_zone_card.dart';
import 'zone_form_dialog.dart';

class ZonesList extends StatelessWidget {
  final List<ZoneModel> zones;
  const ZonesList({super.key, required this.zones});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        return AnimatedZoneCard(
          zone: zones[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, zones[index]),
          onEdit: () => _showEditDialog(context, zones[index]),
          //onTap: () => _showSelectDialog(context, Zones[index]),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    ZoneModel zone,
  ) {
    showDialog(
      context: context,
      builder: (context) => ZoneFormDialog(zone: zone),
    );
  }

  void _showDeleteDialog(BuildContext context, ZoneModel zone) {
    if (zone.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid Zone ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Zone',
        message: 'Are you sure you want to delete this zone?\n"${zone.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<ZoneCubit>().deleteZone(zone.id);
        },
      ),
    );
  }

  // void _showSelectDialog(BuildContext context, ZoneModel Zone) {
  //   if (Zone.id.isEmpty) {
  //     CustomSnackbar.showError(context, 'Invalid Zone ID');
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => CustomDeleteDialog(
  //       title: 'Select Zone',
  //       message:
  //           'Are you sure you want to select this Zone as the default?\n"${Zone.name}"',
  //       icon: Icons.check_circle_rounded,
  //       iconColor: AppColors.primaryBlue,
  //       deleteText: 'Select',
  //       onDelete: () {
  //         Navigator.pop(dialogContext);
  //         context.read<ZoneCubit>().selectZone(Zone.id, Zone.name);
  //       },
  //     ),
  //   );
  // }

}
