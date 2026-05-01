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
import 'package:systego/features/admin/coupon/cubit/coupon_cubit.dart';
import 'package:systego/features/admin/coupon/model/coupon_model.dart';
import 'package:systego/generated/locale_keys.g.dart';


class CouponFormDialog extends StatefulWidget {
  final CouponModel? coupon;

  const CouponFormDialog({super.key, this.coupon});

  @override
  State<CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<CouponFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _amountController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expiredDateController = TextEditingController();
  final _availableController = TextEditingController();

  String? selectedType;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _codeController.text = widget.coupon!.couponCode;
      selectedType = widget.coupon!.type[0].toUpperCase() +
          widget.coupon!.type.substring(1).toLowerCase();
      _amountController.text = widget.coupon!.amount.toString();
      _minAmountController.text = widget.coupon!.minimumAmount.toString();
      _quantityController.text = widget.coupon!.quantity.toString();
      _expiredDateController.text =
          widget.coupon!.expiredDate.split("T").first;
      // Calculate available coupons: quantity - (quantity - available)
      // If available represents remaining count, use it directly
      _availableController.text = widget.coupon!.available.toString();
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
    _codeController.dispose();
    _amountController.dispose();
    _minAmountController.dispose();
    _quantityController.dispose();
    _expiredDateController.dispose();
    _animationController.dispose();
    _availableController.dispose();
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
        child: BlocConsumer<CouponsCubit, CouponsState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateCouponLoading || state is UpdateCouponLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: ResponsiveUI.screenHeight(context) * 0.85,
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
                                  controller: _codeController,
                                  label: LocaleKeys.coupon_code.tr(),
                                  icon: Icons.local_offer,
                                  hint: LocaleKeys.hint_coupon_code.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                          v, LocaleKeys.coupon_code.tr()),
                                ),
                                SizedBox(height: ResponsiveUI.value(context, 12)),
                                buildDropdownField<String>(
                                  context,
                                  value: selectedType,
                                  items: ["Flat", "Percentage"],
                                  label: LocaleKeys.coupon_type.tr(),
                                  icon: Icons.price_change_rounded,
                                  hint: LocaleKeys.select_coupon_type.tr(),
                                  itemLabel: (item) => item,
                                  onChanged: (val) {
                                    setState(() => selectedType = val);
                                  },
                                  validator: (v) =>
                                      v == null ? LocaleKeys.please_select_type.tr() : null,
                                ),
                                SizedBox(height: ResponsiveUI.value(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _amountController,
                                  label: LocaleKeys.coupon_amount.tr(),
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
                                SizedBox(height: ResponsiveUI.value(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _minAmountController,
                                  label: LocaleKeys.minimum_order_amount.tr(),
                                  icon: Icons.shopping_cart_checkout,
                                  hint: LocaleKeys.minimum_amount_to_apply_coupon_hint.tr(),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return LocaleKeys.please_enter_minimum_amount.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.value(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _quantityController,
                                  label: LocaleKeys.coupon_quantity.tr(),
                                  icon: Icons.numbers,
                                  hint: LocaleKeys.total_coupon_quantity_hint.tr(),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return LocaleKeys.enter_quantity.tr();
                                    }
                                    if (int.tryParse(v) == null) {
                                      return LocaleKeys.invalid_number.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.value(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _availableController,
                                  label: LocaleKeys.coupon_available.tr(),
                                  icon: Icons.numbers,
                                  hint: LocaleKeys.total_available_coupons_hint.tr(),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return LocaleKeys.enter_available_count_validation.tr();
                                    }
                                    if (int.tryParse(v) == null) {
                                      return LocaleKeys.invalid_number.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.value(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _expiredDateController,
                                  label: LocaleKeys.expired_date_label.tr(),
                                  icon: Icons.date_range,
                                  readOnly: true,
                                  hint: LocaleKeys.pick_expiration_date.tr(),
                                  onTap: _pickDate,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return LocaleKeys.pick_expiration_date.tr();
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  CouponDialogButtons(
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
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 30,
          offset: Offset(0, 10),
        )
      ],
    );
  }


  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.white, size: ResponsiveUI.iconSize(context, 28)),
          SizedBox(width: ResponsiveUI.value(context, 15)),
          Text(
            isEditMode ? LocaleKeys.edit_coupon.tr() : LocaleKeys.new_coupon.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 22),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: Colors.white, size: ResponsiveUI.iconSize(context, 26)),
          )
        ],
      ),
    );
  }


  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEditMode
          ? DateTime.parse(widget.coupon!.expiredDate)
          : now,
      firstDate: now,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _expiredDateController.text = picked.toIso8601String().split("T").first;
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<CouponsCubit>();

      if (isEditMode) {
        cubit.updateCoupon(
          couponId: widget.coupon!.id,
          couponCode: _codeController.text.trim(),
          type: selectedType!.toLowerCase(),
          amount: double.parse(_amountController.text),
          minimumAmount: double.parse(_minAmountController.text),
          quantity: int.parse(_quantityController.text),
          expiredDate: _expiredDateController.text.trim(),
          available: int.parse(_availableController.text),
        );
      } else {
        cubit.createCoupon(
          couponCode: _codeController.text.trim(),
          type: selectedType!.toLowerCase(),
          amount: double.parse(_amountController.text),
          minimumAmount: double.parse(_minAmountController.text),
          quantity: int.parse(_quantityController.text),
          expiredDate: _expiredDateController.text.trim(),
          available: int.parse(_availableController.text),
        );
      }
    }
  }

  void _handleStateChanges(BuildContext context, CouponsState state) {
    if (state is CreateCouponSuccess || state is UpdateCouponSuccess) {
      Navigator.pop(context);
    } else if (state is CreateCouponError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateCouponError) {
      CustomSnackbar.showError(context, state.error);
    }
  }
}

class CouponDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const CouponDialogButtons({
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
                      isEditMode ? LocaleKeys.update_coupon.tr() : LocaleKeys.create_coupon.tr(),
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


