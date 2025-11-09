// lib/features/pos/home/ui/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import '../../../../admin/product/presentation/screens/barcode_scanner_screen.dart';
import '../../cubit/pos_home_cubit.dart';
import '../../cubit/pos_home_state.dart';
import '../../model/pos_models.dart';
import '../widgets/appbar.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../widgets/cart_fab.dart';
import '../widgets/cart_summary.dart';
import '../widgets/filter_by_category_brand_widgets.dart';
import '../widgets/header_section.dart';
import '../widgets/product_grid.dart';
import '../widgets/tab_bar.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<CartItem> _cartItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    posInit();
  }

  void posInit() async {
    await context.read<PosCubit>().loadPosData();
    context.read<PosCubit>().selectTab();
  }

  void _addToCart(Product product) {
    setState(() {
      final existing = _cartItems.indexWhere((i) => i.product.id == product.id);
      if (existing >= 0) {
        _cartItems[existing].quantity++;
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  double get _total =>
      _cartItems.fold(0, (s, i) => s + i.product.price * i.quantity);

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.price.toString().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              POSHeaderSection(
                searchController: _searchController,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                  if (result != null && result != '-1') {
                    setState(() {
                      _searchQuery = result;
                      _searchController.text = result;
                    });
                  }
                },
                onChanged: (String query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
              POSTabBar(),
              POSFilterBar(), // NEW: filter buttons + panels
              Expanded(
                child: state is PosProductsLoading
                    ? const CustomLoadingState()
                    : POSProductGrid(
                        products: state is PosDataLoaded
                            ? _filterProducts(state.displayedProducts)
                            : [],
                        onProductTap: _addToCart,
                      ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _cartItems.isNotEmpty
          ? POSCartSummary(total: _total, cartItems: _cartItems)
          : null,
      floatingActionButton: _cartItems.isNotEmpty
          ? POSCartFAB(
              itemCount: _cartItems.fold(0, (s, i) => s + i.quantity),
              onPressed: () => _showCartDialog(),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showCartDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => POSCartBottomSheet(
        cartItems: _cartItems,
        onQuantityChanged: (index, delta) {
          setState(() {
            final newQty = _cartItems[index].quantity + delta;
            if (newQty > 0) {
              _cartItems[index].quantity = newQty;
            } else {
              _cartItems.removeAt(index);
            }
          });
        },
        onRemove: (index) => setState(() => _cartItems.removeAt(index)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}