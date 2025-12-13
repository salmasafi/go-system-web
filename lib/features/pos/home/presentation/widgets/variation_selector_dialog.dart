// lib/features/POS/home/widgets/variation_selector_dialog.dart
import 'package:flutter/material.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';

class VariationSelectorDialog extends StatefulWidget {
  final Product product;
  final ValueChanged<PriceVariation> onVariationSelected;

  const VariationSelectorDialog({
    required this.product,
    required this.onVariationSelected,
    super.key,
  });

  @override
  State<VariationSelectorDialog> createState() => _VariationSelectorDialogState();
}

class _VariationSelectorDialogState extends State<VariationSelectorDialog> {
  PriceVariation? _selectedVariation;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Variation for ${widget.product.name}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // عرض تفاصيل المنتج (صورة، وصف، إلخ) هنا إذا أردت توسيع
            Text('Description: ${widget.product.description}'), // افترض إضافة description في Product إذا لزم
            const SizedBox(height: 16),
            const Text('Available Variations:'),
            ...widget.product.prices.map((variation) => ListTile(
                  title: Text('${variation.code} - \$${variation.price.toStringAsFixed(2)}'),
                  subtitle: Text('Quantity: ${variation.quantity}\nVariations: ${variation.variations.map((v) => '${v.name}: ${v.options.map((o) => o.name).join(', ')}').join('\n')}'),
                  trailing: Radio<PriceVariation>(
                    value: variation,
                    groupValue: _selectedVariation,
                    onChanged: (value) => setState(() => _selectedVariation = value),
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedVariation != null
              ? () {
                  widget.onVariationSelected(_selectedVariation!);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}