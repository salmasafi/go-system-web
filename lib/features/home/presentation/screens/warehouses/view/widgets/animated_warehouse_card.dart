import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_colors.dart';
import '../../../../../../../core/widgets/custom_gradient_divider.dart';
import '../../../../../../../core/widgets/custom_icon_container.dart';
import '../../../../../../../core/widgets/custom_popup_menu.dart';
import 'custom_stat_chip.dart';
import '../../data/model/ware_house_model.dart';

class AnimatedWarehouseCard extends StatefulWidget {
  final Warehouses warehouse;
  final int? index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedWarehouseCard({
    super.key,
    required this.warehouse,
    this.index,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedWarehouseCard> createState() => _AnimatedWarehouseCardState();
}

class _AnimatedWarehouseCardState extends State<AnimatedWarehouseCard>
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final delay = widget.animationDelay ??
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
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.lightBlueBackground,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
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
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(),
                      const SizedBox(height: 16),
                      CustomGradientDivider(),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 12),
                      _buildContactRow(),
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
        CustomIconContainer(
          icon: Icons.warehouse,
          size: 30,
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.warehouse.name ?? 'Warehouse',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 15,
                    color: AppColors.red,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.warehouse.address ?? 'No address',
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
          CustomPopupMenu(
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: CustomStatChip(
            icon: Icons.inventory_2_outlined,
            label: '${widget.warehouse.numberOfProducts ?? 0} Products',
            color: AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomStatChip(
            icon: Icons.storage,
            label: '${widget.warehouse.stockQuantity ?? 0} Stock',
            color: AppColors.linkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow() {
    return Row(
      children: [
        Icon(Icons.phone, size: 16, color: AppColors.categoryPurple),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.warehouse.phone ?? 'No phone',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGray.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.email, size: 16, color: AppColors.warningOrange),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.warehouse.email ?? 'No email',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGray.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
