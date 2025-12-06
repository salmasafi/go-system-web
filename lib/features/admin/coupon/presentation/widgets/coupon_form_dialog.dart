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
                                  label: 'Coupon Code',
                                  icon: Icons.local_offer,
                                  hint: 'Enter coupon code',
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                          v, 'coupon code'),
                                ),
                                SizedBox(height: 12),
                                buildDropdownField<String>(
                                  context,
                                  value: selectedType,
                                  items: ["Flat", "Percentage"],
                                  label: 'Coupon Type',
                                  icon: Icons.price_change_rounded,
                                  hint: 'Select coupon type',
                                  itemLabel: (item) => item,
                                  onChanged: (val) {
                                    setState(() => selectedType = val);
                                  },
                                  validator: (v) =>
                                      v == null ? "Please select type" : null,
                                ),
                                SizedBox(height: 12),
                                buildTextField(
                                  context,
                                  controller: _amountController,
                                  label: 'Amount',
                                  icon: Icons.attach_money,
                                  hint: 'Enter amount (number)',
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return "Enter amount";
                                    }
                                    if (double.tryParse(v) == null) {
                                      return "Invalid number";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 12),
                                buildTextField(
                                  context,
                                  controller: _minAmountController,
                                  label: 'Minimum Order Amount',
                                  icon: Icons.shopping_cart_checkout,
                                  hint: 'Minimum amount to apply coupon',
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return "Enter minimum amount";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 12),
                                buildTextField(
                                  context,
                                  controller: _quantityController,
                                  label: 'Quantity',
                                  icon: Icons.numbers,
                                  hint: "Total coupon quantity",
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return "Enter quantity";
                                    }
                                    if (int.tryParse(v) == null) {
                                      return "Invalid number";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 12),
                                buildTextField(
                                  context,
                                  controller: _availableController,
                                  label: 'Available',
                                  icon: Icons.numbers,
                                  hint: "Total available coupons",
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return "Enter available count";
                                    }
                                    if (int.tryParse(v) == null) {
                                      return "Invalid number";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 12),
                                buildTextField(
                                  context,
                                  controller: _expiredDateController,
                                  label: 'Expired Date',
                                  icon: Icons.date_range,
                                  readOnly: true,
                                  hint: 'Pick expiration date',
                                  onTap: _pickDate,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return "Pick expiration date";
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
            isEditMode ? "Edit Coupon" : "New Coupon",
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
