import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
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
                          'amount_with_value'.tr(namedArgs: {'amount': '${'currency_symbol'.tr()}${redeemPoint.amount.toStringAsFixed(2)}'}),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          'points_with_value'.tr(namedArgs: {'points': redeemPoint.points.toString()}),
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
                        tooltip: 'edit'.tr(),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: Icon(
                          Icons.delete_rounded,
                          color: AppColors.red,
                          size: ResponsiveUI.iconSize(context, 20),
                        ),
                        tooltip: 'delete'.tr(),
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
                        'exchange_rate_preview'.tr(namedArgs: {'amount': '${'currency_symbol'.tr()}${(redeemPoint.amount / redeemPoint.points).toStringAsFixed(2)}'}),
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
        title: Text('delete_redeem_points_title'.tr()),
        content: Text('delete_redeem_points_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RedeemPointsCubit>().deleteRedeemPoints(redeemPoint.id);
            },
            child: Text('delete'.tr(), style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
