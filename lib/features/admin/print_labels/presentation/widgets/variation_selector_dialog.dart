
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('Select variation to print', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildVariationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.product.prices.length,
      itemBuilder: (context, index) {
        final variation = widget.product.prices[index];
        final isSelected = _selectedVariation == variation;

        return GestureDetector(
          onTap: () => setState(() => _selectedVariation = variation),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(variation.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      // If you want to show existing stock:
                      Text('Stock: ${variation.quantity}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirm Selection', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}