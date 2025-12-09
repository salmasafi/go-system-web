import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/discount/cubit/discount_cubit.dart';
import 'package:systego/features/admin/discount/model/discount_model.dart';
import 'package:systego/features/admin/discount/presentation/widgets/animated_discount_card.dart';
import 'package:systego/features/admin/discount/presentation/widgets/discounts_form_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class DiscountsList extends StatelessWidget {
  final List<DiscountModel> discounts;
  const DiscountsList({super.key, required this.discounts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: discounts.length,
      itemBuilder: (context, index) {
        return AnimatedDiscountCard(
          discount: discounts[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, discounts[index]),
          onEdit: () => _showEditDialog(context, discounts[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, DiscountModel discount) {
    showDialog(
      context: context,
      builder: (context) => DiscountFormDialog(discount: discount),
    );
  }

  void _showDeleteDialog(BuildContext context, DiscountModel discount) {
    if (discount.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_discount_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_discount.tr(),
        message:
            '${LocaleKeys.delete_discount_message.tr()} \n"${discount.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<DiscountsCubit>().deleteDiscount(discount.id);
        },
      ),
    );
  }

}
