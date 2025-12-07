import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/popup/cubit/popup_cubit.dart';
import 'package:systego/features/admin/popup/model/popup_model.dart';
import 'package:systego/features/admin/popup/presentation/view/edit_popup_screen.dart';
import 'package:systego/features/admin/popup/presentation/widgets/popup_card_widget.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class PopupsList extends StatefulWidget {
  final List<PopupModel> popups;


  const PopupsList({super.key, required this.popups});

  @override
  State<PopupsList> createState() => _PopupsListState();
}

class _PopupsListState extends State<PopupsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: widget.popups.length,
      itemBuilder: (context, index) {
        return AnimatedPopupCard(
          popup: widget.popups[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, widget.popups[index]),
          onEdit: () => _showEditDialog(context, widget.popups[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, PopupModel popup) {
    showDialog(
      context: context,
      builder: (context) => EditPopupBottomSheet(
        popup: popup,
      ),
    );
  }

  

  void _showDeleteDialog(BuildContext context, PopupModel popup) {
    if (popup.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid popup id');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Pop Up',
        message:
            'Are you sure you want to delete this popup?\n"${popup.titleEn}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<PopupCubit>().deletePopup(popup.id);
        },
      ),
    );
  }

  
}
