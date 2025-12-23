import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:systego/features/admin/cashier/model/cashirer_model.dart';
import 'package:systego/features/admin/cashier/presentation/widgets/animated_cashier_card.dart';
import 'package:systego/features/admin/cashier/presentation/widgets/cashier_form_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class CashierList extends StatelessWidget {
  final List<CashierModel> cashiers;
  const CashierList({super.key, required this.cashiers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: cashiers.length,
      itemBuilder: (context, index) {
        return AnimatedCashierCard(
          cashier: cashiers[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, cashiers[index]),
          onEdit: () => _showEditDialog(context, cashiers[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, CashierModel cashier) {
    showDialog(
      context: context,
      builder: (context) => CashierFormDialog(cashier: cashier),
    );
  }

  void _showDeleteDialog(BuildContext context, CashierModel cashier) {
    if (cashier.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_coupon_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_coupon.tr(),
        message:
            '${LocaleKeys.delete_coupon_message.tr()} \n"${cashier.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CashierCubit>().deleteCashier(cashier.id);
        },
      ),
    );
  }

}