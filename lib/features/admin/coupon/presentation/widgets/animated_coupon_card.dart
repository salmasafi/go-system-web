import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/coupon/model/coupon_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedCouponCard extends StatelessWidget {
  final CouponModel coupon;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedCouponCard({
    super.key,
    required this.coupon,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: animationDelay ?? const Duration(milliseconds: 200),
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
              color: AppColors.primaryBlue.withOpacity(0.1),
              blurRadius: ResponsiveUI.borderRadius(context, 10),
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.4),
            width: 1.8,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCouponHeader(context),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Icon(
            Icons.local_offer,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),

        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        Expanded(
          child: Text(
            coupon.couponCode,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ),

        if (onEdit != null || onDelete != null)
          CustomPopupMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerRow(
          _footerItem(
            context,
            LocaleKeys.coupon_type.tr(),
            coupon.type[0].toUpperCase() +
                coupon.type.substring(1).toLowerCase(),
          ),
          _footerItem(context, LocaleKeys.coupon_amount.tr(), coupon.amount.toString()),
          context,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        _footerRow(
          _footerItem(
            context,
            LocaleKeys.coupon_minimum_amount.tr(),
            coupon.minimumAmount.toString(),
          ),
          _footerItem(context, LocaleKeys.coupon_quantity.tr(), coupon.quantity.toString()),
          context,
        ),

        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        _footerRow(
          _footerItem(context, LocaleKeys.coupon_available.tr(), coupon.available.toString()),
          _footerItem(context, LocaleKeys.coupon_expiry.tr(), coupon.expiredDate.split("T")[0]),
          context,
        ),
      ],
    );
  }

  Widget _footerRow(Widget firstItem, Widget secondItem, BuildContext context) {
    return Row(
      children: [
        Expanded(child: firstItem),
        SizedBox(width: ResponsiveUI.spacing(context, 36)),
        Expanded(child: secondItem),
      ],
    );
  }

  Widget _footerItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: ResponsiveUI.spacing(context, 2)),

        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: AppColors.darkGray,
          ),
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
