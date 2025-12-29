import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:systego/features/admin/roloes_and_permissions/model/role_model.dart';
import 'package:systego/features/admin/roloes_and_permissions/presentation/view/edit_role_permissions_screen.dart';
import 'package:systego/features/admin/roloes_and_permissions/presentation/widgets/animated_role_card.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';


class RolesList extends StatefulWidget {
  final List<RoleModel> roles;
  const RolesList({super.key, required this.roles});

  @override
  State<RolesList> createState() => _RolesListState();
}

class _RolesListState extends State<RolesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: widget.roles.length,
      itemBuilder: (context, index) {
        return AnimatedRoleCard(
          role: widget.roles[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, widget.roles[index]),
          onEdit: () => _showEditDialog(context, widget.roles[index]),
        );
      },
    );
  }

  // void _showEditDialog(BuildContext context, RoleModel role) {
  void _showEditDialog(BuildContext context, RoleModel role) async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditRolesBottomSheet(
        currentPermissions: role.permissions,
        roleId: role.id,
      status: role.status,
      roleName: role.name,
      permissionCount: role.permissionsCount,
      )
    );
    if (result == true && mounted) {  // Check result
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolesCubit>().getAllRoles();
    });
  }
  }

  void _showDeleteDialog(BuildContext context, RoleModel role) {
    if (role.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_role_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_role.tr(),
        message:
            '${LocaleKeys.delete_role_message.tr()} \n"${role.name}"?',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<RolesCubit>().deleteRole(roleId: role.id);
        },
      ),
    );
  }
}