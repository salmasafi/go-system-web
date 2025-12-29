import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/customer/model/customer_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedCustomerCard extends StatefulWidget {
  final CustomerModel customer;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedCustomerCard({
    super.key,
    required this.customer,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedCustomerCard> createState() => _AnimatedCustomerCardState();
}

class _AnimatedCustomerCardState extends State<AnimatedCustomerCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    return AnimatedElement(
      delay: const Duration(milliseconds: 200),
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
                  _buildCustomerItem(customer),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(customer),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerItem(CustomerModel customer) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Customer Avatar
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.lightBlueBackground,
          child: _buildCustomerAvatar(customer),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        
        // Customer Info
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              // SizedBox(height: ResponsiveUI.spacing(context, 4)),
              // Text(
              //   customer.email.isNotEmpty ? customer.email : customer.phoneNumber,
              //   style: TextStyle(
              //     fontSize: ResponsiveUI.fontSize(context, 12),
              //     color: AppColors.darkGray.withOpacity(0.6),
              //   ),
              // ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),

        // Points/Due Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 12),
            vertical: ResponsiveUI.padding(context, 4),
          ),
          decoration: BoxDecoration(
            color: customer.isDue 
              ? AppColors.red.withOpacity(0.1)
              : AppColors.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                customer.isDue ? Icons.money_off : Icons.card_giftcard,
                size: ResponsiveUI.iconSize(context, 14),
                color: customer.isDue ? AppColors.red : AppColors.successGreen,
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 4)),
              Text(
                customer.isDue 
                  ? '\$${customer.amountDue.toStringAsFixed(2)}'
                  : '${customer.totalPointsEarned} ${LocaleKeys.points.tr()}',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: customer.isDue ? AppColors.red : AppColors.successGreen,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(width: ResponsiveUI.spacing(context, 8)),

        // Action menu
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildCustomerAvatar(CustomerModel customer) {
    // You can implement logic to get initials or use a profile image if available
    final initials = customer.name.isNotEmpty 
      ? customer.name.split(' ').map((word) => word[0]).take(2).join().toUpperCase()
      : 'CU';
    
    return Text(
      initials,
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 18),
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildFooter(CustomerModel customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Information
        Row(
          children: [
            _buildInfoItem(
              icon: Icons.phone,
              label: LocaleKeys.phone.tr(),
              value: customer.phoneNumber,
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 16)),
            _buildInfoItem(
              icon: Icons.email,
              label: LocaleKeys.email.tr(),
              value: customer.email.isNotEmpty ? customer.email : LocaleKeys.not_provided.tr(),
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        
        // Location Information
        Row(
          children: [
            _buildInfoItem(
              icon: Icons.location_on,
              label: LocaleKeys.address.tr(),
              value: customer.address.isNotEmpty 
                ? '${customer.address.substring(0, customer.address.length > 30 ? 30 : customer.address.length)}${customer.address.length > 30 ? '...' : ''}'
                : LocaleKeys.not_provided.tr(),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 16)),
            _buildInfoItem(
              icon: Icons.public,
              label: LocaleKeys.location.tr(),
              value: '${customer.city}, ${customer.country}',
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // Status and Member Since
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     // Customer Status
        //     Container(
        //       padding: EdgeInsets.symmetric(
        //         horizontal: ResponsiveUI.padding(context, 12),
        //         vertical: ResponsiveUI.padding(context, 6),
        //       ),
        //       decoration: BoxDecoration(
        //         color: customer.isDue 
        //           ? AppColors.red.withOpacity(0.1)
        //           : AppColors.successGreen.withOpacity(0.1),
        //         borderRadius: BorderRadius.circular(
        //           ResponsiveUI.borderRadius(context, 16),
        //         ),
        //       ),
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Icon(
        //             customer.isDue ? Icons.error_outline : Icons.check_circle,
        //             size: ResponsiveUI.iconSize(context, 14),
        //             color: customer.isDue ? AppColors.red : AppColors.successGreen,
        //           ),
        //           SizedBox(width: ResponsiveUI.spacing(context, 4)),
        //           Text(
        //             customer.isDue 
        //               ? LocaleKeys.due_payment.tr()
        //               : LocaleKeys.good_standing.tr(),
        //             style: TextStyle(
        //               fontSize: ResponsiveUI.fontSize(context, 12),
        //               fontWeight: FontWeight.w500,
        //               color: customer.isDue ? AppColors.red : AppColors.successGreen,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: ResponsiveUI.iconSize(context, 14),
                color: AppColors.darkGray.withOpacity(0.6),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 4)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}