import 'package:systego/core/utils/responsive_ui.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/print_labels/presentation/view/label_preview_screen.dart';
import 'package:systego/features/admin/print_labels/presentation/widgets/product_details_dialog.dart';
import 'package:systego/features/admin/print_labels/presentation/widgets/product_grid.dart';
import 'package:systego/features/admin/print_labels/presentation/widgets/variation_selector_dialog.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:systego/features/admin/product/models/product_model.dart';

// lib/features/admin/print_labels/models/label_selection_item.dart

class LabelSelectionItem {
  final Product product;
  final Price? variation; // Null if it's a simple product
  final int quantity;

  LabelSelectionItem({
    required this.product,
    this.variation,
    required this.quantity,
  });
}

class PrintLabelsScreen extends StatefulWidget {
  const PrintLabelsScreen({super.key});

  @override
  State<PrintLabelsScreen> createState() => _PrintLabelsScreenState();
}

class _PrintLabelsScreenState extends State<PrintLabelsScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Local state to hold items selected for printing
  final List<LabelSelectionItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    productsInit();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    productsInit();
  }

  void productsInit() async {
    context.read<ProductsCubit>().getProducts();
  }

  // Logic to add item to the printing list
  void _handleSelection(Product product, {Price? variation, int quantity = 1}) {
    setState(() {
      _selectedItems.add(LabelSelectionItem(
        product: product,
        variation: variation,
        quantity: quantity,
      ));
    });

    CustomSnackbar.showSuccess(
      context, 
      "${product.name} ${variation != null ? '(${variation.code})' : ''} added to print list"
    );
  }

  void _onProductTap(Product product) {
    if (product.differentPrice && product.prices.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => VariationSelectorDialog(
          product: product,
          onVariationSelected: (variation) {
            // Variation dialog doesn't have qty selector, defaulting to 1
            // You could show a second dialog here for quantity if needed
            _handleSelection(product, variation: variation, quantity: 1);
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => ProductDetailsDialog(
          product: product,
          // Now receives quantity from the dialog
          onConfirm: (int quantity) {
            _handleSelection(product, quantity: quantity);
          },
        ),
      );
    }
  }

  void _navigateToPreview() {
    if (_selectedItems.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabelPreviewScreen(selectedItems: _selectedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: 'Select Products for Labels',
      ),
      body: _buildListContent(),
      // Floating Action Button to proceed to print
      floatingActionButton: _selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToPreview,
              backgroundColor: AppColors.primaryBlue,
              icon: Icon(Icons.print, color: Colors.white),
              label: Text(
                'Next (${_selectedItems.length})',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildListContent() {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductDeleteSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          productsInit();
        } else if (state is ProductAddSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          productsInit();
        }
      },
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const CustomLoadingShimmer();
        } else if (state is ProductsSuccess) {
          final products = state.products;

          if (products.isEmpty) {
            return CustomEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Products Found',
              message: 'Add your first product to get started',
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: Column(
                children: [
                  Expanded(
                    child: ProductGrid(
                      products: products, 
                      onProductTap: _onProductTap, // Updated callback
                    ),
                  ),
                ],
              ),
            );
          }
        } else if (state is ProductsError) {
          return CustomEmptyState(
            icon: Icons.error_outline,
            title: 'Error Occurred',
            message: state.message,
            onRefresh: _refresh,
            actionLabel: 'Retry',
            onAction: _refresh,
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
