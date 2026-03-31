import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';

class BundleCard extends StatelessWidget {
  final BundleModel bundle;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const BundleCard({
    super.key,
    required this.bundle,
    required this.index,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: Duration(milliseconds: 100 * index),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(context),
              Expanded(child: _buildInfoSection(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: ResponsiveUI.value(context, 100),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.redeem,
              color: AppColors.primaryBlue,
              size: ResponsiveUI.iconSize(context, 48),
            ),
          ),
        ),
        Positioned(
          top: ResponsiveUI.value(context, 8),
          right: ResponsiveUI.value(context, 8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 6),
              vertical: ResponsiveUI.padding(context, 3),
            ),
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 8),
              ),
            ),
            child: Text(
              '-${bundle.savingsPercentage}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUI.fontSize(context, 11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            bundle.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 2)),
          Text(
            '${bundle.products.length} Items',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 11),
              color: AppColors.linkBlue,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 6)),
          Text(
            '${bundle.originalPrice.toStringAsFixed(2)} EGP',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 11),
              color: AppColors.primaryBlue,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 2)),
          Text(
            '${bundle.price.toStringAsFixed(2)} EGP',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 2)),
          Text(
            'Save ${bundle.savings.toStringAsFixed(2)} EGP',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 11),
              color: AppColors.successGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 8),
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
