import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/product/presentation/widgets/product_image_card.dart';
import 'package:systego/features/product/presentation/widgets/product_info_grid.dart';
import 'package:systego/features/product/presentation/widgets/product_info_item.dart';
import 'package:systego/features/product/presentation/widgets/product_title.dart';
import '../../cubit/product_details_cubit/product_details_cubit.dart';
import '../../cubit/product_details_cubit/product_details_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductDetailsCubit>().getProductDetails(widget.productId);
  }

  Future<void> _refresh() async {
    context.read<ProductDetailsCubit>().getProductDetails(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: appBarWithActions(context, 'Product Details', () {}),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return const CustomLoadingShimmer();
          }

          if (state is ProductDetailsError) {
            return CustomEmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              message: state.message,
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          if (state is ProductDetailsSuccess) {
            final product = state.productDetails.data?.product;
            if (product == null) {
              return CustomEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No Product Found',
                message: 'Product details not available',
                actionLabel: 'Retry',
                onAction: _refresh,
                onRefresh: _refresh,
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUI.contentMaxWidth(context),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.horizontalPadding(context),
                      vertical: ResponsiveUI.padding(context, 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImageCard(imageUrl: product.image),
                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),
                        ProductTitle(
                          title: product.name,
                          subtitle: product.description,
                        ),
                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),
                        ProductInfoGrid(
                          items: [
                            ProductInfoItem(
                              label: 'Product Code',
                              value: product.id,
                            ),
                            ProductInfoItem(
                              label: 'Brand',
                              value: product.brandId?.name ?? 'No Brand',
                            ),
                            ProductInfoItem(
                              label: 'Category',
                              value: product.categoryId.isNotEmpty
                                  ? product.categoryId.first.name
                                  : 'No Category',
                            ),
                            ProductInfoItem(label: 'Unit', value: product.unit),
                            ProductInfoItem(
                              label: 'Quantity',
                              value: '${product.quantity}',
                            ),
                            ProductInfoItem(
                              label: 'Price',
                              value: '\$${product.price.toStringAsFixed(2)}',
                            ),
                          ],
                        ),

                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),

                        // 🟢 NEW SECTION — Show variations if available
                        if (product.prices.isNotEmpty &&
                            product.prices.any(
                              (element) => element.variations.isNotEmpty,
                            ))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Variations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUI.verticalSpacing(
                                  context,
                                  1,
                                ),
                              ),
                              ...product.prices.map((price) {
                                final hasVariations =
                                    price.variations != null &&
                                    price.variations.isNotEmpty;

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveUI.verticalSpacing(
                                      context,
                                      1,
                                    ),
                                  ),
                                  child: ProductInfoGrid(
                                    items: [
                                      ProductInfoItem(
                                        label: 'Code',
                                        value: price.code,
                                      ),

                                      ProductInfoItem(
                                        label: 'Price',
                                        value: price.price.toString(),
                                      ),
                                      if (hasVariations)
                                        ...price.variations.map((v) {
                                          return ProductInfoItem(
                                            label: v.name,
                                            value: v.options
                                                .map((o) => o.name)
                                                .join(', '),
                                          );
                                        }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),

                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return CustomEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No Product Found',
            message: 'Pull to refresh or check your connection',
            onAction: _refresh,
            onRefresh: _refresh,
            actionLabel: 'Retry',
          );
        },
      ),
    );
  }
}
