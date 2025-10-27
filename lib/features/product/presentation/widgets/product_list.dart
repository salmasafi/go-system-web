import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/product/models/product_model.dart';
import 'package:systego/features/product/presentation/widgets/product_card.dart';
import '../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

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
        return AnimatedProductCard(
          product: products[index],
          onDelete: () => _showDeleteDialog(context, products[index]),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    if (product.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid product ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Product',
        message:
            'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        onDelete: () {
          Navigator.pop(dialogContext);

          // Call delete method from cubit
          context.read<ProductsCubit>().deleteProduct(product.id);
        },
      ),
    );
  }
}
