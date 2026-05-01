import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: ResponsiveUI.value(context, 50),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          ),
          elevation: isLoading ? 0 : 4,
          shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: ResponsiveUI.value(context, 20),
                width: ResponsiveUI.value(context, 20),
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 18),
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }
}

