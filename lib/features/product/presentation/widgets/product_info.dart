import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/product/presentation/widgets/info_label.dart';

class ProductInfo extends StatelessWidget {
  final String brand;
  final String title;
  final String category;
  final String code;
  final String quantity;
  final String price;
  final String unit;

  const ProductInfo({
    super.key,
    required this.brand,
    required this.title,
    required this.category,
    required this.code,
    required this.quantity,
    required this.price,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brand,
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: ResponsiveUI.fontSize(context, 11),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        Row(
          children: [
            InfoLabel(label: category),
            SizedBox(width: ResponsiveUI.spacing(context, 8)),
            InfoLabel(label: code),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        Row(
          children: [
            Text(
              quantity,
              style: TextStyle(
                color: AppColors.shadowGray[600],
                fontSize: ResponsiveUI.fontSize(context, 12),
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 16)),
            Text(
              price,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 4)),
            Text(
              '• $unit',
              style: TextStyle(
                color: AppColors.shadowGray[500],
                fontSize: ResponsiveUI.fontSize(context, 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
