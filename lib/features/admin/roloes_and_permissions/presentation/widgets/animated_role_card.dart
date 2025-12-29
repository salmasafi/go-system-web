import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/roloes_and_permissions/model/role_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedRoleCard extends StatefulWidget {
  final RoleModel role;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedRoleCard({
    super.key,
    required this.role,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedRoleCard> createState() => _AnimatedRoleCardState();
}

class _AnimatedRoleCardState extends State<AnimatedRoleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    // final isActive = role.status;

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
                  _buildRoleHeader(role),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildRoleInfo(role),
                  if (role.permissions.isNotEmpty) ...[
                    SizedBox(height: ResponsiveUI.spacing(context, 12)),
                    _buildPermissionsSection(role),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleHeader(RoleModel role) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Status indicator
        Container(
          width: ResponsiveUI.value(context, 8),
          height: ResponsiveUI.value(context, 40),
          decoration: BoxDecoration(
            color: role.status == 'active'
              ? AppColors.successGreen 
              : AppColors.red,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 4),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        
        // Role Icon
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.lightBlueBackground,
          child: Icon(
            Icons.verified_user,
            color: AppColors.primaryBlue,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        
        // Role Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role.name,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: ResponsiveUI.fontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                '${role.permissionsCount} ${LocaleKeys.permissions.tr()}',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),

        // Action menu
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildRoleInfo(RoleModel role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status and Created Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 12),
                vertical: ResponsiveUI.padding(context, 6),
              ),
              decoration: BoxDecoration(
                color: role.status == 'active'
                  ? AppColors.successGreen.withOpacity(0.1)
                  : AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    role.status == 'active' 
                      ? Icons.check_circle 
                      : Icons.cancel,
                    size: ResponsiveUI.iconSize(context, 14),
                    color: role.status == 'active' 
                      ? AppColors.successGreen 
                      : AppColors.red,
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 4)),
                  Text(
                    role.status == 'active' 
                      ? LocaleKeys.active.tr() 
                      : LocaleKeys.inactive.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      fontWeight: FontWeight.w500,
                      color: role.status == 'active' 
                        ? AppColors.successGreen 
                        : AppColors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Created date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: ResponsiveUI.iconSize(context, 14),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 4)),
                Text(
                  _formatDate(role.createdAt),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: AppColors.darkGray.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // Modules count
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 12),
            vertical: ResponsiveUI.padding(context, 8),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 12),
            ),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.apps,
                size: ResponsiveUI.iconSize(context, 16),
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 8)),
              Expanded(
                child: Text(
                  '${role.permissions.length} ${LocaleKeys.modules.tr()}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (role.permissions.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryBlue,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(RoleModel role) {
    if (!_isExpanded) return const SizedBox();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.permissions.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          ...role.permissions.map((permission) {
            final moduleName = permission.module;
            final actionNames = permission.actions.map((a) => a.action).join(', ');
            
            return Container(
              margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
                border: Border.all(
                  color: AppColors.lightGray,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: ResponsiveUI.value(context, 8),
                        height: ResponsiveUI.value(context, 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 8)),
                      Expanded(
                        child: Text(
                          moduleName,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      Text(
                        '${permission.actions.length} ${LocaleKeys.actions.tr()}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.darkGray.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 6)),
                  if (actionNames.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: ResponsiveUI.padding(context, 16)),
                      child: Text(
                        actionNames,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.darkGray.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

}