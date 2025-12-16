import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CustomDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDelete;
  final String? cancelText;
  final String? deleteText;
  final IconData? icon;
  final Color? iconColor;

  const CustomDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDelete,
    this.cancelText,
    this.deleteText,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final paddingValue = ResponsiveUI.padding(context, 24);
    final iconSize = ResponsiveUI.iconSize(context, 50);
    final fontSizeTitle = ResponsiveUI.fontSize(context, 22);
    final fontSizeMessage = ResponsiveUI.fontSize(context, 14);
    final buttonPadding = ResponsiveUI.padding(context, 14);
    final borderRadius = ResponsiveUI.borderRadius(context, 24);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(paddingValue),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.red).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.warning_amber_rounded,
                color: iconColor ?? AppColors.red,
                size: iconSize,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 20)),
            Text(
              title,
              style: TextStyle(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSizeMessage),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 24)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      side: BorderSide(color: AppColors.lightGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12),
                        ),
                      ),
                    ),
                    child: Text(
                      cancelText ?? LocaleKeys.cancel.tr(),
                      style: TextStyle(
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor ?? AppColors.red,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12),
                        ),
                      ),
                    ),
                    child: Text(deleteText ?? LocaleKeys.delete.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
