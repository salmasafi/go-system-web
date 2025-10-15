import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';

class CustomDetailTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;

  const CustomDetailTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 8)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 20),
            color: iconColor ?? AppColors.primaryBlue,
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: AppColors.darkGray.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 15),
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}