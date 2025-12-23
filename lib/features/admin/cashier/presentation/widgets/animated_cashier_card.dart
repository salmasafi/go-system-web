import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/cashier/model/cashirer_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedCashierCard extends StatelessWidget {
  final CashierModel cashier;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedCashierCard({
    super.key,
    required this.cashier,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onToggleStatus,
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
            colors: cashier.cashierActive
                ? [AppColors.white, AppColors.lightBlueBackground]
                : [AppColors.white, AppColors.lightGray],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
          boxShadow: [
            BoxShadow(
              color: cashier.cashierActive
                  ? AppColors.primaryBlue.withOpacity(0.1)
                  : AppColors.shadowGray.withOpacity(0.1),
              blurRadius: ResponsiveUI.borderRadius(context, 10),
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: cashier.cashierActive
                ? AppColors.primaryBlue.withOpacity(0.4)
                : AppColors.shadowGray.withOpacity(0.4),
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
                  _buildCashierHeader(context),
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

  Widget _buildCashierHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Status indicator circle
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cashier.cashierActive
                ? AppColors.successGreen
                : AppColors.red,
            boxShadow: [
              BoxShadow(
                color: cashier.cashierActive
                    ? AppColors.successGreen.withOpacity(0.3)
                    : AppColors.red.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),

        // Icon
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: cashier.cashierActive
              ? AppColors.primaryBlue.withOpacity(0.8)
              : AppColors.shadowGray.withOpacity(0.8),
          child: Icon(
            Icons.person_outline,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),

        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        // Cashier names
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cashier.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: cashier.cashierActive
                      ? AppColors.darkGray
                      : AppColors.shadowGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                cashier.arName,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  color: cashier.cashierActive
                      ? AppColors.darkGray.withOpacity(0.7)
                      : AppColors.shadowGray.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        if (onToggleStatus != null)
          _buildStatusToggle(context),

        if (onEdit != null || onDelete != null)
          CustomPopupMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }

  Widget _buildStatusToggle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: ResponsiveUI.spacing(context, 8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cashier.cashierActive
              ? AppColors.successGreen.withOpacity(0.1)
              : AppColors.red.withOpacity(0.1),
        ),
        child: Switch.adaptive(
          value: cashier.cashierActive,
          onChanged: (value) => onToggleStatus?.call(),
          activeColor: AppColors.successGreen,
          inactiveTrackColor: AppColors.shadowGray,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerRow(
          _footerItem(
            context,
            LocaleKeys.warehouse.tr(),
            cashier.warehouse.name,
            icon: Icons.store_outlined,
          ),
          _footerItem(
            context,
            LocaleKeys.status.tr(),
            cashier.status ? LocaleKeys.active.tr() : LocaleKeys.inactive_label.tr(),
            icon: Icons.circle,
            iconColor: cashier.status
                ? AppColors.successGreen
                : AppColors.red,
          ),
          context,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        _footerRow(
          _footerItem(
            context,
            LocaleKeys.users.tr(),
            '${cashier.users.length}',
            icon: Icons.people_outline,
          ),
          _footerItem(
            context,
            LocaleKeys.bank_accounts_title.tr(),
            '${cashier.bankAccounts.length}',
            icon: Icons.account_balance_wallet_outlined,
          ),
          context,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        // _footerRow(
        //   _footerItem(
        //     context,
        //     LocaleKeys.created_at.tr(),
        //     _formatDate(cashier.createdAt),
        //     icon: Icons.calendar_today_outlined,
        //   ),
        //   _footerItem(
        //     context,
        //     LocaleKeys.updated_at.tr(),
        //     _formatDate(cashier.updatedAt),
        //     icon: Icons.update_outlined,
        //   ),
        //   context,
        // ),
      ],
    );
  }

  // String _formatDate(String dateString) {
  //   try {
  //     final date = DateTime.parse(dateString);
  //     return '${date.day}/${date.month}/${date.year}';
  //   } catch (e) {
  //     return dateString.split('T')[0];
  //   }
  // }

  Widget _footerRow(Widget firstItem, Widget secondItem, BuildContext context) {
    return Row(
      children: [
        Expanded(child: firstItem),
        SizedBox(width: ResponsiveUI.spacing(context, 36)),
        Expanded(child: secondItem),
      ],
    );
  }

  Widget _footerItem(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(right: ResponsiveUI.spacing(context, 6)),
                child: Icon(
                  icon,
                  size: ResponsiveUI.fontSize(context, 14),
                  color: iconColor ?? AppColors.darkGray.withOpacity(0.6),
                ),
              ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 2)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: cashier.cashierActive
                ? AppColors.darkGray
                : AppColors.shadowGray,
          ),
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}