import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';

class ProductImageCard extends StatelessWidget {
  final String imageUrl;

  const ProductImageCard({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveUI.imageHeight(context),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[100],
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: AppColors.shadowGray[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.phone_iphone,
                size: ResponsiveUI.iconSize(context, 80),
                color: AppColors.shadowGray,
              ),
            );
          },
        ),
      ),
    );
  }
}
