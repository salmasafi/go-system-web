import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import '../../constants/app_colors.dart';

class CustomEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Color? iconColor;
  final VoidCallback? onAction;
  final String? actionLabel;
  final RefreshCallback? onRefresh;

  const CustomEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.iconColor,
    this.onAction,
    this.actionLabel,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Container(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 50)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryBlue).withValues(alpha:
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: ResponsiveUI.iconSize(context, 64),
                color: iconColor ?? AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: ResponsiveUI.value(context, 24)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: ResponsiveUI.value(context, 12)),
              Text(
                message!,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  color: AppColors.darkGray.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: ResponsiveUI.value(context, 32)),
              CustomElevatedButton(onPressed: onAction, text: actionLabel!),
            ],
          ],
        ),
        ),
      ),
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.primaryBlue,
        child: content,
      );
    }

    return content;
  }
}

