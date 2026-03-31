import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/purchase_returns/model/purchase_return_model.dart';

class PurchaseReturnCard extends StatelessWidget {
  final PurchaseReturnModel returnModel;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PurchaseReturnCard({
    super.key,
    required this.returnModel,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin:
            EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, AppColors.lightBlueBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  CircleAvatar(
                    radius: ResponsiveUI.borderRadius(context, 25),
                    backgroundColor:
                        AppColors.darkBlue,
                    child: Icon(Icons.assignment_return_rounded,
                        color: AppColors.white,
                        size: ResponsiveUI.fontSize(context, 22)),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${returnModel.reference}',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                          ),
                        ),
                        Text(
                          'Purchase: #${returnModel.purchaseReference}',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 12),
                            color: AppColors.shadowGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomPopupMenu(
                      onEdit: onEdit, onDelete: onDelete),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              const CustomGradientDivider(),
              SizedBox(height: ResponsiveUI.spacing(context, 12)),

              // ── Details ──
              Wrap(
                spacing: ResponsiveUI.spacing(context, 8),
                runSpacing: ResponsiveUI.spacing(context, 8),
                children: [
                  _Chip(
                    icon: Icons.attach_money_rounded,
                    label:
                        '${returnModel.totalAmount.toStringAsFixed(2)} EGP',
                    color: AppColors.successGreen,
                  ),
                  _Chip(
                    icon: Icons.inventory_2_outlined,
                    label: '${returnModel.items.length} item(s)',
                    color: AppColors.primaryBlue,
                  ),
                  if (returnModel.supplierName != null)
                    _Chip(
                      icon: Icons.factory_rounded,
                      label: returnModel.supplierName!,
                      color: AppColors.categoryPurple,
                    ),
                  _Chip(
                    icon: Icons.payment_rounded,
                    label: returnModel.refundMethod,
                    color: AppColors.warningOrange,
                  ),
                ],
              ),

              if (returnModel.note.isNotEmpty) ...[
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                Row(
                  children: [
                    Icon(Icons.notes_rounded,
                        size: ResponsiveUI.iconSize(context, 14), color: AppColors.shadowGray),
                    SizedBox(width: ResponsiveUI.spacing(context, 4)),
                    Expanded(
                      child: Text(
                        returnModel.note,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.shadowGray,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 10),
          vertical: ResponsiveUI.padding(context, 5),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: ResponsiveUI.iconSize(context, 13), color: color),
            SizedBox(width: ResponsiveUI.spacing(context, 4)),
            Text(label,
                style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: color,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

