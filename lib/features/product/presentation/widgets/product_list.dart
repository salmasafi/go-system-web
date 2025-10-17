import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/product/data/models/product_model.dart';
import 'package:systego/features/product/presentation/widgets/product_card.dart';

class ProductsList extends StatelessWidget {
  final List<Product> products;
  const ProductsList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return AnimatedProductCard(product: products[index]);
      },
    );
  }
}
