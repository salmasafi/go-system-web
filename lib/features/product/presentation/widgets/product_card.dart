import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/product/data/models/product_model.dart';
import 'package:systego/core/widgets/custom_image_card.dart';
import '../../../home/presentation/screens/warehouses/view/widgets/custom_stat_chip.dart';
//import 'package:systego/features/product/presentation/widgets/product_image.dart';
//import 'package:systego/features/product/presentation/widgets/product_info.dart';
//import 'package:systego/features/product/presentation/widgets/product_menu.dart';

// class ProductCard extends StatelessWidget {
//   final Product product;

//   const ProductCard({super.key, required this.product});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
//       padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(
//           ResponsiveUI.borderRadius(context, 12),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ProductImage(imageUrl: product.image),
//           SizedBox(width: ResponsiveUI.spacing(context, 12)),
//           Expanded(child: ProductInfo(product: product)),
//           ProductMenu(),
//         ],
//       ),
//     );
//   }
// }

class AnimatedProductCard extends StatefulWidget {
  final Product product;
  final int? index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedProductCard({
    super.key,
    required this.product,
    this.index,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final delay =
        widget.animationDelay ??
        Duration(milliseconds: (widget.index ?? 0) * 100);

    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.white, AppColors.lightBlueBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      const CustomGradientDivider(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _buildStatsRow(),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      //_buildDescriptionRow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        CustomImageContainer(
          size: ResponsiveUI.iconSize(context, 70),
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
          ),
          image: widget.product.image,
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              Row(
                children: [
                  Icon(Icons.category, size: 15, color: AppColors.successGreen),
                  SizedBox(width: ResponsiveUI.spacing(context, 4)),
                  Expanded(
                    child: Text(
                      widget.product.categoryId.isNotEmpty
                          ? widget.product.categoryId.first.name
                          : 'No category',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGray.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.branding_watermark,
                    size: 15,
                    color: AppColors.successGreen,
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 4)),
                  Expanded(
                    child: Text(
                      widget.product.brandId.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGray.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: CustomStatChip(
            icon: Icons.production_quantity_limits,
            label: '${widget.product.quantity} Units',
            color: AppColors.successGreen,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 10)),
        Expanded(
          child: CustomStatChip(
            icon: Icons.attach_money,
            label: widget.product.price.toStringAsFixed(2),
            color: AppColors.linkBlue,
          ),
        ),
      ],
    );
  }

  // Widget _buildDescriptionRow() {
  //   return Row(
  //     children: [
  //       Icon(Icons.description, size: 16, color: AppColors.categoryPurple),
  //       SizedBox(width: ResponsiveUI.spacing(context, 6)),
  //       Expanded(
  //         child: Text(
  //           widget.product.description,
  //           style: TextStyle(
  //             fontSize: 13,
  //             color: AppColors.darkGray.withOpacity(0.7),
  //           ),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
