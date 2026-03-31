import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? color;
  final VoidCallback? onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primaryBlue;
    final inactiveColor = AppColors.darkGray.withValues(alpha: 0.5);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: activeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
                child: Icon(
                  icon,
                  size: ResponsiveUI.iconSize(context, 26),
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              SizedBox(height: ResponsiveUI.value(context, 4)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
              if (isActive)
                Container(
                  margin: EdgeInsets.only(top: ResponsiveUI.padding(context, 4)),
                  height: ResponsiveUI.value(context, 3),
                  width: ResponsiveUI.value(context, 24),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 2)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
