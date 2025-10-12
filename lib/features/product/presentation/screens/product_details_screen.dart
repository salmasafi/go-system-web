import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/product/presentation/widgets/product_image_card.dart';
import 'package:systego/features/product/presentation/widgets/product_info_grid.dart';
import 'package:systego/features/product/presentation/widgets/product_info_item.dart';
import 'package:systego/features/product/presentation/widgets/product_title.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Product Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveUI.fontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: ResponsiveUI.iconSize(context, 24),
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
              size: ResponsiveUI.iconSize(context, 24),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.horizontalPadding(context),
                vertical: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProductImageCard(
                    imageUrl:
                        'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400',
                  ),
                  SizedBox(height: ResponsiveUI.verticalSpacing(context, 3)),
                  const ProductTitle(
                    title: 'iPhone 12 64GB Blue (Singapore Unofficial)',
                    subtitle: 'Super Retina XDR Display with OLED',
                  ),
                  SizedBox(height: ResponsiveUI.verticalSpacing(context, 3)),
                  const ProductInfoGrid(
                    items: [
                      ProductInfoItem(label: 'Product Type', value: 'Standard'),
                      ProductInfoItem(label: 'Product Code', value: '12345678'),
                      ProductInfoItem(label: 'Brand', value: 'Apple'),
                      ProductInfoItem(label: 'Category', value: 'Smart Phone'),
                      ProductInfoItem(label: 'Unit', value: 'Piece'),
                      ProductInfoItem(label: 'Quantity', value: '154'),
                      ProductInfoItem(label: 'Alert Quantity', value: '10'),
                      ProductInfoItem(
                        label: 'Purchase Cost',
                        value: '\$700.00',
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.verticalSpacing(context, 3)),
                  //const PriceCard(price: '\$750.00'),
                  //SizedBox(height: ResponsiveUI.verticalSpacing(context, 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class PriceCard extends StatelessWidget {
//   final String price;

//   const PriceCard({super.key, required this.price});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.linkBlue[600]!, Colors.blue[400]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(
//           ResponsiveUI.borderRadius(context, 12),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.3),
//             blurRadius: ResponsiveUI.padding(context, 12),
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Selling Price',
//             style: TextStyle(
//               fontSize: ResponsiveUI.fontSize(context, 13),
//               color: Colors.white70,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: ResponsiveUI.spacing(context, 8)),
//           Text(
//             price,
//             style: TextStyle(
//               fontSize: ResponsiveUI.fontSize(context, 32),
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
