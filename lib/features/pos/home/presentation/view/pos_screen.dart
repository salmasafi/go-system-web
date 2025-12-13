// lib/features/pos/home/ui/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../../admin/product/presentation/screens/barcode_scanner_screen.dart';
import '../widgets/appbar.dart';
import '../../../checkout/presentation/widgets/cart_bottom_sheet.dart';
import '../../../checkout/presentation/widgets/cart_fab.dart';
import '../../../checkout/presentation/widgets/cart_summary.dart';
import '../widgets/filter_by_category_brand_widgets.dart';
import '../widgets/header_section.dart';
import '../widgets/product_grid.dart';
import '../widgets/tab_bar.dart';
import '../widgets/variation_selector_dialog.dart'; // جديد

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PosCubit>().loadPosData();
  }

  void _addToCart(Product product) {
    if (product.differentPrice && product.prices.isNotEmpty) {
      // إذا variations، افتح الديالوج

      final checkoutCubit = context.read<CheckoutCubit>();
      final PosCubit posCubit = context.read<PosCubit>();

      showDialog(
        context: context,
        builder: (_) => VariationSelectorDialog(
          product: product,
          onVariationSelected: (variation) {
            checkoutCubit.addToCart(product, variation: variation);
            posCubit.selectTab(
              tab: posCubit.selectedTab,
              noFliterRefresh: true,
            );
          },
        ),
      );
    } else {
      // سعر واحد: أضف مباشرة (يمكن إضافة snackbar لعرض تفاصيل سريع)
      context.read<CheckoutCubit>().addToCart(product);
      PosCubit posCubit = context.read<PosCubit>();
      posCubit.selectTab(tab: posCubit.selectedTab, noFliterRefresh: true);
      CustomSnackbar.showSuccess(
        context,
        '${product.name} added (Price: \$${product.price})',
      ); // عرض تفاصيل بسيط
    }
  }

  // ────────────────────────────────────────────────────────────────
  //  Handle barcode scan → API → add to cart
  // ────────────────────────────────────────────────────────────────
  void _handleBarcodeScan(String code) async {
    final posCubit = context.read<PosCubit>();

    // Clear search bar
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });

    final product = await posCubit.getProductByCode(code);
    if (product != null && mounted) {
      _addToCart(product);
    }
  }

  double get _total => context.read<CheckoutCubit>().cartItems.fold(
    0,
    (s, i) => s + i.product.price * i.quantity,
  );

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.price.toString().contains(_searchQuery.toLowerCase()) ||
          product.prices.any(
            (v) => v.code.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      return matchesSearch;
    }).toList();
  }

  void _showCartDialog() {
    final posCubit = context.read<PosCubit>();
    final checkoutCubit = context.read<CheckoutCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => POSCartBottomSheet(
        onQuantityChanged: (index, delta) {
          checkoutCubit.updateQuantity(index, delta);
          posCubit.refreshCartProducts();
        },
        onRemove: (index) {
          checkoutCubit.removeFromCart(index);
          posCubit.refreshCartProducts();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<CheckoutCubit>();
        final cartItems = cubit.cartItems;

        return Scaffold(
          backgroundColor: AppColors.lightBlueBackground,
          appBar: const POSAppBar(),
          body: BlocConsumer<PosCubit, PosState>(
            listener: (context, state) {
              if (state is PosError) {
                ErrorHandler.handleError(state.message);
              }
            },
            builder: (context, state) {
              if (state is PosLoading) {
                return const CustomLoadingState();
              }

              return Column(
                children: [
                  // Search + Header
                  POSHeaderSection(
                    searchController: _searchController,
                    onChanged: (query) => setState(() => _searchQuery = query),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BarcodeScannerScreen(),
                        ),
                      );

                      if (result != null &&
                          result is String &&
                          result != '-1') {
                        _handleBarcodeScan(result);
                      }
                      //_handleBarcodeScan('6225000571365');
                    },
                  ),

                  // Tabs
                  const POSTabBar(),

                  // Filter Panel
                  const POSFilterBar(),

                  // Product Grid
                  Expanded(
                    child: BlocBuilder<PosCubit, PosState>(
                      builder: (context, state) {
                        final cubit = context.read<PosCubit>();
                        if (state is PosProductsLoading) {
                          return const CustomLoadingState();
                        }
                        if (state is PosDataLoaded &&
                            state.displayedProducts.isNotEmpty) {
                          return POSProductGrid(
                            products: _filterProducts(state.displayedProducts),
                            onProductTap: _addToCart,
                          );
                        } else if (cubit.showBrandFilters ||
                            cubit.showCategoryFilters) {
                          return SizedBox();
                        }

                        return CustomEmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Products Found',
                          message: 'Try adjusting your search or filters',
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // Cart Summary (bottom)
          bottomSheet: cartItems.isNotEmpty
              ? POSCartSummary(total: _total)
              : null,

          // FAB
          floatingActionButton: cartItems.isNotEmpty
              ? AnimatedOpacity(
                  opacity: cartItems.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: POSCartFAB(
                    itemCount: cartItems.fold(0, (s, i) => s + i.quantity),
                    onPressed: _showCartDialog,
                  ),
                )
              : null,

          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
