import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/product/presentation/widgets/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return ProductCard(
          brand: 'Apple',
          title: 'iPhone 12 64GB Blue (Singapore...',
          category: 'Smart Phone',
          code: '66038330',
          quantity: '154',
          price: '\$750.00',
          unit: 'Piece',
          imageUrl:
              'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=200',
        );
      },
    );
  }
}
