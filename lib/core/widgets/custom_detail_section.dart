import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  final Color? backgroundColor;

  const CustomDetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
              ),
              child: Icon(icon, color: iconColor, size: ResponsiveUI.iconSize(context, 20)),
            ),
            SizedBox(width: ResponsiveUI.value(context, 12)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 17),
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUI.value(context, 12)),
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.white,
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
            border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.5)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
