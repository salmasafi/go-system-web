import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import '../../../../../../../core/widgets/custom_image_card.dart';
import '../../../warehouses/view/widgets/custom_stat_chip.dart';
import '../../logic/model/get_categories_model.dart';

class AnimatedCategoryCard extends StatefulWidget {
  final CategoryItem category;
  final int? index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedCategoryCard({
    super.key,
    required this.category,
    this.index,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
}

class _AnimatedCategoryCardState extends State<AnimatedCategoryCard>
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
                      // SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      // _buildParentRow(),
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
          image: widget.category.image,
          icon: Icons.category,
          size: ResponsiveUI.iconSize(context, 70),
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            //   SizedBox(height: ResponsiveUI.spacing(context, 6)),
            //   Row(
            //     children: [
            //       Icon(Icons.image, size: 15, color: AppColors.successGreen),
            //       SizedBox(width: ResponsiveUI.spacing(context, 4)),
            //       Expanded(
            //         child: Text(
            //           widget.category.image,
            //           style: TextStyle(
            //             fontSize: 14,
            //             color: AppColors.darkGray.withOpacity(0.6),
            //           ),
            //           maxLines: 1,
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //       ),
            //     ],
            //   ),
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
            icon: Icons.inventory_2_outlined,
            label: '${widget.category.productQuantity} Products',
            color: AppColors.successGreen,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 10)),
        widget.category.parentId != null
            ? Expanded(
                child: CustomStatChip(
                  icon: Icons.folder,
                  label: 'Parent: ${widget.category.parentId!.name}',
                  color: AppColors.linkBlue,
                ),
              )
            : SizedBox(),
      ],
    );
  }

  // Widget _buildParentRow() {
  //   if (widget.category.parentId == null) return const SizedBox.shrink();
  //   return Row(
  //     children: [
  //       Icon(Icons.folder, size: 16, color: AppColors.categoryPurple),
  //       SizedBox(width: ResponsiveUI.spacing(context, 6)),
  //       Expanded(
  //         child: Text(
  //           'Parent: ${widget.category.parentId?.name ?? 'No parent'}',
  //           style: TextStyle(
  //             fontSize: 13,
  //             color: AppColors.darkGray.withOpacity(0.7),
  //           ),
  //           maxLines: 1,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

// class CategoryCardWidget extends StatelessWidget {
//   final CategoryItem category;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const CategoryCardWidget({
//     super.key,
//     required this.category,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
//       padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(
//           ResponsiveUI.borderRadius(context, 12),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.lightBlueBackground,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _buildCategoryImage(context),
//           SizedBox(width: ResponsiveUI.spacing(context, 12)),
//           Expanded(child: _buildCategoryInfo(context)),
//           CustomPopupMenu(
//             onEdit: onEdit,
//             onDelete: onDelete,
//             backgroundColor: AppColors.white,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryImage(BuildContext context) {
//     return Container(
//       width: ResponsiveUI.value(context, 60),
//       height: ResponsiveUI.value(context, 60),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(
//           ResponsiveUI.borderRadius(context, 8),
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(
//           ResponsiveUI.borderRadius(context, 8),
//         ),
//         child: Image.network(
//           category.image,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => Icon(
//             Icons.category,
//             color: AppColors.lightGray,
//             size: ResponsiveUI.iconSize(context, 24),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryInfo(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           category.name,
//           style: TextStyle(
//             fontSize: ResponsiveUI.fontSize(context, 16),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         if (category.parentId != null)
//           Padding(
//             padding: EdgeInsets.only(top: ResponsiveUI.spacing(context, 4)),
//             child: Text(
//               'Parent category: ${category.parentId!.name}',
//               style: TextStyle(
//                 fontSize: ResponsiveUI.fontSize(context, 12),
//                 color: AppColors.darkBlue,
//               ),
//             ),
//           ),
//         Padding(
//           padding: EdgeInsets.only(top: ResponsiveUI.spacing(context, 4)),
//           child: Text(
//             '${category.productQuantity} Products',
//             style: TextStyle(
//               fontSize: ResponsiveUI.fontSize(context, 12),
//               color: AppColors.darkBlue,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
