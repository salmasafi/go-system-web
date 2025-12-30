import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/widgets/animation/animated_element.dart';
import '../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../../../checkout/cubit/checkout_cubit/checkout_cubit.dart';
import '../../cubit/pos_home_state.dart';
import 'product_card.dart';
import 'product_details_dialog.dart';
import 'variation_selector_dialog.dart';

class POSProductGrid extends StatefulWidget {
  // final List<Product> products;
  // final ValueChanged<Product> onProductTap;

  const POSProductGrid({
    // required this.products,
    // required this.onProductTap,
    super.key,
  });

  @override
  State<POSProductGrid> createState() => _POSProductGridState();
}

class _POSProductGridState extends State<POSProductGrid> {
  void _addToCart(Product product) {
    // ... (نفس الكود السابق الخاص بك)
    final checkoutCubit = context.read<CheckoutCubit>();
    final posCubit = context.read<PosCubit>();

    if (product.differentPrice && product.prices.isNotEmpty) {
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
      showDialog(
        context: context,
        builder: (_) => ProductDetailsDialog(
          product: product,
          onAddToCart: () {
            checkoutCubit.addToCart(product);
            posCubit.selectTab(
              tab: posCubit.selectedTab,
              noFliterRefresh: true,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();
        if (state is PosProductsLoading || state is PosLoading) {
          return const CustomLoadingState();
        }

        if (state is PosDataLoaded) {
          if (state.displayedProducts.isNotEmpty) {
            return AnimatedElement(
              delay: const Duration(milliseconds: 100),
              child: GridView.builder(
                padding: EdgeInsets.only(
                  right: ResponsiveUI.padding(context, 16),
                  left: ResponsiveUI.padding(context, 16),
                  top: ResponsiveUI.padding(context, 16),
                  bottom: ResponsiveUI.padding(context, 75),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.displayedProducts.length,
                itemBuilder: (_, i) => POSProductCard(
                  product: state.displayedProducts[i],
                  onTap: () => _addToCart(state.displayedProducts[i]),
                ),
              ),
            );
          } else {
            if (cubit.isBrandProductsLoading ||
                cubit.isCategoryProductsLoading) {
              return const CustomLoadingState();
            } else {
              return const SizedBox();
            }
          }
        } else if (cubit.showBrandFilters || cubit.showCategoryFilters) {
          return const SizedBox();
        }

        return const CustomEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No Products Found',
          message: 'Try adjusting your search or filters',
        );
      },
    );
  }
}
