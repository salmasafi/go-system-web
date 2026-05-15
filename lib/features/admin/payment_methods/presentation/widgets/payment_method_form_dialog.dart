import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../cubit/payment_method_cubit.dart';
import '../../cubit/payment_method_state.dart';
import '../../model/payment_method_model.dart';

class PaymentMethodFormDialog extends StatefulWidget {
  final PaymentMethodModel? paymentMethod;
  final String? existingImageUrl;

  const PaymentMethodFormDialog({
    super.key,
    this.paymentMethod,
    this.existingImageUrl,
  });

  @override
  State<PaymentMethodFormDialog> createState() =>
      _PaymentMethodFormDialogState();
}

class _PaymentMethodFormDialogState extends State<PaymentMethodFormDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.paymentMethod != null;
  String? selectedtaxType;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.paymentMethod!.name;
      _typeController.text = widget.paymentMethod!.type;
      _descriptionController.text = widget.paymentMethod!.description;
      selectedtaxType = widget.paymentMethod!.type.toLowerCase();
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);
    final maxHeight = ResponsiveUI.screenHeight(context) * 0.85;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<PaymentMethodCubit, PaymentMethodState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreatePaymentMethodLoading ||
                state is UpdatePaymentMethodLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PaymentMethodDialogHeader(
                    isEditMode: isEditMode,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Flexible(
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
                                  label: LocaleKeys.payment_method_name_en.tr(),
                                  icon: Icons.attach_money_rounded,
                                  hint: LocaleKeys.enter_payment_method_name_en
                                      .tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.payment_method_name_en.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildDropdownField<String>(
                                  context,
                                  value: selectedtaxType,
                                  items: ["manual", "automatic"],
                                  label: LocaleKeys.tax_type.tr(),
                                  icon: Icons.attach_money_rounded,

                                  hint: LocaleKeys.select_tax_type.tr(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedtaxType = value;
                                    });
                                  },
                                  itemLabel: (type) => type,
                                  validator: (value) {
                                    if (value == null) {
                                      return LocaleKeys.please_select_tax_type
                                          .tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _descriptionController,
                                  label: LocaleKeys.description.tr(),
                                  icon: Icons.description,
                                  hint: LocaleKeys.enter_description.tr(),
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  PaymentMethodDialogButtons(
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

  BoxDecoration _buildDialogDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 24),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.2),
          blurRadius: ResponsiveUI.value(context, 30),
          offset: Offset(0, ResponsiveUI.value(context, 10)),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, PaymentMethodState state) {
    if (state is CreatePaymentMethodSuccess) {
      CustomSnackbar.showSuccess(context, state.message);
      Navigator.of(context).pop();
    } else if (state is UpdatePaymentMethodSuccess) {
      CustomSnackbar.showSuccess(context, state.message);
      Navigator.of(context).pop();
    } else if (state is CreatePaymentMethodError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdatePaymentMethodError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<PaymentMethodCubit>();
      if (isEditMode) {
        cubit.updatePaymentMethod(
          paymentMethodId: widget.paymentMethod!.id,
          name: _nameController.text.trim(),
          type: selectedtaxType!.toLowerCase(),
          description: _descriptionController.text.trim(),
          isActive: true,
          icon: null,
        );
      } else {
        cubit.createPaymentMethod(
          name: _nameController.text.trim(),
          type: selectedtaxType!.toLowerCase(),
          description: _descriptionController.text.trim(),
          isActive: true,
          icon: null,
        );
      }
    }
  }
}

// PaymentMethodDialogHeader and PaymentMethodDialogButtons remain unchanged
class PaymentMethodDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const PaymentMethodDialogHeader({
    super.key,
    required this.isEditMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = ResponsiveUI.padding(context, 24);
    final paddingVertical = ResponsiveUI.padding(context, 20);
    final iconSize28 = ResponsiveUI.iconSize(context, 28);
    final fontSize22 = ResponsiveUI.fontSize(context, 22);
    final fontSize13 = ResponsiveUI.fontSize(context, 13);
    final spacing16 = ResponsiveUI.spacing(context, 16);
    final padding10 = ResponsiveUI.padding(context, 10);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final iconSize24 = ResponsiveUI.iconSize(context, 24);
    final padding8 = ResponsiveUI.padding(context, 8);
    final borderRadius20 = ResponsiveUI.borderRadius(context, 20);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius24),
          topRight: Radius.circular(borderRadius24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(borderRadius12),
            ),
            child: Icon(
              isEditMode ? Icons.edit : Icons.add,
              color: AppColors.white,
              size: iconSize28,
            ),
          ),
          SizedBox(width: spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode
                      ? LocaleKeys.edit_payment_method.tr()
                      : LocaleKeys.new_payment_method.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode
                      ? LocaleKeys.update_payment_method_details.tr()
                      : LocaleKeys.add_a_new_payment_method.tr(),
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: fontSize13,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius20),
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.all(padding8),
                child: Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: iconSize24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const PaymentMethodDialogButtons({
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
                      isEditMode
                          ? LocaleKeys.update_payment_method.tr()
                          : LocaleKeys.create_payment_method.tr(),
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

