import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import '../../../../../core/constants/app_colors.dart';

class POSProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final int cartQuantity;

  POSProductCard({
    required this.product,
    required this.onTap,
    required this.cartQuantity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                //height: ResponsiveUI.value(context, 100),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      ResponsiveUI.borderRadius(context, 16),
                    ),
                  ),
                ),
                child: Center(
                  child: product.image != null
                      ? CachedNetworkImage(
                          imageUrl: product.image!,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const CustomLoadingState(),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.image,
                            size: ResponsiveUI.iconSize(context, 40),
                          ),
                        )
                      : Icon(
                          Icons.image,
                          size: ResponsiveUI.iconSize(context, 40),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // في build، في Row السعر:
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPrice(context),
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveUI.padding(context, 6),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              ResponsiveUI.borderRadius(context, 8),
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: ResponsiveUI.iconSize(context, 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    final hasWholesale =
        product.wholePrice != null &&
        product.startQuantity != null &&
        product.startQuantity! > 0;
    final wholesaleActive =
        hasWholesale && cartQuantity >= product.startQuantity!;
    final baseLabel = product.differentPrice
        ? 'From \$${product.price.toStringAsFixed(2)}'
        : '\$${product.price.toStringAsFixed(2)}';

    if (wholesaleActive) {
      final wholesaleLabel = product.differentPrice
          ? 'From \$${product.wholePrice!.toStringAsFixed(2)}'
          : '\$${product.wholePrice!.toStringAsFixed(2)}';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wholesaleLabel,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              fontWeight: FontWeight.bold,
              color: AppColors.successGreen,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 2)),
          Text(
            baseLabel,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 10),
              color: AppColors.linkBlue,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    return Text(
      baseLabel,
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 12),
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
    );
  }
}
