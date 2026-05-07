import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart';
import 'package:GoSystem/features/admin/product/presentation/widgets/info_label.dart';

class ProductInfo extends StatelessWidget {
  final Product product;

  const ProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.brandId.name,
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: ResponsiveUI.fontSize(context, 11),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        Text(//////
          product.name,
          style: TextStyle(
            color: Colors.black87,
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        InfoLabel(
          label: product.categoryId.isNotEmpty
              ? product.categoryId[0].name
              : '',
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        Row(
          children: [
            Text(
              product.quantity.toString(),
              style: TextStyle(
                color: AppColors.shadowGray[600],
                fontSize: ResponsiveUI.fontSize(context, 12),
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 16)),
            Text(
              product.price.toString(),
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 4)),
            Text(
              '• ${product.saleUnit.isNotEmpty ? product.saleUnit : product.purchaseUnit}',
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
