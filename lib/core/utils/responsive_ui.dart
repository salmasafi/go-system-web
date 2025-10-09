import 'package:flutter/material.dart';

class ResponsiveUI {
  // Screen dimensions
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Device type detection
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 1200;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1200;

  // Responsive font size
  static double fontSize(BuildContext context, {double mobile = 12.0, double tablet = 14.0, double desktop = 16.0}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  // Responsive padding
  static double padding(BuildContext context, {double mobile = 8.0, double tablet = 12.0, double desktop = 16.0}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  // Responsive icon size
  static double iconSize(BuildContext context, {double mobile = 24.0, double tablet = 28.0, double desktop = 32.0}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  // Responsive spacer for FAB notch in BottomAppBar (approximate based on screen width)
  static double fabNotchSpacer(BuildContext context) {
    final width = screenWidth(context);
    if (isMobile(context)) return 60.0;
    if (isTablet(context)) return 80.0;
    return 100.0;
  }

  // Responsive bottom nav height
  static double bottomNavHeight(BuildContext context, {double mobile = 80.0, double tablet = 100.0, double desktop = 120.0}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}