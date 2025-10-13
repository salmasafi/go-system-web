import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomIconContainer extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? padding;
  final BorderRadius? borderRadius;

  const CustomIconContainer({
    super.key,
    required this.icon,
    this.size,
    this.gradient,
    this.backgroundColor,
    this.iconColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding ?? 14),
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: gradient != null
            ? [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: size ?? 30,
      ),
    );
  }
}
