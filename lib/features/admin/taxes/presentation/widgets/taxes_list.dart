import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:systego/features/admin/taxes/model/taxes_model.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import 'animated_tax_card.dart';
import 'tax_form_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../generated/locale_keys.g.dart';

class TaxesList extends StatelessWidget {
  final List<TaxModel> taxes;
  const TaxesList({super.key, required this.taxes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: taxes.length,
      itemBuilder: (context, index) {
        return AnimatedTaxCard(
          tax: taxes[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, taxes[index]),
          onEdit: () => _showEditDialog(context, taxes[index]),
          onchangeStatus: (newStatus) => _changeStatus(context, taxes[index], newStatus),
        );
      },
    );
  }

  void _changeStatus(BuildContext context, TaxModel tax, bool status) {
    log("updating tax status");
    context.read<TaxesCubit>().changeTaxStatus(tax.id, tax.name, status);
  }

  void _showEditDialog(BuildContext context, TaxModel tax) {
    showDialog(
      context: context,
      builder: (context) => TaxFormDialog(tax: tax),
    );
  }

  void _showDeleteDialog(BuildContext context, TaxModel tax) {
    if (tax.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_tax_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_tax.tr(),
        message: '${LocaleKeys.delete_tax_message.tr()}\n"${tax.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<TaxesCubit>().deleteTax(tax.id);
        },
      ),
    );
  }
}
