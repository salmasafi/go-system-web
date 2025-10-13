import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;
  final Color? iconColor;

  const CustomErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.red).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: 80,
              color: iconColor ?? AppColors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title ?? 'Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray.withOpacity(0.7),
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}