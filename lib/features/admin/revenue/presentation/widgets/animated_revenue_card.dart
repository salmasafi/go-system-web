import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/revenue/model/revenue_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedRevenueCard extends StatelessWidget {
  final RevenueModel revenue;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedRevenueCard({
    super.key,
    required this.revenue,
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
            colors: [
              AppColors.white,
              AppColors.lightBlueBackground
            ],
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
          // border: Border.all(
          //   color: AppColors.successGreen.withOpacity(0.3),
          //   width: 1.8,
          // ),
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
                  _buildHeader(context),
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

  // -------------------- HEADER --------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue,
          child: Icon(
                  Icons.attach_money,
                  color: AppColors.white,
                  size: ResponsiveUI.fontSize(context, 24),
                )
        ),

        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                revenue.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                (revenue.note?.isNotEmpty ?? false) 
      ? revenue.note! 
      : LocaleKeys.no_note.tr(),
                // revenue.note.isNotEmpty ? revenue.note : LocaleKeys.no_note.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        if (onEdit != null || onDelete != null)
          CustomPopupMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }

  // -------------------- FOOTER --------------------
  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerRow(
          _footerItem(
            context,
            LocaleKeys.category.tr(),
            revenue.category?.name ?? '',
          ),
          _footerItem(
            context,
            LocaleKeys.amount.tr(),
            '${revenue.amount}',
          ),
          context,
        ),

        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        _footerRow(
          _footerItem(
            context,
            LocaleKeys.financial_account.tr(),
            revenue.financialAccount?.name ?? '',
          ),
          _footerItem(
            context,
            LocaleKeys.created_by.tr(),
            // revenue.admin.username,
            revenue.admin?.username ?? 'Unknown Admin'
          ),
          context,
        ),

     
      ],
    );
  }

  // -------------------- Helpers --------------------
  Widget _footerRow(Widget firstItem, Widget secondItem, BuildContext context) {
    return Row(
      children: [
        Expanded(child: firstItem),
        SizedBox(width: ResponsiveUI.spacing(context, 24)),
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
            fontSize: ResponsiveUI.fontSize(context, 11),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            fontWeight: FontWeight.w500,
            color: AppColors.darkGray,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}