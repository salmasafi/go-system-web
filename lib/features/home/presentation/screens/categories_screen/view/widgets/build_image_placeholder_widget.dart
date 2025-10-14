import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';

class CustomImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double? fontSize;

  const CustomImagePlaceholder({
    super.key,
    this.icon = Icons.image,
    this.text = 'No Image',
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.grey[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.grey[400],
            size: iconSize ?? ResponsiveUI.iconSize(context, 40),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.grey[600],
                fontSize: fontSize ?? ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}