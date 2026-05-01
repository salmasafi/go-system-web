import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:systego/features/pos/home/model/pos_models.dart';
import '../../../../../core/constants/app_colors.dart';

class VariationSelectorDialog extends StatefulWidget {
  final Product product;
  final ValueChanged<PriceVariation> onVariationSelected;

  const VariationSelectorDialog({
    required this.product,
    required this.onVariationSelected,
    super.key,
  });

  @override
  State<VariationSelectorDialog> createState() =>
      _VariationSelectorDialogState();
}

class _VariationSelectorDialogState extends State<VariationSelectorDialog> {
  PriceVariation? _selectedVariation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20))),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildProductDetails(),
            Divider(height: ResponsiveUI.value(context, 1)),
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
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          topRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          if (widget.product.image != null)
            Container(
              width: ResponsiveUI.value(context, 60),
              height: ResponsiveUI.value(context, 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                color: AppColors.white,
                image: DecorationImage(
                  image: NetworkImage(widget.product.image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (widget.product.image != null) SizedBox(width: ResponsiveUI.value(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUI.value(context, 4)),
                Text(
                  'Select your price item',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    if (widget.product.description.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      color: AppColors.lightBlueBackground,
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: ResponsiveUI.iconSize(context, 20),
            color: AppColors.primaryBlue,
          ),
          SizedBox(width: ResponsiveUI.value(context, 12)),
          Expanded(
            child: Text(
              widget.product.description,
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.darkGray),
            ),
          ),
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
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.05)
                  : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              child: Row(
                children: [
                  Container(
                    width: ResponsiveUI.value(context, 24),
                    height: ResponsiveUI.value(context, 24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
                        width: ResponsiveUI.value(context, 2),
                      ),
                      color: isSelected ? AppColors.primaryBlue : AppColors.white,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: ResponsiveUI.iconSize(context, 16), color: AppColors.white)
                        : null,
                  ),
                  SizedBox(width: ResponsiveUI.value(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variation.code,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.darkBlue : AppColors.darkGray,
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 8)),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 8),
                                vertical: ResponsiveUI.padding(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: variation.quantity > 0
                                    ? AppColors.successGreen.withValues(alpha: 0.1)
                                    : AppColors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    variation.quantity > 0 ? Icons.inventory_2 : Icons.remove_circle_outline,
                                    size: ResponsiveUI.iconSize(context, 14),
                                    color: variation.quantity > 0 ? AppColors.successGreen : AppColors.red,
                                  ),
                                  SizedBox(width: ResponsiveUI.value(context, 4)),
                                  Text(
                                    'Qty: ${variation.quantity}',
                                    style: TextStyle(
                                      fontSize: ResponsiveUI.fontSize(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: variation.quantity > 0 ? AppColors.successGreen : AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (variation.variations.isNotEmpty) ...[
                          SizedBox(height: ResponsiveUI.value(context, 8)),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: variation.variations.expand((v) {
                              return v.options.map((opt) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUI.padding(context, 10),
                                    vertical: ResponsiveUI.padding(context, 5),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBlueBackground,
                                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                                    border: Border.all(color: AppColors.lightGray),
                                  ),
                                  child: Text(
                                    '${v.name}: ${opt.name}',
                                    style: TextStyle(
                                      fontSize: ResponsiveUI.fontSize(context, 12),
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                );
                              });
                            }).toList(),
                          ),
                        ],
                        SizedBox(height: ResponsiveUI.value(context, 10)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 12),
                            vertical: ResponsiveUI.padding(context, 6),
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlue : AppColors.darkBlue,
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
                          ),
                          child: Text(
                            '\${variation.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                side: BorderSide(color: AppColors.lightGray, width: ResponsiveUI.value(context, 2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
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
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: AppColors.lightGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
                elevation: _selectedVariation != null ? 2 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: ResponsiveUI.iconSize(context, 20),
                    color: _selectedVariation != null ? AppColors.white : AppColors.darkGray,
                  ),
                  SizedBox(width: ResponsiveUI.value(context, 8)),
                  Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: _selectedVariation != null ? AppColors.white : AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

