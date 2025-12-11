import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/utils/validators.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/core/widgets/custom_loading/build_overlay_loading.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/admin/discount/cubit/discount_cubit.dart';
import 'package:systego/features/admin/discount/model/discount_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class DiscountFormDialog extends StatefulWidget {
  final DiscountModel? discount;

  const DiscountFormDialog({super.key, this.discount});

  @override
  State<DiscountFormDialog> createState() => _DiscountFormDialogState();
}

class _DiscountFormDialogState extends State<DiscountFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? selectedType;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.discount != null;
  bool status = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.discount!.name;
      selectedType = widget.discount!.type[0].toUpperCase() +
          widget.discount!.type.substring(1).toLowerCase();
      _amountController.text = widget.discount!.amount.toString();
      status = widget.discount!.status;
    }
  }

  void _setupAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<DiscountsCubit, DiscountsState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateDiscountLoading || state is UpdateDiscountLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: ResponsiveUI.screenHeight(context) * 0.5,
              ),
              decoration: _buildDecoration(context),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.all(
                            ResponsiveUI.padding(context, 24),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                buildTextField(
                                  context,
                                  controller: _nameController,
                                  label: LocaleKeys.discount_name.tr(),
                                  icon: Icons.local_offer,
                                  hint: LocaleKeys.hint_discount_name.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                          v, LocaleKeys.discount_name.tr()),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildDropdownField<String>(
                                  context,
                                  value: selectedType,
                                  items: ["Fixed", "Percentage"],
                                  label: LocaleKeys.discount_type.tr(),
                                  icon: Icons.price_change_rounded,
                                  hint: LocaleKeys.select_discount_type.tr(),
                                  itemLabel: (item) => item,
                                  onChanged: (val) {
                                    setState(() => selectedType = val);
                                  },
                                  validator: (v) =>
                                      v == null ? LocaleKeys.please_select_type.tr() : null,
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _amountController,
                                  label: LocaleKeys.discount_amount.tr(),
                                  icon: Icons.attach_money,
                                  hint: LocaleKeys.please_enter_minimum_amount.tr(),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return LocaleKeys.enter_amount.tr();
                                    }
                                    if (double.tryParse(v) == null) {
                                      return LocaleKeys.invalid_number.tr();
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),

                                 Row(
                                  children: [
                                    Text(
                                      LocaleKeys.active.tr(),
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(
                                          context,
                                          14,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Switch(
                                      value: status,
                                      onChanged: (value) {
                                        setState(() {
                                          status = value;
                                        });
                                      },
                                      activeColor: AppColors.white,
                                      activeTrackColor: AppColors.primaryBlue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  DiscountDialogButtons(
                    isEditMode: isEditMode,
                    isLoading: isLoading,
                    onCancel: () => Navigator.of(context).pop(),
                    onSubmit: _handleSubmit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 30,
          offset: Offset(0, 10),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.white, size: 28),
          SizedBox(
                                  width: ResponsiveUI.spacing(context, 15),
                                ),
          Text(
            isEditMode ? LocaleKeys.edit_discount.tr() : LocaleKeys.new_discount.tr(),
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: Colors.white, size: 26),
          )
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<DiscountsCubit>();

      if (isEditMode) {
        cubit.updateDiscount(
          discountId: widget.discount!.id,
          name: _nameController.text.trim(),
          type: selectedType!.toLowerCase(),
          amount: double.parse(_amountController.text),
          status: status,
        );
      } else {
        cubit.createDiscount(
          name: _nameController.text.trim(),
          type: selectedType!.toLowerCase(),
          amount: double.parse(_amountController.text),
          status: status,
        );
      }
    }
  }

  void _handleStateChanges(BuildContext context, DiscountsState state) {
    if (state is CreateDiscountSuccess || state is UpdateDiscountSuccess) {
      Navigator.pop(context);
    } else if (state is CreateDiscountError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateDiscountError) {
      CustomSnackbar.showError(context, state.error);
    }
  }
}


class DiscountDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const DiscountDialogButtons({
    super.key,
    required this.isEditMode,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final padding24 = ResponsiveUI.padding(context, 24);
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final padding16 = ResponsiveUI.padding(context, 16);
    final value1_5 = ResponsiveUI.value(context, 1.5);
    final fontSize16 = ResponsiveUI.fontSize(context, 16);
    final padding12 = ResponsiveUI.padding(context, 12);
    final value14 = ResponsiveUI.fontSize(context, 14);
    final iconSize20 = ResponsiveUI.iconSize(context, 20);
    final spacing8 = ResponsiveUI.spacing(context, 8);
    final spacing16 = ResponsiveUI.spacing(context, 16);

    return Container(
      padding: EdgeInsets.all(padding24),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius24),
          bottomRight: Radius.circular(borderRadius24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: padding16),
                side: BorderSide(
                  color: AppColors.shadowGray[300]!,
                  width: value1_5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius12),
                ),
              ),
              child: Text(
                LocaleKeys.cancel.tr(),
                style: TextStyle(
                  fontSize: fontSize16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.shadowGray[700],
                ),
              ),
            ),
          ),
          SizedBox(width: spacing16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  vertical: padding16,
                  horizontal: padding12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEditMode
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                    size: iconSize20,
                  ),
                  SizedBox(width: spacing8),
                  Flexible(
                    child: Text(
                      isEditMode ? LocaleKeys.update_discount.tr() : LocaleKeys.create_discount.tr(),
                      style: TextStyle(
                        fontSize: value14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}