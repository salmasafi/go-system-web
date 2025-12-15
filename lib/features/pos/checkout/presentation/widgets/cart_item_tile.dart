import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../model/checkout_models.dart';
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasVariation
                ? AppColors.primaryBlue.withOpacity(0.3)
                : AppColors.lightGray.withOpacity(0.5),
            width: hasVariation ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowGray.withOpacity(0.08),
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
            const SizedBox(width: 12),

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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppColors.primaryBlue,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showItemDetails(context),
                      ),
                    ],
                  ),

                  // Variation Code (if exists)
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code,
                          size: 12,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasVariation
                              ? item.selectedVariation!.code
                              : item.product.code,
                          style: const TextStyle(
                            fontSize: 11,
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
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.selectedVariation!.variations
                          .take(2)
                          .expand((v) {
                            return v.options.map((opt) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(
                                    0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${v.name}: ${opt.name}',
                                  style: const TextStyle(
                                    fontSize: 10,
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
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${item.selectedVariation!.variations.length - 2} more',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryBlue.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 8),

                  // Price & Quantity Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '\$${item.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),

                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: onDecrement,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPress: onLongPress,
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 32),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onIncrement,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(8),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
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

  Widget _buildProductImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
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
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 32,
        color: AppColors.lightGray,
      ),
    );
  }
}
