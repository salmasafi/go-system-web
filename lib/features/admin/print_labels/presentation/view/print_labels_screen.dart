import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/print_labels/presentation/view/label_preview_screen.dart';
import 'package:GoSystem/features/admin/print_labels/presentation/widgets/product_details_dialog.dart';
import 'package:GoSystem/features/admin/print_labels/presentation/widgets/product_grid.dart';
// Note: variation_selector_dialog removed - variations no longer exist after migration 014
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart';

// lib/features/admin/print_labels/models/label_selection_item.dart

class LabelSelectionItem {
  final Product product;
  // Note: Variations/prices were removed in migration 014
  // Products now have a single price only
  final int quantity;

  LabelSelectionItem({
    required this.product,
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
  void _handleSelection(Product product, {int quantity = 1}) {
    setState(() {
      _selectedItems.add(LabelSelectionItem(
        product: product,
        quantity: quantity,
      ));
    });

    CustomSnackbar.showSuccess(
      context, 
      "${product.name} added to print list"
    );
  }

  void _onProductTap(Product product) {
    // Note: differentPrice and prices were removed in migration 014
    // All products now have a single price, so we just show the details dialog
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
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.print_labels_title.tr(),
        showBackButton: true,
      ),
      body: SafeArea(
        child: _buildListContent(),
      ),
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
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
