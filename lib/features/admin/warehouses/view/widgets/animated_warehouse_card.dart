import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_image_card.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_gradient_divider.dart';
import '../../../../../core/widgets/custom_popup_menu.dart';
import 'custom_stat_chip.dart';
import '../../model/ware_house_model.dart';

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
    final paddingValue = ResponsiveUI.padding(context, 18);
    final borderRadiusValue = ResponsiveUI.borderRadius(context, 20);
    final marginBottom = ResponsiveUI.padding(context, 16);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: EdgeInsets.only(bottom: marginBottom),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.white, AppColors.lightBlueBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadiusValue),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  blurRadius: ResponsiveUI.value(context, 15),
                  offset: Offset(0, ResponsiveUI.value(context, 5)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(borderRadiusValue),
                child: Padding(
                  padding: EdgeInsets.all(paddingValue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      CustomGradientDivider(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _buildStatsRow(),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
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
    final iconSize = ResponsiveUI.iconSize(context, 70);
    final fontSizeName = ResponsiveUI.fontSize(context, 19);
    final fontSizeAddress = ResponsiveUI.fontSize(context, 14);
    //final spacing12 = ResponsiveUI.spacing(context, 12);
    final spacing6 = ResponsiveUI.spacing(context, 6);
    final spacing4 = ResponsiveUI.spacing(context, 4);
    final spacing14 = ResponsiveUI.spacing(context, 14);
    final iconSizeLocation = ResponsiveUI.iconSize(context, 15);

    return Row(
      children: [
        CustomImageContainer(
          icon: Icons.warehouse,
          size: iconSize,
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
          ),
          image: null,
        ),
        SizedBox(width: spacing14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.warehouse.name ?? LocaleKeys.warehouse_default_name.tr(),
                style: TextStyle(
                  fontSize: fontSizeName,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: spacing6),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: iconSizeLocation,
                    color: AppColors.red,
                  ),
                  SizedBox(width: spacing4),
                  Expanded(
                    child: Text(
                      widget.warehouse.address ?? LocaleKeys.warehouse_no_address.tr(),
                      style: TextStyle(
                        fontSize: fontSizeAddress,
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
    final spacing10 = ResponsiveUI.spacing(context, 10);

    return Row(
      children: [
        Expanded(
          child: CustomStatChip(
            icon: Icons.inventory_2_outlined,
            label: '${widget.warehouse.numberOfProducts ?? 0} ${LocaleKeys.warehouse_products.tr()}',
            color: AppColors.successGreen,
          ),
        ),
        SizedBox(width: spacing10),
        Expanded(
          child: CustomStatChip(
            icon: Icons.storage,
            label: '${widget.warehouse.stockQuantity ?? 0} ${LocaleKeys.warehouse_stock.tr()}',
            color: AppColors.linkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow() {
    final iconSize16 = ResponsiveUI.iconSize(context, 16);
    final fontSize13 = ResponsiveUI.fontSize(context, 13);
    final spacing6 = ResponsiveUI.spacing(context, 6);
    final spacing12 = ResponsiveUI.spacing(context, 12);

    return Row(
      children: [
        Icon(Icons.phone, size: iconSize16, color: AppColors.categoryPurple),
        SizedBox(width: spacing6),
        Expanded(
          child: Text(
            widget.warehouse.phone ?? LocaleKeys.warehouse_no_phone.tr(),
            style: TextStyle(
              fontSize: fontSize13,
              color: AppColors.darkGray.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: spacing12),
        Icon(Icons.email, size: iconSize16, color: AppColors.warningOrange),
        SizedBox(width: spacing6),
        Expanded(
          child: Text(
            widget.warehouse.email ?? LocaleKeys.warehouse_no_email.tr(),
            style: TextStyle(
              fontSize: fontSize13,
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
