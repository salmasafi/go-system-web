import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/pos/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import '../../../../../core/constants/app_colors.dart';
import 'product_card.dart';
import 'attribute_selection_dialog.dart';

class POSProductGrid extends StatefulWidget {
  final List<Product>? filteredProducts;

  const POSProductGrid({super.key, this.filteredProducts});

  @override
  State<POSProductGrid> createState() => _POSProductGridState();
}

class _POSProductGridState extends State<POSProductGrid> {
  // ─── Add to Cart Logic ───
  void _addToCart(Product product) {
    final checkoutCubit = context.read<CheckoutCubit>();
    final posCubit = context.read<PosCubit>();

    if (product.attributes.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AttributeSelectionDialog(
          product: product,
          onAttributesSelected: (selectedAttributes) {
            checkoutCubit.addToCart(product, selectedAttributes: selectedAttributes);
            posCubit.selectTab(
              tab: posCubit.selectedTab,
              noFliterRefresh: true,
            );
          },
        ),
      );
    } else {
      checkoutCubit.addToCart(product);
      posCubit.selectTab(tab: posCubit.selectedTab, noFliterRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();

        if (state is PosProductsLoading ||
            state is PosLoading ||
            cubit.isCategoryProductsLoading ||
            cubit.isBrandProductsLoading) {
          return _buildShimmerLoading(context);
        }

        if (state is PosDataLoaded) {
          final productsToShow =
              widget.filteredProducts ?? state.displayedProducts;

          if (productsToShow.isNotEmpty) {
            return BlocBuilder<CheckoutCubit, CheckoutState>(
              builder: (context, _) {
                final cartItems = context.read<CheckoutCubit>().cartItems;
                final hasAnyImage = productsToShow.any(
                  (p) => p.image != null && p.image!.isNotEmpty,
                );
                final isMobile = ResponsiveUI.isMobile(context);
                return AnimatedElement(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    color: AppColors.lightBlueBackground,
                    child: GridView.builder(
                      padding: EdgeInsets.only(
                        right: ResponsiveUI.padding(context, 16),
                        left: ResponsiveUI.padding(context, 16),
                        top: ResponsiveUI.padding(context, 12),
                        bottom: ResponsiveUI.padding(
                          context,
                          isMobile ? 80 : 16,
                        ),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: hasAnyImage
                            ? (isMobile ? 2 : 4)
                            : (isMobile ? 1 : 3),
                        childAspectRatio: hasAnyImage ? 0.78 : 3.8,
                        crossAxisSpacing: hasAnyImage ? 14 : 10,
                        mainAxisSpacing: hasAnyImage ? 14 : 8,
                      ),
                      itemCount: productsToShow.length,
                      itemBuilder: (_, i) {
                        final product = productsToShow[i];
                        final quantityInCart = cartItems
                            .where((item) => item.product.id == product.id)
                            .fold<int>(0, (sum, item) => sum + item.quantity);
                        return POSProductCard(
                          product: product,
                          onTap: () => _addToCart(product),
                          cartQuantity: quantityInCart,
                          compactMode: !hasAnyImage,
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return _buildEmptyState();
          }
        }

        return _buildEmptyState();
      },
    );
  }

  // ─── Shimmer loading placeholder ──────────────────────────────────────────
  Widget _buildShimmerLoading(BuildContext context) {
    final isMobile = ResponsiveUI.isMobile(context);
    return Container(
      color: AppColors.lightBlueBackground,
      child: GridView.builder(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : 4,
          childAspectRatio: 0.78,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: 8,
        itemBuilder: (_, __) => const _ShimmerCard(),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      color: AppColors.lightBlueBackground,
      child: const CustomEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Products Found',
        message:
            'Try adjusting your search or selecting a different category',
      ),
    );
  }
}

// ─── Shimmer placeholder card ────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final opacity = 0.3 + 0.15 * ((value - 0.5).abs() * 2);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 18),
            ),
            border: Border.all(
              color: AppColors.shadowGray.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBackground.withValues(alpha: opacity),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        ResponsiveUI.borderRadius(context, 18),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: ResponsiveUI.value(context, 60),
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: ResponsiveUI.value(context, 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.shadowGray.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 8)),
                    Container(
                      height: ResponsiveUI.value(context, 10),
                      width: ResponsiveUI.value(context, 60),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
