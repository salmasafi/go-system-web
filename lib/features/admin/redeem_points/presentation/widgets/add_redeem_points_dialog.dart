import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../cubit/redeem_points_cubit.dart';
import '../../model/redeem_points_model.dart';

class AddRedeemPointsDialog extends StatefulWidget {
  final RedeemPointsModel? redeemPoint;

  const AddRedeemPointsDialog({
    super.key,
    this.redeemPoint,
  });

  @override
  State<AddRedeemPointsDialog> createState() => _AddRedeemPointsDialogState();
}

class _AddRedeemPointsDialogState extends State<AddRedeemPointsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _pointsController = TextEditingController();
  
  bool get isEditing => widget.redeemPoint != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _amountController.text = widget.redeemPoint!.amount.toString();
      _pointsController.text = widget.redeemPoint!.points.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUI.contentMaxWidth(context) * 0.5,
        ),
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppColors.shadowGray),
                  ),
                  if (isEditing)
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(context),
                      icon: Icon(Icons.delete_rounded, color: AppColors.shadowGray),
                    ),
                ],
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 16)),
              
              // Title
              Text(
                isEditing ? 'edit_redeem_points'.tr() : 'add_new_redeem_points'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 8)),
              Text(
                'exchange_rate_config_msg'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  color: AppColors.shadowGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // Amount Field
              Text(
                '${'amount'.tr()} (${'currency_symbol'.tr()})',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 8)),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'enter_amount'.tr(),
                  prefixText: '${'currency_symbol'.tr()} ',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.lightGray.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.lightGray.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    borderSide: BorderSide(
                      color: const Color(0xFFE65100),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_amount'.tr();
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'please_enter_valid_amount'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 20)),

              // Points Field
              Text(
                'points'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 8)),
              TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'enter_points'.tr(),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.lightGray.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.lightGray.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    borderSide: BorderSide(
                      color: const Color(0xFFE65100),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_points'.tr();
                  }
                  final points = int.tryParse(value);
                  if (points == null || points <= 0) {
                    return 'please_enter_valid_points'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // Exchange Rate Preview
              if (_amountController.text.isNotEmpty && _pointsController.text.isNotEmpty)
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
                          'exchange_rate_preview'.tr(namedArgs: {'amount': '${'currency_symbol'.tr()}${_calculateExchangeRate()}'}),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 12),
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // Submit Button
              BlocConsumer<RedeemPointsCubit, RedeemPointsState>(
                listener: (context, state) {
                  if (state is CreateRedeemPointsSuccess ||
                      state is UpdateRedeemPointsSuccess) {
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CreateRedeemPointsLoading ||
                      state is UpdateRedeemPointsLoading;

                  return CustomElevatedButton(
                    text: isEditing ? 'update'.tr() : 'create'.tr(),
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateExchangeRate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final points = int.tryParse(_pointsController.text) ?? 0;
    if (amount <= 0 || points <= 0) return '0.00';
    return (amount / points).toStringAsFixed(2);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final points = int.parse(_pointsController.text);

      if (isEditing) {
        context.read<RedeemPointsCubit>().updateRedeemPoints(
          id: widget.redeemPoint!.id,
          amount: amount,
          points: points,
        );
      } else {
        context.read<RedeemPointsCubit>().createRedeemPoints(
          amount: amount,
          points: points,
        );
      }
    }
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
              if (widget.redeemPoint != null) {
                context.read<RedeemPointsCubit>().deleteRedeemPoints(widget.redeemPoint!.id);
              }
            },
            child: Text('delete'.tr(), style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
