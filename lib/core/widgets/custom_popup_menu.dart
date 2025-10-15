import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomPopupMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? backgroundColorMenu;

  const CustomPopupMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.backgroundColor,
    this.backgroundColorMenu
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton(
        color: backgroundColorMenu,
        icon: Icon(Icons.more_vert, color: AppColors.darkGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        itemBuilder: (context) => [
          if (onEdit != null)
            PopupMenuItem(
              onTap: onEdit,
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  const Text('Edit', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          if (onDelete != null)
            PopupMenuItem(
              onTap: onDelete,
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.red, size: 20),
                  const SizedBox(width: 12),
                  const Text('Delete', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}