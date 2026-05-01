import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomPopupMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color? backgroundColor;

  const CustomPopupMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: AppColors.darkGray,
          size: ResponsiveUI.iconSize(context, 24),
        ),
        offset: const Offset(0, 45),
        elevation: ResponsiveUI.value(context, 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
        color: Colors.white,
        itemBuilder: (context) {
          List<PopupMenuEntry<dynamic>> items = [];

          if (onEdit != null) {
            items.add(
              PopupMenuItem(
                onTap: onEdit,
                height: ResponsiveUI.value(context, 50),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 8), vertical: ResponsiveUI.padding(context, 4)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: AppColors.primaryBlue,
                          size: ResponsiveUI.iconSize(context, 20),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 12)),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUI.fontSize(context, 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (onEdit != null && onDelete != null) {
            items.add(PopupMenuDivider(height: ResponsiveUI.value(context, 1)));
          }

          if (onDelete != null) {
            items.add(
              PopupMenuItem(
                onTap: onDelete,
                height: ResponsiveUI.value(context, 50),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 8), vertical: ResponsiveUI.padding(context, 4)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppColors.red,
                          size: ResponsiveUI.iconSize(context, 20),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 12)),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUI.fontSize(context, 15),
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return items;
        },
      ),
    );
  }
}
