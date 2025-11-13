import 'package:flutter/material.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
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
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryBlue).withOpacity(
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 100,
                color: iconColor ?? AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.darkGray.withOpacity(0.7),
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              CustomElevatedButton(onPressed: onAction, text: actionLabel!),
            ],
          ],
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
