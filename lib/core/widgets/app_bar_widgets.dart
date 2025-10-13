import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? startColor;
  final Color? endColor;
  final double? height;

  const CustomGradientAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.startColor,
    this.endColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              startColor ?? AppColors.primaryBlue,
              endColor ?? AppColors.darkBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (startColor ?? AppColors.primaryBlue).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (onBackPressed != null)
                  IconButton(
                    onPressed: onBackPressed,
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                if (onBackPressed != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 70);
}