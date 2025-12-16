import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/features/admin/admins_screen/model/admins_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedAdminCard extends StatefulWidget {
  final AdminModel admin;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedAdminCard({
    super.key,
    required this.admin,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedAdminCard> createState() => _AnimatedAdminCardState();
}

class _AnimatedAdminCardState extends State<AnimatedAdminCard> {
  @override
  Widget build(BuildContext context) {
    final admin = widget.admin;
    final isActive = admin.status.toLowerCase() == 'active';

    return AnimatedElement(
      delay: widget.animationDelay ?? const Duration(milliseconds: 200),
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
          border: isActive
              ? Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.8),
                  width: 2.5,
                )
              : null,
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
                  _buildAdminHeader(admin),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(admin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildAdminHeader(AdminModel admin) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Text(
            admin.username.isNotEmpty
                ? admin.username[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUI.fontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
              Text(
                admin.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  // ================= FOOTER =================
  Widget _buildFooter(AdminModel admin) {
    final isActive = admin.status.toLowerCase() == 'active';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company
        Text(
          admin.companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: AppColors.darkGray,
          ),
        ),

        SizedBox(height: ResponsiveUI.spacing(context, 10)),

        Row(
          children: [
            // Warehouse
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WareHouse",
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.darkGray.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 2)),
                  Text(
                    admin.warehouseName ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: ResponsiveUI.spacing(context, 80)),

            // Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Role",
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.darkGray.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 2)),
                  Text(
                    admin.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // Status
        Text(
          isActive
              ? LocaleKeys.bank_accounts_active.tr()
              : LocaleKeys.bank_accounts_inactive.tr(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            fontWeight: FontWeight.w500,
            color:
                isActive ? AppColors.successGreen : AppColors.darkGray.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
