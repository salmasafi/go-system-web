import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_gradient_divider.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart';
import '../../../../../core/widgets/custom_image_card.dart';
import '../../../../../core/widgets/custom_popup_menu.dart';
import '../../../warehouses/view/widgets/custom_stat_chip.dart';

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
      end: ResponsiveUI.padding(context, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: ResponsiveUI.padding(context, 1.0),
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
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
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
          
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
          ),
          image: widget.product.image,
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 18)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 19),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              Row(
                children: [
                  Icon(Icons.category, size: ResponsiveUI.iconSize(context, 15), color: AppColors.successGreen),
                  SizedBox(width: ResponsiveUI.spacing(context, 4)),
                  Expanded(
                    child: Text(
                      widget.product.categoryId.isNotEmpty
                          ? widget.product.categoryId.first.name
                          : 'No category',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        color: AppColors.darkGray.withValues(alpha: 0.6),
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
                    size: ResponsiveUI.iconSize(context, 15),
                    color: AppColors.successGreen,
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 4)),
                  Expanded(
                    child: Text(
                      widget.product.brandId.name,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        color: AppColors.darkGray.withValues(alpha: 0.6),
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
  //       Icon(Icons.description, size: ResponsiveUI.iconSize(context, 16), color: AppColors.categoryPurple),
  //       SizedBox(width: ResponsiveUI.spacing(context, 6)),
  //       Expanded(
  //         child: Text(
  //           widget.product.description,
  //           style: TextStyle(
  //             fontSize: ResponsiveUI.fontSize(context, 13),
  //             color: AppColors.darkGray.withValues(alpha: 0.7),
  //           ),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
