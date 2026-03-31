import 'package:systego/core/utils/responsive_ui.dart';

import 'package:flutter/material.dart';
import '../../../product/models/product_model.dart';
import '../../../../../core/constants/app_colors.dart';

class VariationSelectorDialog extends StatefulWidget {
  final Product product;
  final ValueChanged<Price> onVariationSelected;

  const VariationSelectorDialog({
    required this.product,
    required this.onVariationSelected,
    super.key,
  });

  @override
  State<VariationSelectorDialog> createState() => _VariationSelectorDialogState();
}

class _VariationSelectorDialogState extends State<VariationSelectorDialog> {
  Price? _selectedVariation;

  @override
  Widget build(BuildContext context) {
    // Structure remains the same
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20))),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(child: _buildVariationsList()),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)), topRight: Radius.circular(ResponsiveUI.borderRadius(context, 20))),
      ),
      child: Row(
        children: [
           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name, style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 20), fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Select variation to print', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: Colors.white70)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildVariationsList() {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      itemCount: widget.product.prices.length,
      itemBuilder: (context, index) {
        final variation = widget.product.prices[index];
        final isSelected = _selectedVariation == variation;

        return GestureDetector(
          onTap: () => setState(() => _selectedVariation = variation),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
                ),
                SizedBox(width: ResponsiveUI.value(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(variation.code, style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveUI.fontSize(context, 16))),
                      // If you want to show existing stock:
                      Text('Stock: ${variation.quantity}', style: TextStyle(color: Colors.grey[600], fontSize: ResponsiveUI.fontSize(context, 12))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)), bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 20))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16))),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: ResponsiveUI.value(context, 16)),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedVariation != null
                  ? () {
                      widget.onVariationSelected(_selectedVariation!);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
              ),
              child: const Text('Confirm Selection', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
