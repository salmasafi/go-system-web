import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../../../core/constants/app_colors.dart';

class ProductDetailsDialog extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailsDialog({
    required this.product,
    required this.onAddToCart,
    super.key,
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
            Flexible(child: _buildBody(context)),
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
          if (product.image != null)
            Container(
              width: ResponsiveUI.value(context, 60),
              height: ResponsiveUI.value(context, 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                color: AppColors.white,
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: product.image!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Icon(Icons.image, size: ResponsiveUI.iconSize(context, 30)),
              ),
            ),
          if (product.image != null) SizedBox(width: ResponsiveUI.value(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUI.value(context, 4)),
                Text(
                  product.code,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    color: AppColors.white.withValues(alpha: 0.85),
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

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            context,
            icon: Icons.attach_money,
            label: 'Price',
            value: product.differentPrice
                ? 'From ${product.price.toStringAsFixed(2)}'
                : '${product.price.toStringAsFixed(2)}',
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          _infoRow(
            context,
            icon: Icons.inventory_2_outlined,
            label: 'Stock',
            value: product.quantity.toString(),
            valueColor: product.quantity > 0 ? AppColors.successGreen : AppColors.red,
          ),
          if (product.description.isNotEmpty) ...[
            SizedBox(height: ResponsiveUI.value(context, 16)),
            Divider(height: ResponsiveUI.value(context, 1)),
            SizedBox(height: ResponsiveUI.value(context, 16)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: ResponsiveUI.iconSize(context, 18),
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: ResponsiveUI.value(context, 10)),
                Expanded(
                  child: Text(
                    product.description,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: ResponsiveUI.iconSize(context, 20), color: AppColors.primaryBlue),
        SizedBox(width: ResponsiveUI.value(context, 10)),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.darkBlue,
          ),
        ),
      ],
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
