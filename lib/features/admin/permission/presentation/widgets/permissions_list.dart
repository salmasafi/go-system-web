import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/permission/cubit/permission_cubit.dart';
import 'package:systego/features/admin/permission/model/permission_model.dart';
import 'package:systego/features/admin/permission/presentation/view/edit_permission_screen.dart';
import 'package:systego/features/admin/permission/presentation/widgets/delete_permission_widget.dart';
import 'package:systego/features/admin/permission/presentation/widgets/permission_card.dart';

class PermissionsList extends StatefulWidget {
  final List<PermissionModel> permissions;

  const PermissionsList({super.key, required this.permissions});

  @override
  State<PermissionsList> createState() => _PermissionsListState();
}

class _PermissionsListState extends State<PermissionsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: widget.permissions.length,
      itemBuilder: (context, index) {
        return AnimatedPermissionCard(
          permission: widget.permissions[index],
          // index: index,
          onDelete: () =>
              _showDeleteDialog(context, widget.permissions[index]),
          onEdit: () =>
              _showEditDialog(context, widget.permissions[index]),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // EDIT
  // ---------------------------------------------------------------------------

  void _showEditDialog(BuildContext context, PermissionModel permission) {
    showDialog(
      context: context,
      builder: (context) => EditPermissionBottomSheet(
        permission: permission,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  void _showDeleteDialog(BuildContext context, PermissionModel permission) {
    if (permission.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid permission id');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DeletePermissionDialog(
        permissionName: permission.name,
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<PermissionCubit>().deletePermission(permission.id);
        },
      ),
    );
  }
}
