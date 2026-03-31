import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:systego/features/admin/product/cubit/filter_product_cubit/product_filter_cubit.dart';
import 'package:systego/features/admin/product/cubit/product_filter_state.dart';
import 'package:systego/features/admin/product/models/product_model.dart';
import 'package:systego/features/admin/product/presentation/screens/add_product_screen.dart';
import 'package:systego/features/admin/product/presentation/widgets/filter_by_category_brand_widgets.dart';
import 'package:systego/features/admin/product/presentation/widgets/product_list.dart';
import 'package:systego/features/admin/product/presentation/widgets/search_bar_widget.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../widgets/search_bar_widget.dart';
import 'barcode_scanner_screen.dart';

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
  String? _selectedVariationId;

  // String? _selectedVariationId; // Keep this for the variation category
  String? _selectedVariationOption;

  String? _selectedWarehouseId;

  List<String> _warehouseProductIds = [];

  // Track active filters
  Map<String, Filter> _activeFilters = {};

  void productsInit() async {
    context.read<ProductFiltersCubit>().getFilters();
    context.read<ProductsCubit>().getProducts();
  }

  @override
  void initState() {
    super.initState();
    productsInit();
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
      controller.clear();
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _selectedVariationId = null;
      _selectedWarehouseId = null;
      _warehouseProductIds = [];
    });
    productsInit();
  }

  
  // Add a filter
  void _addFilter(FilterType type, String id, String name) {
    setState(() {
      _activeFilters[type.name] = Filter(
        type: type,
        id: id,
        name: name,
      );
    });
  }

  // Remove a specific filter
  void _removeFilter(FilterType type) {
    setState(() {
      _activeFilters.remove(type.name);
    });
  }

  // Clear all filters
  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });
  }

  // List<Product> _filterProducts(List<Product> products) {
  //   return products.where((product) {
  //     // Search filter
  //     bool matchesSearch =
  //         _searchQuery.isEmpty ||
  //         product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
  //         product.description.toLowerCase().contains(
  //           _searchQuery.toLowerCase(),
  //         ) ||
  //         product.price.toString().contains(_searchQuery.toLowerCase()) ||
  //         product.quantity.toString().contains(_searchQuery.toLowerCase()) ||
  //         product.prices.any(
  //           (price) => price.code.contains(_searchQuery.toLowerCase()),
  //         );

  //     // Category filter
  //     bool matchesCategory =
  //         _selectedCategoryId == null ||
  //         product.categoryId.any((cat) => cat.id == _selectedCategoryId);

  //     // Brand filter
  //     bool matchesBrand =
  //         _selectedBrandId == null || product.brandId.id == _selectedBrandId;

  //     bool matchesWarehouse =
  //         _selectedWarehouseId == null ||
  //         _warehouseProductIds.contains(product.id);

  //     // // Variation filter
  //     // bool matchesVariation =
  //     //     _selectedVariationId == null ||
  //     //     product.prices.any(
  //     //       (price) => price.variations.any(
  //     //         (varn) => varn.name == _selectedVariationId,
  //     //       ),
  //     //     );

  //     bool matchesVariation = true;
  //     if (_selectedVariationOption != null) {
  //       // Check if any price variation has the selected option name
  //       matchesVariation = product.prices.any(
  //         (price) => price.variations.any(
  //           (varn) => varn.options.any(
  //             (option) => option.name == _selectedVariationOption,
  //           ),
  //         ),
  //       );
  //     }

  //     return matchesSearch &&
  //         matchesCategory &&
  //         matchesBrand &&
  //         matchesVariation &&
  //         matchesWarehouse;
  //   }).toList();
  // }

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
          product.quantity.toString().contains(_searchQuery.toLowerCase()) ||
          product.prices.any(
                (price) => price.code.contains(_searchQuery.toLowerCase()),
              );

      // Apply active filters in sequence
      bool matchesAllFilters = true;
      
      for (var filter in _activeFilters.values) {
        switch (filter.type) {
          case FilterType.categories:
            matchesAllFilters = matchesAllFilters &&
                product.categoryId.any((cat) => cat.id == filter.id);
            break;
          case FilterType.brands:
            matchesAllFilters = matchesAllFilters &&
                product.brandId.id == filter.id;
            break;
          case FilterType.variations:
            matchesAllFilters = matchesAllFilters &&
                product.prices.any(
                      (price) => price.variations.any(
                            (varn) => varn.options.any(
                              (option) => option.name == filter.name,
                            ),
                          ),
                    );
            break;
          case FilterType.warehouses:
            // You'll need to update this based on your warehouse filtering logic
            // For now, it returns true if warehouse filter is not set
            matchesAllFilters = matchesAllFilters && true;
            break;
        }
        
        // Early exit if any filter fails
        if (!matchesAllFilters) break;
      }

      return matchesSearch && matchesAllFilters;
    }).toList();
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
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: const CustomLoadingShimmer(),
          );
        } else if (state is ProductsSuccess) {
          final products = state.products;
          List<Product> displayProducts = _filterProducts(products);

          if (displayProducts.isEmpty) {
            String title = products.isEmpty
                ? 'No Products Found'
                : 'No Matching Products';
            String message = products.isEmpty
                ? 'Add your first product to get started'
                : 'Try adjusting your search or filters';
            return Column(
              children: [
                if (_activeFilters.isNotEmpty) _buildActiveFiltersChips(),
                Expanded(
                  child: CustomEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: title,
                    message: message,
                    onRefresh: _refresh,
                    actionLabel: 'Retry',
                    onAction: _refresh,
                  ),
                ),
              ],
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: Column(
                children: [
                  if (_activeFilters.isNotEmpty) _buildActiveFiltersChips(),
                  Expanded(child: ProductsList(products: displayProducts)),
                ],
              ),
            );
          }
        } else if (state is ProductsError) {
          return CustomEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Error Occurred',
            message: state.message,
            onRefresh: _refresh,
            actionLabel: 'Retry',
            onAction: _refresh,
          );
        } else {
          return CustomEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No Products Found',
            message: 'Pull to refresh or check your connection',
            onRefresh: _refresh,
            actionLabel: 'Retry',
            onAction: _refresh,
          );
        }
      },
    );
  }

  
  // Build active filter chips
  Widget _buildActiveFiltersChips() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 8),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Clear all button
          if (_activeFilters.length > 1)
            InputChip(
              label: Text('Clear all'),
              onPressed: _clearAllFilters,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              deleteIcon: Icon(Icons.clear_all, size: ResponsiveUI.iconSize(context, 16)),
              onDeleted: _clearAllFilters,
            ),
          
          // Individual filter chips
          ..._activeFilters.values.map((filter) {
            return InputChip(
              label: Text('${filter.type.name}: ${filter.name}'),
              onPressed: () => _removeFilter(filter.type),
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              deleteIcon: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 16)),
              onDeleted: () => _removeFilter(filter.type),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Add this method to fetch warehouse products
  Future<void> _fetchWarehouseProducts(String warehouseId) async {
    if (warehouseId.isEmpty) {
      setState(() {
        _warehouseProductIds = [];
      });
      return;
    }

    try {
      // Call your warehouse products API
      final response = await DioHelper.getData(
        url: EndPoint.getWareHouseProducts(warehouseId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final productsJson =
              data['data']['productWarehouses'] as List<dynamic>? ?? [];

          // Extract product IDs from warehouse products
          final productIds = productsJson
              .where((json) => json['productId'] != null)
              .map<String>((json) => json['productId']['_id'] as String)
              .toList();

          setState(() {
            _warehouseProductIds = productIds;
          });
        }
      }
    } catch (error) {
      // log('Error fetching warehouse products: $error');
      // You might want to show an error message here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: 'Products',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        showActions: true,
      ),
      body: BlocConsumer<ProductFiltersCubit, ProductFiltersState>(
        listener: (context, state) {
          if (state is ProductFiltersError) {
            CustomSnackbar.showError(context, state.message);
          }
        },

        builder: (context, filtersState) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUI.contentMaxWidth(context),
              ),
              child: Column(
                children: [
                  AnimatedElement(
                    delay: Duration.zero,
                    child: // في ملف products_screen.dart
                        // فقط قم بتحديث الجزء الخاص بـ SearchBarWidget
                        SearchBarWidget(
                          controller: controller,
                          onChanged: (String query) {
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                          text: 'products by name or code',
                          suffixIcon: Icons.qr_code_scanner,
                          suffixOnPressed: () async {
                            // Navigate to Barcode Scanner Screen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BarcodeScannerScreen(),
                              ),
                            );

                            // If barcode was scanned, use it to search
                            if (result != null && result != '-1') {
                              setState(() {
                                _searchQuery = result;
                                controller.text = result;
                              });
                            }
                          },
                        ),
                  ),
                  // FilterButtons(
                  //   onCategorySelected: (id) {
                  //     setState(() {
                  //       _selectedCategoryId = id;
                  //     });
                  //   },
                  //   onBrandSelected: (id) {
                  //     setState(() {
                  //       _selectedBrandId = id;
                  //     });
                  //   },

                  //   // onVariationSelected: (id) {
                  //   //   setState(() {
                  //   //     _selectedVariationId = id;
                  //   //   });
                  //   // },
                  //   onVariationSelected: (variationId, optionName) {
                  //     // Updated to pass both
                  //     setState(() {
                  //       _selectedVariationId = variationId;
                  //       _selectedVariationOption = optionName;
                  //     });
                  //   },

                  //   // onWarehouseSelected: (id) {
                  //   //   setState(() {
                  //   //     _selectedWarehouseId = id;
                  //   //   });
                  //   //   if (id != null) {
                  //   //     context.read<ProductsCubit>().getWareHouseProducts(id);
                  //   //   } else {
                  //   //     context.read<ProductsCubit>().getProducts();
                  //   //   }
                  //   // },
                  //   onWarehouseSelected: (id) async {
                  //     setState(() {
                  //       _selectedWarehouseId = id;
                  //       // Clear warehouse product IDs when warehouse is cleared
                  //       if (id == null) {
                  //         _warehouseProductIds = [];
                  //       }
                  //     });

                  //     // Fetch warehouse products when a warehouse is selected
                  //     if (id != null) {
                  //       await _fetchWarehouseProducts(id);
                  //     }

                  //     // Trigger a rebuild to apply the filter
                  //     setState(() {});
                  //   },
                  // ),
                   FilterButtons(
                    onCategorySelected: (id) {
                      if (id != null) {
                        // Get category name from filters state
                        final category = (filtersState as ProductFiltersSuccess?)
                            ?.filters
                            .data
                            ?.categories
                            ?.firstWhere((cat) => cat.id == id);
                        _addFilter(FilterType.categories, id, category?.name ?? 'Category');
                      } else {
                        _removeFilter(FilterType.categories);
                      }
                    },
                    onBrandSelected: (id) {
                      if (id != null) {
                        final brand = (filtersState as ProductFiltersSuccess?)
                            ?.filters
                            .data
                            ?.brands
                            ?.firstWhere((b) => b.id == id);
                        _addFilter(FilterType.brands, id, brand?.name ?? 'Brand');
                      } else {
                        _removeFilter(FilterType.brands);
                      }
                    },
                    onVariationSelected: (variationId, optionName) {
                      if (optionName != null) {
                        _addFilter(FilterType.variations, variationId ?? '', optionName);
                      } else {
                        _removeFilter(FilterType.variations);
                      }
                    },
                    onWarehouseSelected: (id) async {
                      if (id != null) {
                        final warehouse = (filtersState as ProductFiltersSuccess?)
                            ?.filters
                            .data
                            ?.warehouses
                            ?.firstWhere((w) => w.id == id);
                        _addFilter(FilterType.warehouses, id, warehouse?.name ?? 'Warehouse');
                        await _fetchWarehouseProducts(id);
                      } else {
                        _removeFilter(FilterType.warehouses);
                        setState(() {
                          _warehouseProductIds = [];
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: AnimatedElement(
                      delay: const Duration(milliseconds: 200),
                      child: _buildListContent(),
                    ),
                  ),
                  // Expanded(
                  //   child: AnimatedElement(
                  //     delay: const Duration(milliseconds: 200),
                  //     child: _buildListContent(),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Filter {
  final FilterType type;
  final String id;
  final String name;
  
  Filter({
    required this.type,
    required this.id,
    required this.name,
  });
}
