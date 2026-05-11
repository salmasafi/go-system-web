import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';

class POSProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final int cartQuantity;
  final bool compactMode;

  const POSProductCard({
    required this.product,
    required this.onTap,
    required this.cartQuantity,
    this.compactMode = false,
    super.key,
  });

  @override
  State<POSProductCard> createState() => _POSProductCardState();
}

class _POSProductCardState extends State<POSProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.product.isOutOfStock) {
      _scaleController.reverse();
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    _scaleController.forward();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactMode) {
      return _buildCompactCard(context);
    }
    return _buildImageCard(context);
  }

  // ─── Full card with image ─────────────────────────────────────────────────
  Widget _buildImageCard(BuildContext context) {
    final outOfStock = widget.product.isOutOfStock;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: outOfStock ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleController,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 18),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: _isPressed ? 0.18 : 0.08),
                blurRadius: _isPressed ? 16 : 10,
                spreadRadius: _isPressed ? 1 : 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image section ──
              Expanded(
                child: Stack(
                  children: [
                    // Image with gradient overlay
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueBackground,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            ResponsiveUI.borderRadius(context, 18),
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            ResponsiveUI.borderRadius(context, 18),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: widget.product.image ?? '',
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const CustomLoadingState(),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: ResponsiveUI.iconSize(context, 40),
                                  color: AppColors.shadowGray.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            // Bottom gradient overlay for better text readability
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.08),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Stock badge (top-start)
                    Positioned(
                      top: ResponsiveUI.padding(context, 8),
                      left: ResponsiveUI.padding(context, 8),
                      right: ResponsiveUI.padding(context, 8),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _buildStockBadge(context),
                      ),
                    ),
                    // Cart quantity badge (top-end)
                    if (widget.cartQuantity > 0)
                      Positioned(
                        top: ResponsiveUI.padding(context, 8),
                        left: ResponsiveUI.padding(context, 8),
                        right: ResponsiveUI.padding(context, 8),
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: _buildCartBadge(context),
                        ),
                      ),
                    // Out of stock overlay
                    if (outOfStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                ResponsiveUI.borderRadius(context, 18),
                              ),
                            ),
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 12),
                                vertical: ResponsiveUI.padding(context, 6),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUI.borderRadius(context, 20),
                                ),
                              ),
                              child: Text(
                                LocaleKeys.out_of_stock.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveUI.fontSize(context, 11),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Info section ──
              Container(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUI.padding(context, 12),
                  ResponsiveUI.padding(context, 10),
                  ResponsiveUI.padding(context, 12),
                  ResponsiveUI.padding(context, 12),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(
                      ResponsiveUI.borderRadius(context, 18),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 6)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _buildPrice(context)),
                        SizedBox(width: ResponsiveUI.padding(context, 6)),
                        _addButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Compact card without image ───────────────────────────────────────────
  Widget _buildCompactCard(BuildContext context) {
    final outOfStock = widget.product.isOutOfStock;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: outOfStock ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleController,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: outOfStock
                ? AppColors.greyLight
                : AppColors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: _isPressed ? 0.14 : 0.06),
                blurRadius: _isPressed ? 12 : 8,
                spreadRadius: _isPressed ? 0.5 : 0,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: outOfStock
                  ? AppColors.red.withValues(alpha: 0.2)
                  : _isPressed
                      ? AppColors.primaryBlue.withValues(alpha: 0.3)
                      : AppColors.shadowGray.withValues(alpha: 0.1),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 12),
              vertical: ResponsiveUI.padding(context, 10),
            ),
            child: Row(
              children: [
                // Product icon placeholder
                Container(
                  width: ResponsiveUI.value(context, 42),
                  height: ResponsiveUI.value(context, 42),
                  decoration: BoxDecoration(
                    color: outOfStock
                        ? AppColors.shadowGray.withValues(alpha: 0.08)
                        : AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      outOfStock
                          ? Icons.block_outlined
                          : Icons.inventory_2_rounded,
                      size: ResponsiveUI.iconSize(context, 20),
                      color: outOfStock
                          ? AppColors.red.withValues(alpha: 0.5)
                          : AppColors.primaryBlue.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUI.padding(context, 10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          fontWeight: FontWeight.w600,
                          color: outOfStock
                              ? AppColors.shadowGray
                              : AppColors.darkGray,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.value(context, 3)),
                      _buildPrice(context),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUI.padding(context, 8)),
                // Stock badge inline
                Flexible(
                  fit: FlexFit.loose,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _buildStockBadge(context),
                  ),
                ),
                SizedBox(width: ResponsiveUI.padding(context, 6)),
                // Cart quantity or add button
                if (widget.cartQuantity > 0)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveUI.value(context, 110),
                        ),
                        child: _buildCartQuantityIndicator(context),
                      ),
                    ),
                  )
                else
                  _addButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Add button ───────────────────────────────────────────────────────────
  Widget _addButton(BuildContext context) {
    final outOfStock = widget.product.isOutOfStock;
    if (widget.cartQuantity > 0 && !widget.compactMode) {
      return _buildCartQuantityIndicator(context);
    }
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 7)),
      decoration: BoxDecoration(
        color: outOfStock
            ? AppColors.shadowGray.withValues(alpha: 0.2)
            : AppColors.primaryBlue,
        borderRadius: BorderRadius.all(
          Radius.circular(ResponsiveUI.borderRadius(context, 10)),
        ),
        boxShadow: outOfStock
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Icon(
        outOfStock ? Icons.block_outlined : Icons.add_rounded,
        color: Colors.white,
        size: ResponsiveUI.iconSize(context, 20),
      ),
    );
  }

  // ─── Cart quantity indicator ──────────────────────────────────────────────
  Widget _buildCartQuantityIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 10),
        vertical: ResponsiveUI.padding(context, 5),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.successGreen, AppColors.successGreen.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(ResponsiveUI.borderRadius(context, 10)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: ResponsiveUI.iconSize(context, 14),
          ),
          SizedBox(width: ResponsiveUI.value(context, 4)),
          Text(
            '${widget.cartQuantity}',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUI.fontSize(context, 12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cart badge (for image card) ─────────────────────────────────────────
  Widget _buildCartBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 8),
        vertical: ResponsiveUI.padding(context, 4),
      ),
      decoration: BoxDecoration(
        color: AppColors.successGreen,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: ResponsiveUI.iconSize(context, 12),
          ),
          SizedBox(width: ResponsiveUI.value(context, 3)),
          Text(
            '${widget.cartQuantity}',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUI.fontSize(context, 10),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stock badge ──────────────────────────────────────────────────────────
  Widget _buildStockBadge(BuildContext context) {
    if (widget.product.isOutOfStock && widget.product.showQuantity) {
      return _badge(context, LocaleKeys.out_of_stock_short.tr(), AppColors.red, Icons.error_outline_rounded);
    }
    final qty = widget.product.displayQuantity;
    if (qty == null) return const SizedBox.shrink();
    if (widget.product.isLowStock) {
      return _badge(context, '⚠ $qty', AppColors.warningOrange, Icons.warning_amber_rounded);
    }
    return _badge(context, '$qty', AppColors.primaryBlue, Icons.inventory_2_outlined);
  }

  Widget _badge(BuildContext context, String label, Color color, IconData icon) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUI.value(context, 120),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 8),
          vertical: ResponsiveUI.padding(context, 4),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 8),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: ResponsiveUI.iconSize(context, 10),
            ),
            SizedBox(width: ResponsiveUI.value(context, 3)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUI.fontSize(context, 9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Price display ────────────────────────────────────────────────────────
  Widget _buildPrice(BuildContext context) {
    final hasWholesale =
        widget.product.wholePrice != null &&
        widget.product.startQuantity != null &&
        widget.product.startQuantity! > 0;
    final wholesaleActive =
        hasWholesale && widget.cartQuantity >= widget.product.startQuantity!;
    final baseLabel = '${widget.product.price.toStringAsFixed(2)} ${'currency_symbol'.tr()}';

    if (wholesaleActive) {
      final wholesaleLabel = '${widget.product.wholePrice!.toStringAsFixed(2)} ${'currency_symbol'.tr()}';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 6),
              vertical: ResponsiveUI.padding(context, 2),
            ),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 6),
              ),
            ),
            child: Text(
              wholesaleLabel,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                fontWeight: FontWeight.bold,
                color: AppColors.successGreen,
              ),
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 2)),
          Text(
            baseLabel,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 10),
              color: AppColors.linkBlue,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 6),
        vertical: ResponsiveUI.padding(context, 2),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 6),
        ),
      ),
      child: Text(
        baseLabel,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 12),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
