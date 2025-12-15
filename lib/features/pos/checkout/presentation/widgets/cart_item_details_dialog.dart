// lib/features/POS/checkout/presentation/widgets/cart_item_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import '../../model/checkout_models.dart';

class CartItemDetailsDialog extends StatelessWidget {
  final CartItem item;

  const CartItemDetailsDialog({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hasVariation = item.selectedVariation != null;
    final availableQty = item.selectedVariation?.quantity ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(hasVariation),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProductImage(),
                    _buildProductInfo(hasVariation, availableQty),
                  ],
                ),
              ),
            ),
            
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool hasVariation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasVariation ? Icons.dashboard_customize : Icons.inventory_2,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasVariation ? 'Product Price Item Details' : 'Product Details',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: AppColors.lightGray.withOpacity(0.5)),
        ),
      ),
      child: item.product.image != null
          ? Image.network(
              item.product.image!,
              fit: BoxFit.contain,
              height: 180,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 70,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: AppColors.darkGray.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(bool hasVariation, int availableQty) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            item.product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          
          // Cart Quantity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  size: 16,
                  color: AppColors.successGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Quantity in Cart: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Price
          Row(
            children: [
              const Text(
                'Unit Price:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.darkBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Total Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total for this item:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),
          
          if (hasVariation) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            // Variation Details Section
            const Row(
              children: [
                Icon(
                  Icons.dashboard_customize,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8),
                Text(
                  'Price Item Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Product Code
            _buildDetailRow(
              icon: Icons.qr_code,
              label: 'Code',
              value: item.selectedVariation!.code,
            ),
            const SizedBox(height: 10),
            
            // Available Stock
            _buildDetailRow(
              icon: availableQty > 0 
                  ? Icons.inventory_2 
                  : Icons.remove_circle_outline,
              label: 'Available Stock',
              value: availableQty > 0 
                  ? '$availableQty units' 
                  : 'Out of Stock',
              valueColor: availableQty > 0 
                  ? AppColors.successGreen 
                  : AppColors.red,
            ),
            
            // Specifications
            if (item.selectedVariation!.variations.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Specifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.selectedVariation!.variations.expand((v) {
                  return v.options.map((opt) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            v.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            ': ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGray,
                            ),
                          ),
                          Text(
                            opt.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                }).toList(),
              ),
            ],
          ],
          
          // Product Description
          if (item.product.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.product.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkGray,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: AppColors.lightGray.withOpacity(0.3)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 20, color: AppColors.white),
              SizedBox(width: 8),
              Text(
                'Got it',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}