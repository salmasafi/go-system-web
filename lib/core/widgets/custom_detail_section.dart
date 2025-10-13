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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}