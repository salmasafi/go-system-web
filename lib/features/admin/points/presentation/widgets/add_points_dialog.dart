import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_textfield/build_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../cubit/points_cubit.dart';
import '../../cubit/points_state.dart';
import '../../model/points_model.dart';

class AddPointsDialog extends StatefulWidget {
  final PointsModel? point;

  const AddPointsDialog({super.key, this.point});

  @override
  State<AddPointsDialog> createState() => _AddPointsDialogState();
}

class _AddPointsDialogState extends State<AddPointsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.point != null) {
      _amountController.text = widget.point!.amount.toString();
      _pointsController.text = widget.point!.points.toString();
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
    final isEditing = widget.point != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
      child: Container(
        width: ResponsiveUI.value(context, 500),
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
                  Container(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    ),
                    child: Icon(
                      Icons.stars_rounded,
                      color: const Color(0xFF4CAF50),
                      size: ResponsiveUI.iconSize(context, 24),
                    ),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? LocaleKeys.update_category.tr() : LocaleKeys.new_brand.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 20),
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          'Configure the amount and points ratio',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            color: AppColors.shadowGray,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // Form Fields
              buildTextField(
                context,
                controller: _amountController,
                label: '${LocaleKeys.amount.tr()} (EGP)',
                hint: LocaleKeys.enter_total_points.tr(),
                icon: Icons.monetization_on_rounded,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.warning_enter_valid_points.tr();
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return LocaleKeys.warning_enter_valid_points.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              buildTextField(
                context,
                controller: _pointsController,
                label: LocaleKeys.total_points.tr(),
                hint: LocaleKeys.enter_total_points.tr(),
                icon: Icons.stars_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.warning_enter_valid_points.tr();
                  }
                  final points = int.tryParse(value);
                  if (points == null || points <= 0) {
                    return LocaleKeys.warning_enter_valid_points.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                        ),
                        side: BorderSide(color: AppColors.lightGray),
                      ),
                      child: Text(
                        LocaleKeys.ok.tr(),
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 12)),
                  Expanded(
                    flex: 2,
                    child: BlocConsumer<PointsCubit, PointsState>(
                      listener: (context, state) {
                        if (state is CreatePointsSuccess) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        } else if (state is UpdatePointsSuccess) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        } else if (state is CreatePointsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        } else if (state is UpdatePointsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is CreatePointsLoading || 
                                       state is UpdatePointsLoading;

                        return ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                            ),
                            disabledBackgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: ResponsiveUI.value(context, 20),
                                  width: ResponsiveUI.value(context, 20),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  isEditing ? LocaleKeys.update_category.tr() : LocaleKeys.new_brand.tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final points = int.parse(_pointsController.text);

      if (widget.point != null) {
        context.read<PointsCubit>().updatePoints(
          id: widget.point!.id,
          amount: amount,
          points: points,
        );
      } else {
        context.read<PointsCubit>().createPoints(
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
        title: Text('Delete Points Configuration'),
        content: Text('Are you sure you want to delete this points configuration?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.point != null) {
                context.read<PointsCubit>().deletePoints(widget.point!.id);
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
