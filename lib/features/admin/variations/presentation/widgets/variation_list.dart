import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/variations/cubit/variation_cubit.dart';
import 'package:systego/features/admin/variations/model/variation_model.dart';
import 'package:systego/features/admin/variations/presentation/view/edit_variation_screen.dart';
import 'package:systego/features/admin/variations/presentation/widgets/variation_card.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class VariationsList extends StatefulWidget {
  final List<VariationModel> variations;

  const VariationsList({super.key, required this.variations});

  @override
  State<VariationsList> createState() => _VariationsListState();
}

class _VariationsListState extends State<VariationsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: widget.variations.length,
      itemBuilder: (context, index) {
        final variation = widget.variations[index];
        return VariationCard(
          variation: variation,
          index: index,
          onEdit: () => _showEditDialog(context, variation),
          onDelete: () => _showDeleteDialog(context, variation),
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, VariationModel variation) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditVariationBottomSheet(
      variation: variation,
    ),
  );
}


  void _showDeleteDialog(BuildContext context, VariationModel variation) {
    if (variation.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid variation ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Variation',
        message: 'Are you sure you want to delete this variation?\n"${variation.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<VariationCubit>().deleteVariation(variation.id);
        },
      ),
    );
  }
}
