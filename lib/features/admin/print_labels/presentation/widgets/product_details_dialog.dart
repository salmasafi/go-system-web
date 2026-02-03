
import 'package:flutter/material.dart';
import 'package:systego/features/admin/product/models/product_model.dart';
import '../../../../../core/constants/app_colors.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Product product;
  // Changed callback to include quantity
  final ValueChanged<int> onConfirm;

  const ProductDetailsDialog({
    required this.product,
    required this.onConfirm,
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
    // Basic logic for stock check (simplified based on provided code)
    final variation = widget.product.prices.isNotEmpty 
        ? widget.product.prices.first 
        : null;
    final availableQty = variation?.quantity ?? 0;
    // Assuming if no variations/prices, check generic stock or default to true for example
    final isInStock = availableQty > 0 || widget.product.prices.isEmpty; 

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProductImage(),
                    _buildProductInfo(widget.product.name, availableQty, isInStock),
                  ],
                ),
              ),
            ),
            _buildBottomActions(isInStock),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.print, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Select Quantity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ... _buildProductImage and _buildPlaceholder remain exactly the same as your code ...
  Widget _buildProductImage() {
    // (Keep your existing image code here)
    return Container(
       height: 200,
       color: Colors.grey[100],
       child: Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
    );
  }

  Widget _buildProductInfo(String name, int availableQty, bool isInStock) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: TextStyle(fontSize: 14, color: AppColors.darkGray.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isInStock) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Labels to Print', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1 ? _decrementQuantity : null,
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementQuantity,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(_quantity);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add to List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}