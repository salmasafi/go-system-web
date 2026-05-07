// lib/features/pos/checkout/presentation/widgets/cart_item_attribute_display.dart
// Task 16: CartItemAttributeDisplay widget
// Shows selected attributes below the product name in the cart.
// Supports both regular products (selectedAttributes) and bundle products (bundleProductAttributes).

import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';

/// Compact chip-style attribute display.
/// Shows "Color: Red, Size: Large" styled as colored pill badges.
class CartItemAttributeDisplay extends StatelessWidget {
  final CartItem item;
  final bool isArabic;

  const CartItemAttributeDisplay({
    super.key,
    required this.item,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    if (item.hasSelectedAttributes) {
      return _buildAttributeChips(context, item.selectedAttributes);
    }

    if (item.hasBundleAttributes) {
      return _buildBundleAttributes(context);
    }

    return const SizedBox.shrink();
  }

  /// Renders attribute chips for a regular product
  Widget _buildAttributeChips(
      BuildContext context, List<SelectedAttribute> attrs) {
    if (attrs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: ResponsiveUI.padding(context, 4)),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: attrs.map((attr) {
          final label = attr.getDisplayString();
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 7),
              vertical: ResponsiveUI.padding(context, 3),
            ),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
              border: Border.all(
                color: AppColors.successGreen.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune,
                  size: ResponsiveUI.iconSize(context, 10),
                  color: AppColors.successGreen,
                ),
                SizedBox(width: ResponsiveUI.value(context, 3)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 10),
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Renders bundle product attributes (collapsed per-product summary)
  Widget _buildBundleAttributes(BuildContext context) {
    final bundleAttrs = item.bundleProductAttributes!;
    // Collect all attribute strings
    final allStrings = bundleAttrs.values
        .expand((attrs) => attrs.map((a) => a.getDisplayString()))
        .toList();

    if (allStrings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: ResponsiveUI.padding(context, 4)),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: allStrings.map((label) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 7),
              vertical: ResponsiveUI.padding(context, 3),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 10),
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
