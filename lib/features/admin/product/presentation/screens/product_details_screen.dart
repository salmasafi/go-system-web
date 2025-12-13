import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/product/presentation/widgets/product_image_card.dart';
import 'package:systego/features/admin/product/presentation/widgets/product_info_grid.dart';
import 'package:systego/features/admin/product/presentation/widgets/product_info_item.dart';
import 'package:systego/features/admin/product/presentation/widgets/product_title.dart';
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
      appBar: appBarWithActions(context, title: 'Product Details'),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            );
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
                        // Gallery Images Section
                        if (product.galleryProduct.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gallery Images',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUI.verticalSpacing(
                                  context,
                                  2,
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: product.galleryProduct.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: ResponsiveUI.padding(context, 1),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.galleryProduct[index],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: AppColors.shadowGray,
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: AppColors.white,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUI.verticalSpacing(
                                  context,
                                  3,
                                ),
                              ),
                            ],
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

                        // Text(
                        //   'Stock & Inventory',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //     color: AppColors.black,
                        //   ),
                        // ),
                        // // SectionTitle(title: ),
                        // SizedBox(
                        //   height: ResponsiveUI.verticalSpacing(context, 2),
                        // ),

                        // ProductInfoGrid(
                        //   items: [
                        //     ProductInfoItem(
                        //       label: 'Low Stock Alert',
                        //       value: '${product.lowStock} units',
                        //     ),
                        //     ProductInfoItem(
                        //       label: 'Minimum Sale Quantity',
                        //       value: '${product.minimumQuantitySale} units',
                        //     ),
                        //     ProductInfoItem(
                        //       label: 'Maximum Quantity to Show',
                        //       value: product.maximumToShow > 0
                        //           ? '${product.maximumToShow} units'
                        //           : 'No Limit',
                        //     ),
                        //   ],
                        // ),
                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),

                        // 🏷️ Stock & Inventory Section
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 12),
                            vertical: ResponsiveUI.padding(context, 16),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowGray.withOpacity(0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.lightGray.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header with Icon
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    width: ResponsiveUI.padding(context, 12),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stock & Inventory',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlue,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Product stock management details',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkGray,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: ResponsiveUI.verticalSpacing(
                                  context,
                                  3,
                                ),
                              ),

                              // Stock Info Cards
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlueBackground
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.lightGray.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Low Stock Alert
                                    _buildStockInfoRow(
                                      context: context,
                                      icon: Icons.notifications_active_outlined,
                                      iconColor: AppColors.warningOrange,
                                      label: 'Low Stock Alert',
                                      value: '${product.lowStock} units',
                                      isFirst: true,
                                    ),

                                    Divider(
                                      height: 1,
                                      color: AppColors.lightGray.withOpacity(
                                        0.3,
                                      ),
                                      indent: 60,
                                    ),

                                    // Minimum Sale Quantity
                                    _buildStockInfoRow(
                                      context: context,
                                      icon: Icons.shopping_cart_outlined,
                                      iconColor: AppColors.successGreen,
                                      label: 'Minimum Sale Quantity',
                                      value:
                                          '${product.minimumQuantitySale} units',
                                    ),

                                    Divider(
                                      height: 1,
                                      color: AppColors.lightGray.withOpacity(
                                        0.3,
                                      ),
                                      indent: 60,
                                    ),

                                    // Maximum Quantity to Show
                                    _buildStockInfoRow(
                                      context: context,
                                      icon: Icons.visibility_outlined,
                                      iconColor: AppColors.primaryBlue,
                                      label: 'Maximum Quantity to Show',
                                      value: product.maximumToShow > 0
                                          ? '${product.maximumToShow} units'
                                          : 'No Limit',
                                      isLast: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 4),
                        ),

                        // 🎯 Product Features Section
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 12),
                            vertical: ResponsiveUI.padding(context, 16),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowGray.withOpacity(0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.lightGray.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.categoryPurple
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.featured_play_list_outlined,
                                      color: AppColors.categoryPurple,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    width: ResponsiveUI.padding(context, 12),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Product Features',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlue,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Toggle features and capabilities',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkGray,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: ResponsiveUI.verticalSpacing(
                                  context,
                                  3,
                                ),
                              ),

                              // Feature Chips Grid
                              Wrap(
                                spacing: ResponsiveUI.padding(context, 10),
                                runSpacing: ResponsiveUI.padding(context, 10),
                                children: [
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'Expiration Ability',
                                    product.expAbility,
                                    Icons.calendar_today_outlined,
                                    AppColors.warningOrange,
                                  ),
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'Has IMEI',
                                    product.productHasImei,
                                    Icons.qr_code_scanner_outlined,
                                    AppColors.primaryBlue,
                                  ),
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'Different Prices',
                                    product.differentPrice,
                                    Icons.attach_money_outlined,
                                    AppColors.successGreen,
                                  ),
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'Show Quantity',
                                    product.showQuantity,
                                    Icons.visibility_outlined,
                                    AppColors.linkBlue,
                                  ),
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'Featured',
                                    product.isFeatured,
                                    Icons.star_outlined,
                                    AppColors.holdBeige,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),

                        // 🟢 Product Features & Flags
                        // Text(
                        //   'Product Features',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //     color: AppColors.black,
                        //   ),
                        // ),
                        // // SectionTitle(title: 'Product Features'),
                        // SizedBox(
                        //   height: ResponsiveUI.verticalSpacing(context, 2),
                        // ),

                        // Wrap(
                        //   spacing: ResponsiveUI.padding(context, 8),
                        //   runSpacing: ResponsiveUI.padding(context, 8),
                        //   children: [
                        //     _buildFeatureChip(
                        //       'Expiration Ability',
                        //       product.expAbility,
                        //       Icons.calendar_today,
                        //     ),
                        //     _buildFeatureChip(
                        //       'Has IMEI',
                        //       product.productHasImei,
                        //       Icons.qr_code,
                        //     ),
                        //     _buildFeatureChip(
                        //       'Different Prices',
                        //       product.differentPrice,
                        //       Icons.money,
                        //     ),
                        //     _buildFeatureChip(
                        //       'Show Quantity',
                        //       product.showQuantity,
                        //       Icons.visibility,
                        //     ),
                        //     _buildFeatureChip(
                        //       'Featured',
                        //       product.isFeatured,
                        //       Icons.star,
                        //     ),
                        //   ],
                        // ),
                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),

                        // 🟢 VARIATIONS SECTION - CORRECTED
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
                                    price.variations.isNotEmpty;
                                final hasGallery = price.gallery.isNotEmpty;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ProductInfoGrid(
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
                                      gallery: hasGallery ?
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: ResponsiveUI.verticalSpacing(
                                            context,
                                            1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(
                                            //   'Price Variant Images',
                                            //   style: TextStyle(
                                            //     fontSize: 14,
                                            //     fontWeight: FontWeight.w600,
                                            //     color: AppColors.darkGray,
                                            //   ),
                                            // ),
                                            SizedBox(
                                              height:
                                                  ResponsiveUI.verticalSpacing(
                                                    context,
                                                    1,
                                                  ),
                                            ),
                                            SizedBox(
                                              height:
                                                  80, // Smaller height for variant gallery
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: price.gallery.length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          ResponsiveUI.padding(
                                                            context,
                                                            1,
                                                          ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        price.gallery[index],
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                width: 80,
                                                                height: 80,
                                                                color: AppColors
                                                                    .shadowGray,
                                                                child: Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  size: 30,
                                                                ),
                                                              );
                                                            },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ): null,
                                    ),

                                    // // 🖼️ VARIANT GALLERY SECTION
                                    // if (hasGallery)
                                    //   Padding(
                                    //     padding: EdgeInsets.only(
                                    //       top: ResponsiveUI.verticalSpacing(
                                    //         context,
                                    //         1,
                                    //       ),
                                    //     ),
                                    //     child: Column(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //         // Text(
                                    //         //   'Price Variant Images',
                                    //         //   style: TextStyle(
                                    //         //     fontSize: 14,
                                    //         //     fontWeight: FontWeight.w600,
                                    //         //     color: AppColors.darkGray,
                                    //         //   ),
                                    //         // ),
                                    //         SizedBox(
                                    //           height:
                                    //               ResponsiveUI.verticalSpacing(
                                    //                 context,
                                    //                 1,
                                    //               ),
                                    //         ),
                                    //         SizedBox(
                                    //           height:
                                    //               80, // Smaller height for variant gallery
                                    //           child: ListView.builder(
                                    //             scrollDirection:
                                    //                 Axis.horizontal,
                                    //             itemCount: price.gallery.length,
                                    //             itemBuilder: (context, index) {
                                    //               return Padding(
                                    //                 padding: EdgeInsets.only(
                                    //                   right:
                                    //                       ResponsiveUI.padding(
                                    //                         context,
                                    //                         1,
                                    //                       ),
                                    //                 ),
                                    //                 child: ClipRRect(
                                    //                   borderRadius:
                                    //                       BorderRadius.circular(
                                    //                         8,
                                    //                       ),
                                    //                   child: Image.network(
                                    //                     price.gallery[index],
                                    //                     width: 80,
                                    //                     height: 80,
                                    //                     fit: BoxFit.cover,
                                    //                     errorBuilder:
                                    //                         (
                                    //                           context,
                                    //                           error,
                                    //                           stackTrace,
                                    //                         ) {
                                    //                           return Container(
                                    //                             width: 80,
                                    //                             height: 80,
                                    //                             color: AppColors
                                    //                                 .shadowGray,
                                    //                             child: Icon(
                                    //                               Icons
                                    //                                   .broken_image,
                                    //                               color:
                                    //                                   AppColors
                                    //                                       .white,
                                    //                               size: 30,
                                    //                             ),
                                    //                           );
                                    //                         },
                                    //                   ),
                                    //                 ),
                                    //               );
                                    //             },
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    if (product.prices.indexOf(price) <
                                        product.prices.length - 1)
                                      Divider(
                                        height: ResponsiveUI.verticalSpacing(
                                          context,
                                          3,
                                        ),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ],
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

  Widget _buildFeatureChip(String label, bool isActive, IconData icon) {
    return Chip(
      backgroundColor: isActive
          ? AppColors.primaryBlue.withOpacity(0.1)
          : AppColors.lightGray.withOpacity(0.1),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primaryBlue : AppColors.darkGray,
          fontSize: 12,
        ),
      ),
      avatar: Icon(
        icon,
        size: 16,
        color: isActive ? AppColors.primaryBlue : AppColors.darkGray,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isActive ? AppColors.primaryBlue : AppColors.darkGray,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildStockInfoRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? Radius.circular(10) : Radius.zero,
          topRight: isFirst ? Radius.circular(10) : Radius.zero,
          bottomLeft: isLast ? Radius.circular(10) : Radius.zero,
          bottomRight: isLast ? Radius.circular(10) : Radius.zero,
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUI.padding(context, 14),
        horizontal: ResponsiveUI.padding(context, 16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          SizedBox(width: ResponsiveUI.padding(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGray,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFeatureChip(
    BuildContext context,
    String label,
    bool isActive,
    IconData icon,
    Color activeColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isActive
            ? activeColor.withOpacity(0.1)
            : AppColors.lightGray.withOpacity(0.3),
        border: Border.all(
          color: isActive
              ? activeColor.withOpacity(0.3)
              : AppColors.lightGray.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 14),
          vertical: ResponsiveUI.padding(context, 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeColor : AppColors.darkGray,
            ),
            SizedBox(width: ResponsiveUI.padding(context, 6)),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : AppColors.darkGray,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: ResponsiveUI.padding(context, 4)),
            if (isActive)
              Icon(Icons.check_circle, size: 14, color: activeColor),
          ],
        ),
      ),
    );
  }
}
