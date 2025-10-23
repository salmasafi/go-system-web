import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/responsive_ui.dart';

Widget buildLoadingOverlay(BuildContext context) {
  final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
  final borderRadius20 = ResponsiveUI.borderRadius(context, 20);
  final padding30 = ResponsiveUI.padding(context, 30);
  //final value20 = ResponsiveUI.value(context, 20);
  final strokeWidth3 = ResponsiveUI.value(context, 3);
  final spacing20 = ResponsiveUI.spacing(context, 20);
  final fontSize16 = ResponsiveUI.fontSize(context, 16);
  final value10 = ResponsiveUI.value(context, 0.1);
  final value20Blur = ResponsiveUI.value(context, 20);

  return Container(
    decoration: BoxDecoration(
      color: AppColors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(borderRadius24),
    ),
    child: Center(
      child: Container(
        padding: EdgeInsets.all(padding30),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(value10),
              blurRadius: value20Blur,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: strokeWidth3,
            ),
            SizedBox(height: spacing20),
            Text(
              'Processing...',
              style: TextStyle(
                fontSize: fontSize16,
                fontWeight: FontWeight.w600,
                color: AppColors.shadowGray[700],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
