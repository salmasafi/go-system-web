// ── AppBar ───────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';

class POSAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  const POSAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '06-11-2025',
            style: TextStyle(
              color: AppColors.white,
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Shop 1 • John Watson',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: ResponsiveUI.fontSize(context, 12),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.home_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
      ],
    );
  }
}
