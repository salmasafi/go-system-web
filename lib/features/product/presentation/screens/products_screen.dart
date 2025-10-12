import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/product/presentation/widgets/product_list.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shadowGray[50],
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
            size: ResponsiveUI.iconSize(context, 24),
          ),
          onPressed: () {},
        ),
        title: Text(
          'Products',
          style: TextStyle(
            color: AppColors.black,
            fontSize: ResponsiveUI.fontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: Column(
            children: [
              SearchBar(),
              Expanded(child: ProductsList()),
            ],
          ),
        ),
      ),
    );
  }
}

