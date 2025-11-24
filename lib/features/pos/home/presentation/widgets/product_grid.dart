import 'package:flutter/material.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/widgets/animation/animated_element.dart';
import 'product_card.dart';

class POSProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const POSProductGrid({required this.products, required this.onProductTap, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: const Duration(milliseconds: 100),
      child: GridView.builder(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio:  1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => POSProductCard(
          product: products[i],
          onTap: () => onProductTap(products[i]),
        ),
      ),
    );
  }
}
