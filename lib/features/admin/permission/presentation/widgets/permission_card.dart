import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/permission/model/permission_model.dart';

class AnimatedPermissionCard extends StatefulWidget {
  final PermissionModel permission;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const AnimatedPermissionCard({
    super.key,
    required this.permission,
    this.onDelete,
    this.onEdit,
    this.onTap,
  });

  @override
  State<AnimatedPermissionCard> createState() =>
      _AnimatedPermissionCardState();
}

class _AnimatedPermissionCardState extends State<AnimatedPermissionCard> {
  @override
  Widget build(BuildContext context) {
    final permission = widget.permission;

    return AnimatedElement(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, AppColors.lightBlueBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.1),
              blurRadius: ResponsiveUI.borderRadius(context, 10),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(permission),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  _buildRoles(permission.roles),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// HEADER: Permission name + menu
  Widget _buildHeader(PermissionModel permission) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user,
          color: AppColors.primaryBlue,
          size: ResponsiveUI.fontSize(context, 32),
        ),

        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        Expanded(
          child: Text(
            permission.name,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ),

        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
          ),
      ],
    );
  }

  /// ROLES LIST + ACTIONS
  Widget _buildRoles(List<RoleModel> roles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: roles.map((role) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ROLE name
              Text(
                role.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 6)),

              /// ACTIONS
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: role.actions.map((action) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        color: AppColors.darkGray,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
