import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';

class CustomStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double? iconSize;
  final double? fontSize;

  const CustomStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
          vertical: ResponsiveUI.padding(context, 10)
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: ResponsiveUI.iconSize(context, iconSize ?? 18),
              color: color),
          SizedBox(width: ResponsiveUI.spacing(context, 6)),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, fontSize ?? 12),
                fontWeight: FontWeight.w600,
                color: color,
              ),
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}