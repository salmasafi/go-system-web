import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../model/checkout_models.dart';
import 'cart_item_attribute_display.dart';
import 'cart_item_details_dialog.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongPress;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongPress,
  });

  void _showItemDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CartItemDetailsDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasVariation = item.selectedVariation != null;

    return InkWell(
      onTap: () => _showItemDetails(context),
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 16),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveUI.padding(context, 6),
        ),
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          border: Border.all(
            color: hasVariation
                ? AppColors.primaryBlue.withValues(alpha: 0.3)
                : AppColors.lightGray.withValues(alpha: 0.5),
            width: hasVariation ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowGray.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            _buildProductImage(),
            SizedBox(width: ResponsiveUI.value(context, 12)),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Info Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 15),
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          size: ResponsiveUI.iconSize(context, 20),
                          color: AppColors.primaryBlue,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showItemDetails(context),
                      ),
                    ],
                  ),

                  // Attribute display (Color: Red, Size: M, etc.)
                  if (item.hasSelectedAttributes || item.hasBundleAttributes)
                    CartItemAttributeDisplay(item: item),

                  // Variation Code (if exists)
                  SizedBox(height: ResponsiveUI.value(context, 4)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 8),
                      vertical: ResponsiveUI.padding(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 6),
                      ),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: ResponsiveUI.iconSize(context, 12),
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(width: ResponsiveUI.value(context, 4)),
                        Text(
                          hasVariation
                              ? item.selectedVariation!.code
                              : item.product.code,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 11),
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Variation Options (if exists)
                  if (hasVariation &&
                      item.selectedVariation!.variations.isNotEmpty) ...[
                    SizedBox(height: ResponsiveUI.value(context, 6)),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.selectedVariation!.variations
                          .take(2)
                          .expand((v) {
                            return v.options.map((opt) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUI.padding(context, 6),
                                  vertical: ResponsiveUI.padding(context, 2),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUI.borderRadius(context, 4),
                                  ),
                                ),
                                child: Text(
                                  '${v.name}: ${opt.name}',
                                  style: TextStyle(
                                    fontSize: ResponsiveUI.fontSize(
                                      context,
                                      10,
                                    ),
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              );
                            });
                          })
                          .toList(),
                    ),
                    if (item.selectedVariation!.variations.length > 2)
                      Padding(
                        padding: EdgeInsets.only(
                          top: ResponsiveUI.padding(context, 6),
                        ),
                        child: Text(
                          '+${item.selectedVariation!.variations.length - 2} more',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 10),
                            color: AppColors.primaryBlue.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],

                  SizedBox(height: ResponsiveUI.value(context, 8)),

                  // Price & Quantity Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      _buildPriceDisplay(context),

                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: ResponsiveUI.value(context, 1.5),
                          ),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUI.borderRadius(context, 8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: onDecrement,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(
                                  ResponsiveUI.borderRadius(context, 8),
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(
                                  ResponsiveUI.padding(context, 6),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: ResponsiveUI.iconSize(context, 18),
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPress: onLongPress,
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 32),
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUI.padding(context, 8),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ResponsiveUI.fontSize(
                                      context,
                                      16,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onIncrement,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(
                                  ResponsiveUI.borderRadius(context, 8),
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(
                                  ResponsiveUI.padding(context, 6),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: ResponsiveUI.iconSize(context, 18),
                                  color: AppColors.successGreen,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildPriceDisplay(BuildContext context) {
    if (item.isWholePriceActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${item.wholePrice!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: AppColors.successGreen,
            ),
          ),
          Text(
            '\$${item.basePrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: AppColors.linkBlue,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 2)),
          Text(
            'Wholesale price active (≥ ${item.startQuantity})',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 10),
              color: AppColors.primaryBlue.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }
    return Text(
      '\$${item.basePrice.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 16),
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.5)),
      ),
      child: item.product.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                item.product.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 32,
        color: AppColors.lightGray,
      ),
    );
  }
}
