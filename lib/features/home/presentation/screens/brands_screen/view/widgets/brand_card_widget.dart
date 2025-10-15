import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_icon_container.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import '../../../warehouses/view/widgets/custom_stat_chip.dart';
import '../../logic/model/get_brands_model.dart';

class AnimatedBrandCard extends StatefulWidget {
  final Brands brand;
  final int? index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedBrandCard({
    super.key,
    required this.brand,
    this.index,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedBrandCard> createState() => _AnimatedBrandCardState();
}

class _AnimatedBrandCardState extends State<AnimatedBrandCard>
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
            margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.lightBlueBackground,
                ],
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
                      _buildLogoRow(),
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
          icon: Icons.branding_watermark,
          size: 30,
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
                widget.brand.name ?? 'Brand',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 15,
                    color: AppColors.successGreen,
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 4)),
                  Expanded(
                    child: Text(
                      _formatDate(widget.brand.createdAt),
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
            icon: Icons.branding_watermark,
            label: 'Brand ID: ${widget.brand.id}',
            color: AppColors.successGreen,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 10)),
        Expanded(
          child: CustomStatChip(
            icon: Icons.update,
            label: 'Updated: ${_formatDate(widget.brand.updatedAt)}',
            color: AppColors.linkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoRow() {
    return Row(
      children: [
        Icon(Icons.image, size: 16, color: AppColors.categoryPurple),
        SizedBox(width: ResponsiveUI.spacing(context, 6)),
        Expanded(
          child: Text(
            widget.brand.logo ?? 'No logo',
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

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

