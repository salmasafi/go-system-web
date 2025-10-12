import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/product/presentation/widgets/product_image.dart';
import 'package:systego/features/product/presentation/widgets/product_info.dart';
import 'package:systego/features/product/presentation/widgets/product_menu.dart';

class ProductCard extends StatelessWidget {
  final String brand;
  final String title;
  final String category;
  final String code;
  final String quantity;
  final String price;
  final String unit;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.brand,
    required this.title,
    required this.category,
    required this.code,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ProductImage(imageUrl: imageUrl),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: ProductInfo(
              brand: brand,
              title: title,
              category: category,
              code: code,
              quantity: quantity,
              price: price,
              unit: unit,
            ),
          ),
          ProductMenu(),
        ],
      ),
    );
  }
}

