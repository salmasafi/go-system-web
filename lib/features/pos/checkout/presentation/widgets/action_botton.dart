import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';

class POSActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const POSActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 14)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: ResponsiveUI.iconSize(context, 20)),
          SizedBox(width: ResponsiveUI.spacing(context, 8)),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
