// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:systego/core/constants/app_colors.dart';
// import 'package:systego/core/utils/error_handler.dart';
// import 'package:systego/core/widgets/app_bar_widgets.dart';
// import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
// import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
// import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
// import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
// import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
// import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
// import 'package:systego/features/admin/print_labels/model/product_model.dart';
// import 'package:systego/features/admin/print_labels/presentation/widgets/product_details_dialog.dart';
// import 'package:systego/features/admin/print_labels/presentation/widgets/product_grid.dart';
// import 'package:systego/features/admin/print_labels/presentation/widgets/variation_selector_dialog.dart';
// import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
// import 'package:systego/features/admin/product/cubit/get_products_cubit/product_state.dart';
// import 'package:systego/features/pos/checkout/presentation/widgets/cart_bottom_sheet.dart';


// class PrintLabelsScreen extends StatefulWidget {
//   const PrintLabelsScreen({super.key});

//   @override
//   State<PrintLabelsScreen> createState() => _PrintLabelsScreenState();
// }

// class _PrintLabelsScreenState extends State<PrintLabelsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _shiftTimer;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _shiftTimer?.cancel();
//     super.dispose();
//   }

//     Future<void> _refresh() async {
//     productsInit();
//   }

//     void productsInit() async {
//     context.read<ProductsCubit>().getProducts();
//   }



//   void _addToCart(Product product) {
//     final checkoutCubit = context.read<CheckoutCubit>();
//     final posCubit = context.read<PosCubit>();

//     if (product.differentPrice && product.prices.isNotEmpty) {
//       showDialog(
//         context: context,
//         builder: (_) => VariationSelectorDialog(
//           product: product,
//           onVariationSelected: (variation) {
//             // checkoutCubit.addToCart(product, variation: variation);
//             posCubit.selectTab(
//               tab: posCubit.selectedTab,
//               noFliterRefresh: true,
//             );
//           },
//         ),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (_) => ProductDetailsDialog(
//           product: product,
//           onAddToCart: () {
//             // checkoutCubit.addToCart(product);
//             posCubit.selectTab(
//               tab: posCubit.selectedTab,
//               noFliterRefresh: true,
//             );
//           },
//         ),
//       );
//     }
//   }


//   List<Product> _filterProducts(List<Product> products) {
//     return products;
//   }

//   void _showCartDialog() {
//     final posCubit = context.read<PosCubit>();
//     final checkoutCubit = context.read<CheckoutCubit>();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => POSCartBottomSheet(
//         onQuantityChanged: (index, delta) {
//           checkoutCubit.updateQuantity(index, delta);
//           posCubit.refreshCartProducts();
//         },
//         onRemove: (index) {
//           checkoutCubit.removeFromCart(index);
//           posCubit.refreshCartProducts();
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PosCubit, PosState>(
//       listener: (context, state) {
//         if (state is PosError) {
//           CustomSnackbar.showError(
//             context,
//             ErrorHandler.handleError(state.message),
//           );
//         }

//       },
//       builder: (context, state) {
//         final cubit = context.read<PosCubit>();
//         final checkoutCubit = context.read<CheckoutCubit>();
//         final cartItems = checkoutCubit.cartItems;

//         return Scaffold(
//           backgroundColor: AppColors.lightBlueBackground,
//             appBar: appBarWithActions(
//         context,
//         title: 'Products',
//       ),
//           // ─── 1. تعديل الـ AppBar ───
         

//           body: 
//           // _buildBody(cubit, state, cartItems),

//           _buildListContent(),

       
//           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         );
//       },
//     );
//   }

//   Widget _buildListContent() {
//     return BlocConsumer<ProductsCubit, ProductsState>(
//       listener: (context, state) {
//         if (state is ProductDeleteSuccess) {
//           CustomSnackbar.showSuccess(context, state.message);
//           productsInit();
//         } else if (state is ProductAddSuccess) {
//           CustomSnackbar.showSuccess(context, state.message);
//           productsInit();
//         }
//       },
//       builder: (context, state) {
//         if (state is ProductsLoading) {
//           return RefreshIndicator(
//             onRefresh: _refresh,
//             color: AppColors.primaryBlue,
//             child: const CustomLoadingShimmer(),
//           );
//         } else if (state is ProductsSuccess) {
//           final products = state.products;
//           // List<Product> displayProducts = _filterProducts(products);

//           if (products.isEmpty) {
//             String title = products.isEmpty
//                 ? 'No Products Found'
//                 : 'No Matching Products';
//             String message = products.isEmpty
//                 ? 'Add your first product to get started'
//                 : 'Try adjusting your search or filters';
//             return Column(
//               children: [
//                 Expanded(
//                   child: CustomEmptyState(
//                     icon: Icons.inventory_2_outlined,
//                     title: title,
//                     message: message,
//                     onRefresh: _refresh,
//                     actionLabel: 'Retry',
//                     onAction: _refresh,
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return RefreshIndicator(
//               onRefresh: _refresh,
//               color: AppColors.primaryBlue,
//               child: Column(
//                 children: [
//                   Expanded(child: ProductGrid(products: products, onProductTap: _addToCart,)),
//                 //   POSProductGrid(
//                 //   products: _filterProducts(state.displayedProducts),
//                 //   onProductTap: _addToCart,
//                 // );
//                 ],
//               ),
//             );
//           }
//         } else if (state is ProductsError) {
//           return CustomEmptyState(
//             icon: Icons.inventory_2_outlined,
//             title: 'Error Occurred',
//             message: state.message,
//             onRefresh: _refresh,
//             actionLabel: 'Retry',
//             onAction: _refresh,
//           );
//         } else {
//           return CustomEmptyState(
//             icon: Icons.inventory_2_outlined,
//             title: 'No Products Found',
//             message: 'Pull to refresh or check your connection',
//             onRefresh: _refresh,
//             actionLabel: 'Retry',
//             onAction: _refresh,
//           );
//         }
//       },
//     );
//   }


//   // Widget _buildBody(ProductsCubit cubit, ProductsState state, List<dynamic> cartItems) {
//   //   if (state is ProductsLoading) {
//   //     return const CustomLoadingState();
//   //   }

//   //   // الحالة 3: الشيفت مفتوح (عرض محتوى الـ POS الطبيعي)
//   //   return Column(
//   //     children: [
//   //       // Product Grid
//   //       Expanded(
//   //         child: Builder(
//   //           builder: (context) {
//   //             if (state is PosProductsLoading) {
//   //               return const CustomLoadingState();
//   //             }

//   //             if (state is PosDataLoaded &&
//   //                 state.displayedProducts.isNotEmpty) {
//   //               return POSProductGrid(
//   //                 products: _filterProducts(state.displayedProducts),
//   //                 onProductTap: _addToCart,
//   //               );
//   //             } else if (cubit.showBrandFilters || cubit.showCategoryFilters) {
//   //               return const SizedBox();
//   //             }

//   //             return const CustomEmptyState(
//   //               icon: Icons.inventory_2_outlined,
//   //               title: 'No Products Found',
//   //               message: 'Try adjusting your search or filters',
//   //             );
//   //           },
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
// }
