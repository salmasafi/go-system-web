import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/product/cubit/get_products_cubit/product_state.dart';
import 'package:systego/features/product/data/models/product_model.dart';
import 'package:systego/features/product/presentation/widgets/filter_by_category_brand_widgets.dart';
import 'package:systego/features/product/presentation/widgets/product_list.dart';
import '../widgets/search_bar_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  TextEditingController controller = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedBrandId;
  bool _showCategoriesFilter = false;
  bool _showBrandsFilter = false;
  bool _showWarhousesFilter = false;
  bool _showVariationsFilter = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().getProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
      controller.clear();
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _showCategoriesFilter = false;
      _showBrandsFilter = false;
    });
    await context.read<ProductsCubit>().getProducts();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      // Search filter
      bool matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          product.price.toString().contains(_searchQuery.toLowerCase()) ||
          product.quantity.toString().contains(_searchQuery.toLowerCase());

      // Category filter
      bool matchesCategory =
          _selectedCategoryId == null ||
          product.categoryId.any((cat) => cat.id == _selectedCategoryId);

      // Brand filter
      bool matchesBrand =
          _selectedBrandId == null || product.brandId.id == _selectedBrandId;

      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();
  }

  Widget _buildListContent(ProductsState state) {
    if (state is ProductsLoading) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: const CustomLoadingShimmer(),
      );
    }

    if (state is ProductsSuccess) {
      final products = state.products;
      List<Product> displayProducts = _filterProducts(products);

      if (displayProducts.isEmpty) {
        String title = products.isEmpty
            ? 'No Products Found'
            : 'No Matching Products';
        String message = products.isEmpty
            ? 'Add your first product to get started'
            : 'Try adjusting your search or filters';
        return CustomEmptyState(
          icon: Icons.inventory_2_outlined,
          title: title,
          message: message,
          onRefresh: _refresh,
          actionLabel: 'Retry',
          onAction: _refresh,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: ProductsList(products: displayProducts),
      );
    }

    if (state is ProductsError) {
      return CustomEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Error Occurred',
        message: state.message,
        onRefresh: _refresh,
        actionLabel: 'Retry',
        onAction: _refresh,
      );
    }

    return CustomEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No Products Found',
      message: 'Pull to refresh or check your connection',
      onRefresh: _refresh,
      actionLabel: 'Retry',
      onAction: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(context, 'Products', () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ProductDetailsScreen()),
        // );
      }, showActions: true),
      body: BlocConsumer<ProductsCubit, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            showErrorSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUI.contentMaxWidth(context),
              ),
              child: Column(
                children: [
                  AnimatedElement(
                    delay: Duration.zero,
                    child: SearchBarWidget(
                      controller: controller,
                      onChanged: (String query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                      text: 'products by name or code',
                    ),
                  ),
                  FilterButtons(
                    showCategories: _showCategoriesFilter,
                    showBrands: _showBrandsFilter,
                    showVariations: _showVariationsFilter,
                    showWarehouses: _showWarhousesFilter,
                    onCategoriesToggle: () {
                      setState(() {
                        // navigatorKey.currentState?.pushAndRemoveUntil(
                        //   MaterialPageRoute(
                        //     builder: (context) => const LoginScreen(),
                        //   ),
                        //   (route) => false,
                        // );
                        _showCategoriesFilter = !_showCategoriesFilter;
                        if (_showCategoriesFilter) _showBrandsFilter = false;
                        if (_showCategoriesFilter) _showWarhousesFilter = false;
                        if (_showCategoriesFilter)_showVariationsFilter = false;
                      });
                    },
                    onBrandsToggle: () {
                      setState(() {
                        _showBrandsFilter = !_showBrandsFilter;
                        if (_showBrandsFilter) _showCategoriesFilter = false;
                        if (_showBrandsFilter) _showWarhousesFilter = false;
                        if (_showBrandsFilter) _showVariationsFilter = false;
                      });
                    },
                    onVariationsToggle: () {
                      setState(() {
                        _showVariationsFilter = !_showVariationsFilter;
                        if (_showVariationsFilter)
                          _showCategoriesFilter = false;
                        if (_showVariationsFilter) _showWarhousesFilter = false;
                        if (_showVariationsFilter) _showBrandsFilter = false;
                      });
                    },
                    onWarehousesToggle: () {
                      setState(() {
                        _showWarhousesFilter = !_showWarhousesFilter;
                        if (_showWarhousesFilter) _showCategoriesFilter = false;
                        if (_showWarhousesFilter) _showBrandsFilter = false;
                        if (_showWarhousesFilter) _showVariationsFilter = false;
                      });
                    },
                  ),

                  if (_showCategoriesFilter && state is ProductsSuccess)
                    AnimatedElement(
                      delay: Duration.zero,
                      child: CategoriesFilterPanel(
                        products: state.products,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          setState(() {
                            _selectedCategoryId = categoryId;
                          });
                        },
                        onClose: () {
                          setState(() {
                            _showCategoriesFilter = false;
                          });
                        },
                      ),
                    ),
                  if (_showBrandsFilter && state is ProductsSuccess)
                    AnimatedElement(
                      delay: Duration.zero,
                      child: BrandsFilterPanel(
                        products: state.products,
                        selectedBrandId: _selectedBrandId,
                        onBrandSelected: (brandId) {
                          setState(() {
                            _selectedBrandId = brandId;
                          });
                        },
                        onClose: () {
                          setState(() {
                            _showBrandsFilter = false;
                          });
                        },
                      ),
                    ),
                  Expanded(
                    child: AnimatedElement(
                      delay: const Duration(milliseconds: 200),
                      child: _buildListContent(state),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
