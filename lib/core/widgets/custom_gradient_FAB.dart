import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomGradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? startColor;
  final Color? endColor;
  final BorderRadius? borderRadius;

  const CustomGradientFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.startColor,
    this.endColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            startColor ?? AppColors.primaryBlue,
            endColor ?? AppColors.darkBlue,
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: (startColor ?? AppColors.primaryBlue).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 20), vertical: ResponsiveUI.padding(context, 14)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                if (label != null) ...[
                  SizedBox(width: ResponsiveUI.value(context, 8)),
                  Text(
                    label!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
