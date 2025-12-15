import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/adjustment/presentation/widgets/adjustment_card.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import '../../cubit/adjustment_cubit.dart';
import '../../model/adjustment_model.dart';
import 'adjustment_form_dialog.dart';

class AdjustmentsList extends StatelessWidget {
  final List<AdjustmentModel> adjustments;
  const AdjustmentsList({super.key, required this.adjustments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: adjustments.length,
      itemBuilder: (context, index) {
        return AnimatedAdjustmentCard(
          adjustment: adjustments[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, adjustments[index]),
          onEdit: () => _showEditDialog(context, adjustments[index]),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    AdjustmentModel adjustment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AdjustmentFormDialog(adjustment: adjustment, existingImageUrl: adjustment.image,),
    );
  }

  void _showDeleteDialog(BuildContext context, AdjustmentModel adjustment) {
    if (adjustment.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_adjustment_id.tr());
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_adjustment.tr(),
        message: '${LocaleKeys.delete_adjustment_message.tr()} \n"${adjustment.note}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<AdjustmentCubit>().deleteAdjustment(adjustment.id);
        },
      ),
    );
  }
}