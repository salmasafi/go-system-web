import 'package:flutter/material.dart';

class ResponsiveUI {
  // Screen dimensions
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Device type detection with better breakpoints
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= 600 && screenWidth(context) < 1024;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1024;

  // Additional helper for large desktop screens
  static bool isLargeDesktop(BuildContext context) =>
      screenWidth(context) >= 1440;

  // Scale factor based on screen width for more fluid scaling
  static double scaleFactor(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 0.85; // Small mobile
    if (width < 600) return 1.0; // Normal mobile
    if (width < 1024) return 1.15; // Tablet
    if (width < 1440) return 1.3; // Desktop
    return 1.5; // Large desktop
  }

  // Base responsive value calculator
  static double value(BuildContext context, double mobileValue) {
    return mobileValue * scaleFactor(context);
  }
  // Get responsive values
  static double fontSize(BuildContext context, double mobileSize) {
    return value(context, mobileSize);
  }

  static double padding(BuildContext context, double mobilePadding) {
    return value(context, mobilePadding);
  }

  static double spacing(BuildContext context, double mobileSpacing) {
    return value(context, mobileSpacing);
  }

  static double iconSize(BuildContext context, double mobileSize) {
    return value(context, mobileSize);
  }

  static double borderRadius(BuildContext context, double mobileRadius) {
    return value(context, mobileRadius);
  }

  // Get optimal content width based on screen size
  static double contentMaxWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isMobile(context)) return width;
    if (isTablet(context)) return 600.0;
    if (isLargeDesktop(context)) return 900.0;
    return 750.0;
  }

  // Get grid columns based on screen size
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 2;
  }

  // Responsive image aspect ratio
  static double imageHeight(BuildContext context) {
    if (isMobile(context)) return screenHeight(context) * 0.35;
    if (isTablet(context)) return 400.0;
    return 450.0;
  }

  // Horizontal padding for screen edges
  static double horizontalPadding(BuildContext context) {
    return value(context, 16.0);
  }

  // Vertical spacing multiplier
  static double verticalSpacing(BuildContext context, double multiplier) {
    return value(context, 8.0 * multiplier);
  }
}