import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/product/presentation/widgets/product_image_card.dart';
import 'package:GoSystem/features/admin/product/presentation/widgets/product_info_grid.dart';
import 'package:GoSystem/features/admin/product/presentation/widgets/product_info_item.dart';
import 'package:GoSystem/features/admin/product/presentation/widgets/product_title.dart';
import 'package:GoSystem/features/admin/product/presentation/widgets/product_attribute_assignment_widget.dart';
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
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(context, title: "تفاصيل المنتج"),
      body: SafeArea(
        child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {

          if (state is ProductDetailsError) {
            return CustomEmptyState(
              icon: Icons.error_outline,
              title: 'خطأ',
              message: state.message,
              onRefresh: _refresh,
              actionLabel: 'إعادة المحاولة',
              onAction: _refresh,
            );
          }

          if (state is ProductDetailsSuccess) {
            final product = state.productDetails.data?.product;
            if (product == null) {
              return CustomEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'لم يتم العثور على المنتج',
                message: 'تفاصيل المنتج غير متاحة',
                actionLabel: 'إعادة المحاولة',
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
                                'صور المعرض',
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 18),
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
                                height: ResponsiveUI.value(context, 100),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: product.galleryProduct.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: ResponsiveUI.padding(context, 1),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                                        child: Image.network(
                                          product.galleryProduct[index],
                                          width: ResponsiveUI.value(context, 100),
                                          height: ResponsiveUI.value(context, 100),
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: ResponsiveUI.value(context, 100),
                                                  height: ResponsiveUI.value(context, 100),
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
                              label: 'كود المنتج',
                              value: product.id,
                            ),
                            ProductInfoItem(
                              label: 'العلامة التجارية',
                              value: product.brandId?.name ?? 'لا توجد علامة تجارية',
                            ),
                            ProductInfoItem(
                              label: 'الفئة',
                              value: product.categoryId.isNotEmpty
                                  ? product.categoryId.first.name
                                  : 'لا توجد فئة',
                            ),
                            ProductInfoItem(label: 'وحدة البيع', value: product.saleUnit.isNotEmpty ? product.saleUnit : '-'),
                            ProductInfoItem(label: 'وحدة الشراء', value: product.purchaseUnit.isNotEmpty ? product.purchaseUnit : '-'),
                            ProductInfoItem(
                              label: 'الكمية',
                              value: '${product.quantity}',
                            ),
                            ProductInfoItem(
                              label: 'السعر',
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
                        //     fontSize: ResponsiveUI.fontSize(context, 18),
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
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowGray.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.lightGray.withValues(alpha: 0.2),
                              width: ResponsiveUI.value(context, 1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header with Icon
                              Row(
                                children: [
                                  Container(
                                    width: ResponsiveUI.value(context, 40),
                                    height: ResponsiveUI.value(context, 40),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.primaryBlue,
                                      size: ResponsiveUI.iconSize(context, 20),
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
                                          'المخزون والجرد',
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(context, 18),
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlue,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveUI.value(context, 4)),
                                        Text(
                                          'تفاصيل إدارة مخزون المنتج',
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(context, 12),
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
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                                  border: Border.all(
                                    color: AppColors.lightGray.withValues(alpha: 0.3),
                                    width: ResponsiveUI.value(context, 1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Low Stock Alert
                                    _buildStockInfoRow(
                                      context: context,
                                      icon: Icons.notifications_active_outlined,
                                      iconColor: AppColors.warningOrange,
                                      label: 'تنبيه المخزون المنخفض',
                                      value: '${product.lowStock} وحدة',
                                      isFirst: true,
                                    ),

                                    Divider(
                                      height: ResponsiveUI.value(context, 1),
                                      color: AppColors.lightGray.withValues(alpha: 
                                        0.3,
                                      ),
                                      indent: 60,
                                    ),

                                    // Minimum Sale Quantity
                                    _buildStockInfoRow(
                                      context: context,
                                      icon: Icons.shopping_cart_outlined,
                                      iconColor: AppColors.successGreen,
                                      label: 'الحد الأدنى لكمية البيع',
                                      value:
                                          '${product.minimumQuantitySale} وحدة',
                                    ),

                                    Divider(
                                      height: ResponsiveUI.value(context, 1),
                                      color: AppColors.lightGray.withValues(alpha: 
                                        0.3,
                                      ),
                                      indent: 60,
                                    ),

                                    // Maximum Quantity to Show
                                    _buildStockInfoRow(
                                      context: context,
                                      icon: Icons.visibility_outlined,
                                      iconColor: AppColors.primaryBlue,
                                      label: 'الحد الأقصى للكمية المعروضة',
                                      value: product.maximumToShow > 0
                                          ? '${product.maximumToShow} وحدة'
                                          : 'بدون حد',
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
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowGray.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.lightGray.withValues(alpha: 0.2),
                              width: ResponsiveUI.value(context, 1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Row(
                                children: [
                                  Container(
                                    width: ResponsiveUI.value(context, 40),
                                    height: ResponsiveUI.value(context, 40),
                                    decoration: BoxDecoration(
                                      color: AppColors.categoryPurple
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                                    ),
                                    child: Icon(
                                      Icons.featured_play_list_outlined,
                                      color: AppColors.categoryPurple,
                                      size: ResponsiveUI.iconSize(context, 20),
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
                                          'مميزات المنتج',
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(context, 18),
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlue,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveUI.value(context, 4)),
                                        Text(
                                          'تبديل المميزات والإمكانيات',
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(context, 12),
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
                                    'قابلية انتهاء الصلاحية',
                                    product.expAbility,
                                    Icons.calendar_today_outlined,
                                    AppColors.warningOrange,
                                  ),
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'له رقم IMEI',
                                    product.productHasImei,
                                    Icons.qr_code_scanner_outlined,
                                    AppColors.primaryBlue,
                                  ),
                                  // Note: differentPrice removed in migration 014
                                  // _buildEnhancedFeatureChip(
                                  //   context,
                                  //   'Different Prices',
                                  //   false,
                                  //   Icons.attach_money_outlined,
                                  //   AppColors.successGreen,
                                  // ),
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'إظهار الكمية',
                                    product.showQuantity,
                                    Icons.visibility_outlined,
                                    AppColors.linkBlue,
                                  ),
                                  _buildEnhancedFeatureChip(
                                    context,
                                    'مميز',
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
                        //     fontSize: ResponsiveUI.fontSize(context, 18),
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

                        // 🎨 Product Attributes Section
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 12),
                            vertical: ResponsiveUI.padding(context, 16),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowGray.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.lightGray.withValues(alpha: 0.2),
                              width: ResponsiveUI.value(context, 1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Row(
                                children: [
                                  Container(
                                    width: ResponsiveUI.value(context, 40),
                                    height: ResponsiveUI.value(context, 40),
                                    decoration: BoxDecoration(
                                      color: AppColors.successGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                                    ),
                                    child: Icon(
                                      Icons.tune_outlined,
                                      color: AppColors.successGreen,
                                      size: ResponsiveUI.iconSize(context, 20),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ResponsiveUI.padding(context, 12),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'خصائص المنتج',
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(context, 18),
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlue,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        SizedBox(height: ResponsiveUI.value(context, 4)),
                                        Text(
                                          'إدارة تنويعات وخصائص المنتج',
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(context, 12),
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
                                height: ResponsiveUI.verticalSpacing(context, 3),
                              ),

                              // Attribute Assignment Widget
                              // Note: differentPrice removed in migration 014
                              ProductAttributeAssignmentWidget(
                                productId: product.id,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveUI.verticalSpacing(context, 3),
                        ),

                        // Note: VARIATIONS SECTION removed in migration 014
                        // Prices and variations no longer exist
                        /*
                        if (product.prices.isNotEmpty &&
                            product.prices.any(
                              (element) => element.variations.isNotEmpty,
                            ))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ... variations display code removed ...
                            ],
                          ),
                        */
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return CustomEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'لم يتم العثور على المنتج',
            message: 'اسحب للتحديث أو تحقق من الاتصال',
            onAction: _refresh,
            onRefresh: _refresh,
            actionLabel: 'إعادة المحاولة',
          );
        },
      ),
    ),
    );

    // Scale down for web
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }

  Widget _buildFeatureChip(String label, bool isActive, IconData icon) {
    return Chip(
      backgroundColor: isActive
          ? AppColors.primaryBlue.withValues(alpha: 0.1)
          : AppColors.lightGray.withValues(alpha: 0.1),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primaryBlue : AppColors.darkGray,
          fontSize: ResponsiveUI.fontSize(context, 12),
        ),
      ),
      avatar: Icon(
        icon,
        size: ResponsiveUI.iconSize(context, 16),
        color: isActive ? AppColors.primaryBlue : AppColors.darkGray,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
        side: BorderSide(
          color: isActive ? AppColors.primaryBlue : AppColors.darkGray,
          width: ResponsiveUI.value(context, 1),
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
          topLeft: isFirst ? Radius.circular(ResponsiveUI.borderRadius(context, 10)) : Radius.zero,
          topRight: isFirst ? Radius.circular(ResponsiveUI.borderRadius(context, 10)) : Radius.zero,
          bottomLeft: isLast ? Radius.circular(ResponsiveUI.borderRadius(context, 10)) : Radius.zero,
          bottomRight: isLast ? Radius.circular(ResponsiveUI.borderRadius(context, 10)) : Radius.zero,
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUI.padding(context, 14),
        horizontal: ResponsiveUI.padding(context, 16),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveUI.value(context, 36),
            height: ResponsiveUI.value(context, 36),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
            ),
            child: Icon(icon, color: iconColor, size: ResponsiveUI.iconSize(context, 18)),
          ),
          SizedBox(width: ResponsiveUI.padding(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGray,
                  ),
                ),
                SizedBox(height: ResponsiveUI.value(context, 2)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 15),
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
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
        color: isActive
            ? activeColor.withValues(alpha: 0.1)
            : AppColors.lightGray.withValues(alpha: 0.3),
        border: Border.all(
          color: isActive
              ? activeColor.withValues(alpha: 0.3)
              : AppColors.lightGray.withValues(alpha: 0.5),
          width: ResponsiveUI.value(context, 1.5),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.15),
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
              size: ResponsiveUI.iconSize(context, 16),
              color: isActive ? activeColor : AppColors.darkGray,
            ),
            SizedBox(width: ResponsiveUI.padding(context, 6)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : AppColors.darkGray,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: ResponsiveUI.padding(context, 4)),
            if (isActive)
              Icon(Icons.check_circle, size: ResponsiveUI.iconSize(context, 14), color: activeColor),
          ],
        ),
      ),
    );
  }
}

