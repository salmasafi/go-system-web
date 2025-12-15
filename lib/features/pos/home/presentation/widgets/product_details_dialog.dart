// lib/features/POS/home/widgets/product_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../../../core/constants/app_colors.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailsDialog({
    required this.product,
    required this.onAddToCart,
    super.key,
  });

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final variation = widget.product.prices.isNotEmpty 
        ? widget.product.prices.first 
        : null;
    final availableQty = variation?.quantity ?? 0;
    final isInStock = availableQty > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Product Image & Details
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProductImage(),
                    _buildProductInfo(widget.product.code, availableQty, isInStock),
                  ],
                ),
              ),
            ),
            
            // Quantity Selector & Actions
            _buildBottomActions(isInStock),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Product Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: AppColors.lightGray.withOpacity(0.5)),
        ),
      ),
      child: widget.product.image != null
          ? Stack(
              children: [
                Center(
                  child: Image.network(
                    widget.product.image!,
                    fit: BoxFit.contain,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  ),
                ),
                // Gradient overlay for better text visibility
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
            size: 80,
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

  Widget _buildProductInfo(String code, int availableQty, bool isInStock) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          
          // Price Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.darkBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.attach_money,
                  color: AppColors.white,
                  size: 24,
                ),
                const SizedBox(width: 2),
                Text(
                  widget.product.price.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          // Product Code
            _buildInfoRow(
              icon: Icons.qr_code,
              label: 'Product Code',
              value: code,
              valueColor: AppColors.darkGray,
            ),
            const SizedBox(height: 12),
          
          
          // Stock Status
          _buildInfoRow(
            icon: isInStock ? Icons.inventory_2 : Icons.remove_circle_outline,
            label: 'Stock Status',
            value: isInStock ? 'In Stock: $availableQty' : 'Out of Stock',
            valueColor: isInStock ? AppColors.successGreen : AppColors.red,
            iconColor: isInStock ? AppColors.successGreen : AppColors.red,
          ),
          
          // // Variations (if any)
          // if (variation != null && variation.variations.isNotEmpty) ...[
          //   const SizedBox(height: 16),
          //   const Text(
          //     'Specifications',
          //     style: TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.darkGray,
          //     ),
          //   ),
          //   const SizedBox(height: 8),
          //   Wrap(
          //     spacing: 8,
          //     runSpacing: 8,
          //     children: variation.variations.expand((v) {
          //       return v.options.map((opt) {
          //         return Container(
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 12,
          //             vertical: 6,
          //           ),
          //           decoration: BoxDecoration(
          //             color: AppColors.lightBlueBackground,
          //             borderRadius: BorderRadius.circular(8),
          //             border: Border.all(
          //               color: AppColors.primaryBlue.withOpacity(0.3),
          //             ),
          //           ),
          //           child: Text(
          //             '${v.name}: ${opt.name}',
          //             style: const TextStyle(
          //               fontSize: 13,
          //               color: AppColors.darkGray,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         );
          //       });
          //     }).toList(),
          //   ),
          // ],
          
          // Description
          if (widget.product.description.isNotEmpty) ...[
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
              widget.product.description,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkGray.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActions(bool isInStock) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quantity Selector
          if (isInStock) ...[
            Row(
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGray, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1 ? _decrementQuantity : null,
                        color: _quantity > 1 
                            ? AppColors.primaryBlue 
                            : AppColors.lightGray,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 40),
                        child: Text(
                          _quantity.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementQuantity,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.lightGray, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isInStock
                      ? () {
                          // Add to cart with selected quantity
                          for (int i = 0; i < _quantity; i++) {
                            widget.onAddToCart();
                          }
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.lightGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isInStock ? 2 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInStock ? Icons.shopping_cart : Icons.block,
                        size: 20,
                        color: isInStock ? AppColors.white : AppColors.darkGray,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isInStock ? 'Add to Cart' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isInStock ? AppColors.white : AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}