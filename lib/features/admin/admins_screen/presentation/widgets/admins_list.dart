import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:systego/features/admin/admins_screen/model/admins_model.dart';
import 'package:systego/features/admin/admins_screen/presentation/view/edit_permission_screen.dart';
import 'package:systego/features/admin/admins_screen/presentation/widgets/admin_animated_card.dart';
import 'package:systego/generated/locale_keys.g.dart';

import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class AdminsList extends StatefulWidget {
  final List<AdminModel> admins;

  const AdminsList({super.key, required this.admins});

  @override
  State<AdminsList> createState() => _AdminsListState();
}

class _AdminsListState extends State<AdminsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: widget.admins.length,
      itemBuilder: (context, index) {
        final admin = widget.admins[index];

        final isSuperAdmin = admin.role.toLowerCase() == 'superadmin';

        return AnimatedAdminCard(
          admin: admin,
          index: index,
          onEdit: !isSuperAdmin 
              ? () => _showEditDialog(context, admin)
              : null,
          //  () => _showEditDialog(context, admin),
          onDelete: () => _showDeleteDialog(context, admin),
        );
      },
    );
  }


    void _showEditDialog(BuildContext context, AdminModel admin) async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditPermissionsBottomSheet(
        userId: admin.id,
      username: admin.username,
      email: admin.email,
      )
    );
    if (result == true && mounted) {  // Check result
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminsCubit>().getAdmins();
    });
  }
  }


  // ==================== DELETE ====================
  void _showDeleteDialog(BuildContext context, AdminModel admin) {
    if (admin.id.isEmpty) {
      CustomSnackbar.showError(
        context,
        "LocaleKeys.invalid_admin_id.tr()",
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: "Delete Admin",
        message:
            'Are You sure you want to delete this admin? ${admin.username}',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<AdminsCubit>().deleteAdmin(admin.id);
        },
      ),
    );
  }
}
