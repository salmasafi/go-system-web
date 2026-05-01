import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;

  const ProductImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final imageSize = ResponsiveUI.value(context, 60);

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 8),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 8),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.phone_iphone,
              color: AppColors.white,
              size: ResponsiveUI.iconSize(context, 30),
            );
          },
        ),
      ),
    );
  }
}

