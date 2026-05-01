import 'package:flutter/material.dart';
import 'package:GoSystem/features/admin/print_labels/presentation/widgets/product_card.dart';
import '../../../product/models/product_model.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/widgets/animation/animated_element.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const ProductGrid({
    required this.products,
    required this.onProductTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: const Duration(milliseconds: 100),
      child: GridView.builder(
        padding: EdgeInsets.only(
          right: ResponsiveUI.padding(context, 16),
          left: ResponsiveUI.padding(context, 16),
          top: ResponsiveUI.padding(context, 16),
          bottom: ResponsiveUI.padding(context, 75),
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(
          product: products[i],
          onTap: () => onProductTap(products[i]),
        ),
      ),
    );
  }
}
