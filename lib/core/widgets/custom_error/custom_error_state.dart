import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;
  final Color? iconColor;

  const CustomErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.red).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: ResponsiveUI.iconSize(context, 80),
              color: iconColor ?? AppColors.red,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 24)),
          Text(
            title ?? 'Error',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 40)),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: ResponsiveUI.value(context, 32)),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 40), vertical: ResponsiveUI.padding(context, 16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                ),
                elevation: ResponsiveUI.value(context, 5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
