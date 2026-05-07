import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/custom_gradient_divider.dart';
import '../../model/online_order_model.dart';

class OnlineOrderCard extends StatelessWidget {
  final OnlineOrderModel order;
  final int index;

  const OnlineOrderCard({super.key, required this.order, required this.index});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.successGreen;
      case 'pending':
        return AppColors.warningOrange;
      case 'confirmed':
        return AppColors.primaryBlue;
      case 'processing':
        return const Color(0xFF546E7A);
      case 'out_for_delivery':
        return const Color(0xFF7B1FA2);
      case 'canceled':
      case 'failed_to_deliver':
        return AppColors.red;
      case 'returned':
      case 'refund':
        return AppColors.warningOrange;
      case 'scheduled':
        return const Color(0xFF546E7A);
      default:
        return AppColors.shadowGray;
    }
  }

  Widget _buildOrderItemRow(BuildContext context, OnlineOrderItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.productName} x${item.quantity}',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkGray,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.isWholePriceActive) ...[
            Text(
              '${item.wholePrice!.toStringAsFixed(2)} EGP',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                fontWeight: FontWeight.w700,
                color: AppColors.successGreen,
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 4)),
            Text(
              '${item.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                color: AppColors.linkBlue,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ] else
            Text(
              '${item.price.toStringAsFixed(2)} EGP',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkGray,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return AnimatedElement(
      delay: Duration(milliseconds: 80 * (index % 10)),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 14)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: ResponsiveUI.borderRadius(context, 22),
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: statusColor,
                      size: ResponsiveUI.fontSize(context, 20),
                    ),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.orderNumber}',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 15),
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                          ),
                        ),
                        Text(
                          _formatDate(order.dateTime),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 11),
                            color: AppColors.shadowGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 10),
                      vertical: ResponsiveUI.padding(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 20),
                      ),
                    ),
                    child: Text(
                      order.status.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 11),
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              const CustomGradientDivider(),
              SizedBox(height: ResponsiveUI.spacing(context, 10)),
              Wrap(
                spacing: ResponsiveUI.spacing(context, 8),
                runSpacing: ResponsiveUI.spacing(context, 6),
                children: [
                  _Chip(
                    context: context,
                    icon: Icons.person_outline,
                    label: order.customerName,
                    color: AppColors.primaryBlue,
                  ),
                  _Chip(
                    context: context,
                    icon: Icons.store_outlined,
                    label: order.branch,
                    color: const Color(0xFF546E7A),
                  ),
                  _Chip(
                    context: context,
                    icon: Icons.attach_money_rounded,
                    label: '${order.amount.toStringAsFixed(2)} EGP',
                    color: AppColors.successGreen,
                    bold: true,
                  ),
                  if (order.type.isNotEmpty)
                    _Chip(
                      context: context,
                      icon: Icons.label_outline,
                      label: order.type,
                      color: AppColors.categoryPurple,
                    ),
                ],
              ),
              if (order.items.isNotEmpty) ...[
                SizedBox(height: ResponsiveUI.spacing(context, 10)),
                const CustomGradientDivider(),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                ...order.items.map((item) => _buildOrderItemRow(context, item)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final Color color;
  final bool bold;

  const _Chip({
    required this.context,
    required this.icon,
    required this.label,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 8),
        vertical: ResponsiveUI.padding(context, 4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ResponsiveUI.iconSize(context, 12), color: color),
          SizedBox(width: ResponsiveUI.spacing(context, 4)),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveUI.value(context, 140)),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                color: color,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
