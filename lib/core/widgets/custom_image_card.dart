import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';

class CustomImageContainer extends StatelessWidget {
  final String? image;
  final IconData? icon;
  final double? size;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? padding;
  final BorderRadius? borderRadius;

  const CustomImageContainer({
    super.key,
    required this.image,
    this.icon,
    this.size,
    this.gradient,
    this.backgroundColor,
    this.iconColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveUI.value(
        context, //size ??
        100,
      ),
      width: ResponsiveUI.value(context, 90),
      clipBehavior: Clip.antiAlias,
      //padding: EdgeInsets.all(padding ?? 14),
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: gradient != null
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: (image != null)
          ? SizedBox(
              height: ResponsiveUI.value(
                context, //size ??
                120,
              ),
              // width: ResponsiveUI.value(context, size ?? double.maxFinite),
              child: Image.network(
                image!,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    icon ?? Icons.inventory_2,
                    color: AppColors.white,
                    size: ResponsiveUI.iconSize(context, 30),
                  );
                },
              ),
            )
          : Icon(
              icon ?? Icons.inventory_2,
              color: iconColor ?? Colors.white,
              size: size != null
                  ? ResponsiveUI.iconSize(context, 70)
                  : ResponsiveUI.iconSize(context, 30),
            ),
    );
  }
}
