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
import 'package:systego/features/admin/taxes/presentation/widgets/tax_form_dialog.dart';
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
                                SizedBox(height: 12),
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
                                SizedBox(height: 12),
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
                                SizedBox(height: 12),
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
                                SizedBox(height: 12),
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
                                SizedBox(height: 12),
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
                                SizedBox(height: 12),
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
                  TaxDialogButtons(
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
          SizedBox(width: 15),
          Text(
            isEditMode ? LocaleKeys.edit_coupon.tr() : LocaleKeys.new_coupon.tr(),
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
