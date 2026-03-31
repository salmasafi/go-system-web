// ── Floating cart button ───────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';

class POSCartFAB extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const POSCartFAB({
    required this.itemCount,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryBlue,
      icon: Icon(Icons.shopping_cart, color: AppColors.white),
      label: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 8),
          vertical: ResponsiveUI.padding(context, 4),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        ),
        child: Text(
          '$itemCount',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
