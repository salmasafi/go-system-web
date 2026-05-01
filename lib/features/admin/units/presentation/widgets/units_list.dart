import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/units/cubit/units_cubit.dart';
import 'package:systego/features/admin/units/model/unit_model.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import 'animated_unit_card.dart';
import 'unit_form_dialog.dart';
import '../../../../../generated/locale_keys.g.dart';

class UnitsList extends StatelessWidget {
  final List<UnitModel> units;
  const UnitsList({super.key, required this.units});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        return AnimatedUnitCard(
          unit: units[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, units[index]),
          onEdit: () => _showEditDialog(context, units[index]),
          onchangeStatus: (newStatus) => _changeStatus(context, units[index], newStatus),
        );
      },
    );
  }

  void _changeStatus(BuildContext context, UnitModel unit, bool status) {
    log("updating unit status");
    context.read<UnitsCubit>().changeUnitStatus(unit.id, unit.name, status);
  }

  void _showEditDialog(BuildContext context, UnitModel unit) {
    showDialog(
      context: context,
      builder: (context) => UnitFormDialog(unit: unit),
    );
  }

  void _showDeleteDialog(BuildContext context, UnitModel unit) {
    if (unit.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_unit_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_unit.tr(),
        message: '${LocaleKeys.delete_unit_message.tr()}\n"${unit.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<UnitsCubit>().deleteUnit(unit.id);
        },
      ),
    );
  }
}
