import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/pos/home/model/pos_models.dart';

class BundleDetailsDialog extends StatelessWidget {
  final BundleModel bundle;
  final VoidCallback onAddToCart;

  const BundleDetailsDialog({
    super.key,
    required this.bundle,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(child: _buildProductList(context)),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          topRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.redeem, color: AppColors.white, size: ResponsiveUI.iconSize(context, 32)),
          SizedBox(width: ResponsiveUI.value(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bundle.name,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUI.value(context, 4)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 8),
                    vertical: ResponsiveUI.padding(context, 2),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                  ),
                  child: Text(
                    '-${bundle.savingsPercentage}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${bundle.originalPrice.toStringAsFixed(2)} EGP',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.primaryBlue,
                ),
              ),
              Text(
                '${bundle.price.toStringAsFixed(2)} EGP',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.value(context, 4)),
          Text(
            'Save ${bundle.savings.toStringAsFixed(2)} EGP',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: AppColors.successGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 16)),
          Divider(height: ResponsiveUI.value(context, 1)),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Text(
            'Products (${bundle.products.length})',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 8)),
          ...bundle.products.map((p) => _buildProductRow(context, p)),
        ],
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, BundleProduct product) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 6)),
      child: Row(
        children: [
          Icon(Icons.circle, size: ResponsiveUI.iconSize(context, 8), color: AppColors.primaryBlue),
          SizedBox(width: ResponsiveUI.value(context, 10)),
          Expanded(
            child: Text(
              product.name,
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
            ),
          ),
          Text(
            'x${product.quantity}',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(width: ResponsiveUI.value(context, 12)),
          Text(
            '${product.price.toStringAsFixed(2)} EGP',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 14)),
                side: BorderSide(color: AppColors.lightGray, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  color: AppColors.darkGray,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.value(context, 12)),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                onAddToCart();
                Navigator.pop(context);
              },
              icon: Icon(Icons.shopping_cart, size: ResponsiveUI.iconSize(context, 20), color: AppColors.white),
              label: Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 14)),
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
