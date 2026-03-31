import 'package:systego/core/utils/responsive_ui.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20))),
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
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 20), vertical: ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          topRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.print, color: Colors.white, size: ResponsiveUI.iconSize(context, 24)),
          SizedBox(width: ResponsiveUI.value(context, 12)),
          Expanded(
            child: Text(
              'Select Quantity',
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 20), fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
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
       height: ResponsiveUI.value(context, 200),
       color: Colors.grey[100],
       child: Center(child: Icon(Icons.image, size: ResponsiveUI.iconSize(context, 50), color: Colors.grey)),
    );
  }

  Widget _buildProductInfo(String name, int availableQty, bool isInStock) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 21), fontWeight: FontWeight.bold, color: AppColors.darkBlue),
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Text(
            widget.product.description,
            style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.darkGray.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isInStock) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Labels to Print', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 16), fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: _quantity > 1 ? _decrementQuantity : null,
                    ),
                    Text('$_quantity', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 18), fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _incrementQuantity,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.value(context, 20)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16))),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: ResponsiveUI.value(context, 12)),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(_quantity);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
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
