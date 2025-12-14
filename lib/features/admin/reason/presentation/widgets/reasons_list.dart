import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import '../../cubit/reason_cubit.dart';
import '../../model/reason_model.dart';
import 'animated_reason_card.dart';
import 'reason_form_dialog.dart';

class ReasonsList extends StatelessWidget {
  final List<ReasonModel> reasons;
  const ReasonsList({super.key, required this.reasons});

  @override
  Widget build(BuildContext context) {
    // Handle null or empty list
    if (reasons.isEmpty) {
      return Center(
        child: Text(
          LocaleKeys.no_reasons_available.tr(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: reasons.length,
      itemBuilder: (context, index) {
        final reason = reasons[index];
        
        // Skip if reason is null
        if (reason.id.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return AnimatedReasonCard(
          reason: reason,
          index: index,
          onDelete: () => _showDeleteDialog(context, reason),
          onEdit: () => _showEditDialog(context, reason),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    ReasonModel reason,
  ) {
    showDialog(
      context: context,
      builder: (context) => ReasonFormDialog(reason: reason),
    );
  }

  void _showDeleteDialog(BuildContext context, ReasonModel reason) {
    if (reason.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_reason_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_reason.tr(),
        message: '${LocaleKeys.delete_reason_message.tr()} \n"${reason.reason}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<ReasonCubit>().deleteReason(reason.id);
        },
      ),
    );
  }
}