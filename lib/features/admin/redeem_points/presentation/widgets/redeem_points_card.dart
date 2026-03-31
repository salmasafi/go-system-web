import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import '../../cubit/redeem_points_cubit.dart';
import '../../model/redeem_points_model.dart';
import 'add_redeem_points_dialog.dart';

class RedeemPointsCard extends StatelessWidget {
  final RedeemPointsModel redeemPoint;
  final int index;

  const RedeemPointsCard({
    super.key,
    required this.redeemPoint,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
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
              // Header with actions
              Row(
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                    ),
                    child: Icon(
                      Icons.redeem_rounded,
                      color: const Color(0xFFE65100),
                      size: ResponsiveUI.iconSize(context, 24),
                    ),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 12)),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount: \$${redeemPoint.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          'Points: ${redeemPoint.points}',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            color: AppColors.shadowGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showEditDialog(context),
                        icon: Icon(
                          Icons.edit_rounded,
                          color: AppColors.primaryBlue,
                          size: ResponsiveUI.iconSize(context, 20),
                        ),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Colors.red,
                          size: ResponsiveUI.iconSize(context, 20),
                        ),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
              
              // Exchange rate info
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBackground.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFFE65100),
                      size: ResponsiveUI.iconSize(context, 16),
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 8)),
                    Expanded(
                      child: Text(
                        'Exchange Rate: 1 point = \$${(redeemPoint.amount / redeemPoint.points).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.darkGray,
                        ),
                      ),
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<RedeemPointsCubit>(),
        child: AddRedeemPointsDialog(redeemPoint: redeemPoint),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Redeem Points Configuration'),
        content: Text('Are you sure you want to delete this redeem points configuration?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RedeemPointsCubit>().deleteRedeemPoints(redeemPoint.id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
