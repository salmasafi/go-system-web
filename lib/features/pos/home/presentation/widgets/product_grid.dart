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
import 'product_card.dart';
import 'attribute_selection_dialog.dart';

class POSProductGrid extends StatefulWidget {
  // نستقبل القائمة المفلترة من البحث (اختياري)
  // إذا كانت فارغة أو null، يمكننا استخدام القائمة من الـ state مباشرة
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

    // Note: differentPrice and prices removed in migration 014
    // Products now have attributes for selection, not price variations
    if (product.attributes.isNotEmpty) {
      // Product has attributes → show attribute selection dialog
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
      // Simple product → add directly to cart
      checkoutCubit.addToCart(product);
      posCubit.selectTab(tab: posCubit.selectedTab, noFliterRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();

        // 1. الأولوية للتحميل: إذا كان هناك أي نوع من التحميل، اعرض اللودنج فوراً
        // حتى لو كانت الحالة PosDataLoaded، نتحقق من الـ flags
        if (state is PosProductsLoading ||
            state is PosLoading ||
            cubit.isCategoryProductsLoading ||
            cubit.isBrandProductsLoading) {
          return const CustomLoadingState();
        }

        // 2. عرض البيانات
        if (state is PosDataLoaded) {
          // نستخدم القائمة الممررة من البحث إذا وجدت، وإلا نستخدم القائمة من الـ state
          final productsToShow =
              widget.filteredProducts ?? state.displayedProducts;

          if (productsToShow.isNotEmpty) {
            return BlocBuilder<CheckoutCubit, CheckoutState>(
              builder: (context, _) {
                final cartItems = context.read<CheckoutCubit>().cartItems;
                return AnimatedElement(
                  delay: const Duration(milliseconds: 100),
                  child: GridView.builder(
                    padding: EdgeInsets.only(
                      right: ResponsiveUI.padding(context, 16),
                      left: ResponsiveUI.padding(context, 16),
                      top: ResponsiveUI.padding(context, 16),
                      bottom: ResponsiveUI.padding(
                        context,
                        75,
                      ), // مساحة للـ FAB/Bottom Sheet
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              ResponsiveUI.isMobile(context) ? 2 : 4,
                          childAspectRatio:
                              0.8, // تم تحديد النسبة لتحسين التناسب
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
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
                      );
                    },
                  ),
                );
              },
            );
          } else {
            // قائمة فارغة بعد انتهاء التحميل (سواء من البحث أو الفلتر)
            return const CustomEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Products Found',
              message:
                  'Try adjusting your search or selecting a different category',
            );
          }
        }

        // 3. الحالة الافتراضية
        return const CustomEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No Products Found',
          message: 'Try adjusting your search or filters',
        );
      },
    );
  }
}
