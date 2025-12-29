import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/features/admin/customer_group/model/customer_group.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedCustomerGroupCard extends StatelessWidget {
  final CustomerGroup customerGroup;
  final int? index;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedCustomerGroupCard({
    super.key,
    required this.customerGroup,
    this.index,
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
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Icon(
            Icons.group,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),

        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerGroup.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                _formatDate(customerGroup.createdAt),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        
      ],
    );
  }

  // -------------------- FOOTER --------------------
  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerRow(
          _buildStatusItem(context),
          SizedBox(),
          context,
        ),

        // SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // _buildLastUpdatedItem(context),
      ],
    );
  }

  Widget _buildStatusItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.status.tr(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 2)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 8),
            vertical: ResponsiveUI.padding(context, 4),
          ),
          decoration: BoxDecoration(
            color: customerGroup.status 
                ? AppColors.successGreen.withOpacity(0.1)
                : AppColors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
          ),
          child: Text(
            customerGroup.status ? LocaleKeys.active.tr() : LocaleKeys.inactive.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              fontWeight: FontWeight.w500,
              color: customerGroup.status ? AppColors.successGreen : AppColors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.version.tr(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 2)),
        Text(
          'v${customerGroup.version}',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: AppColors.darkGray,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLastUpdatedItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.last_updated.tr(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 2)),
        Text(
          _formatDateTime(customerGroup.updatedAt),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: AppColors.darkGray,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // -------------------- Helpers --------------------
  Widget _footerRow(Widget firstItem, Widget secondItem, BuildContext context) {
    return Row(
      children: [
        Expanded(child: firstItem),
        SizedBox(width: ResponsiveUI.spacing(context, 36)),
        Expanded(child: secondItem),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
