import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import '../../../../../core/widgets/animation/simple_fadein_animation_widget.dart';

class CustomGridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Duration delay;

  const CustomGridCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: delay,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.mediumBlue700.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppColors.mediumBlue700.withValues(alpha: 0.1),
              width: ResponsiveUI.value(context, 1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                decoration: BoxDecoration(
                  color: AppColors.mediumBlue700[700]?.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: ResponsiveUI.iconSize(context, 48),
                  color: AppColors.mediumBlue700[700],
                ),
              ),
              SizedBox(height: ResponsiveUI.value(context, 12)),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

