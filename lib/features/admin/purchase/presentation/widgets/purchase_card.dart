import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/purchase/model/purchase_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedPurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedPurchaseCard({
    super.key,
    required this.purchase,
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
              color: AppColors.primaryBlue.withOpacity(0.08),
              blurRadius: ResponsiveUI.borderRadius(context, 10),
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.1),
            width: 1,
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
                  _buildDetailsGrid(context),
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

  Widget _buildHeader(BuildContext context) {
    // Supplier Image or Default Icon
    final String? supplierImage = "";
    //  purchase.supplier?.image;
    final String supplierName = "";
    //  purchase.supplier?.username ?? "Unknown Supplier";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: (supplierImage != null && supplierImage.isNotEmpty)
              ? ClipOval(
                  child: Image.network(
                    supplierImage,
                    fit: BoxFit.cover,
                    width: ResponsiveUI.borderRadius(context, 50),
                    height: ResponsiveUI.borderRadius(context, 50),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.store,
                      color: AppColors.primaryBlue,
                      size: ResponsiveUI.fontSize(context, 24),
                    ),
                  ),
                )
              : Icon(
                  Icons.store,
                  color: AppColors.primaryBlue,
                  size: ResponsiveUI.fontSize(context, 24),
                ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplierName,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                "Ref: ${purchase.reference}",
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onEdit != null || onDelete != null)
          CustomPopupMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warehouse
        Expanded(
          flex: 3,
          child: _buildInfoItem(
            context,
            label: LocaleKeys.warehouse.tr(),
            value: purchase.warehouse.name,
            icon: Icons.warehouse_outlined,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),
        // Date
        Expanded(
          flex: 2,
          child: _buildInfoItem(
            context,
            label: "Date", // LocaleKeys.date.tr()
            value: _formatDate(purchase.date.toString()),
            icon: Icons.calendar_today_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Payment Status Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 12),
            vertical: ResponsiveUI.padding(context, 6),
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(purchase.paymentStatus).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(purchase.paymentStatus).withOpacity(0.3),
            ),
          ),
          child: Text(
            purchase.paymentStatus.toUpperCase(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 11),
              fontWeight: FontWeight.bold,
              color: _getStatusColor(purchase.paymentStatus),
            ),
          ),
        ),
        
        // Grand Total
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Total", // LocaleKeys.total.tr()
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                color: AppColors.darkGray.withOpacity(0.6),
              ),
            ),
            Text(
              "\$${purchase.grandTotal.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray.withOpacity(0.5),
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                color: AppColors.darkGray.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
      case 'pending':
        return Colors.red;
      default:
        return AppColors.primaryBlue;
    }
  }
}