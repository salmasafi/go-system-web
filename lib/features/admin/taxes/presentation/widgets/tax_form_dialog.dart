import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:systego/features/admin/taxes/model/taxes_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';

class TaxFormDialog extends StatefulWidget {
  final TaxModel? tax;

  const TaxFormDialog({super.key, this.tax});

  @override
  State<TaxFormDialog> createState() => _TaxFormDialogState();
}

class _TaxFormDialogState extends State<TaxFormDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _arNameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String? selectedtaxType;

  bool get isEditMode => widget.tax != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  String? validateTaxAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.please_enter_tax_amount.tr();
    }

    final number = double.tryParse(value);
    if (number == null) {
      return LocaleKeys.amount_must_be_valid_number.tr();
    }

    if (number <= 0) {
      return LocaleKeys.amount_must_be_greater_than_zero.tr();
    }

    return null;
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.tax!.name;
      _arNameController.text = widget.tax!.arName ?? '';
      _amountController.text = widget.tax!.amount.toString();
      selectedtaxType =
          widget.tax!.type[0].toUpperCase() +
          widget.tax!.type.substring(1).toLowerCase();
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
    _amountController.dispose();
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
        child: BlocConsumer<TaxesCubit, TaxesState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateTaxLoading || state is UpdateTaxLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TaxDialogHeader(
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
                                  label: LocaleKeys.tax_name_en.tr(),
                                  icon: Icons.receipt_long_rounded,
                                  hint: LocaleKeys.tax_name_en_hint.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.tax_name_en.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: LocaleKeys.tax_name_ar.tr(),
                                  icon: Icons.receipt_long_rounded,
                                  hint: LocaleKeys.tax_name_ar_hint.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.tax_name_ar.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildDropdownField<String>(
                                  context,
                                  value: selectedtaxType,
                                   items: [
                                    LocaleKeys.tax_type_fixed.tr(),
                                    LocaleKeys.tax_type_percentage.tr()
                                  ],
                                  label: LocaleKeys.tax_type.tr(),
                                  icon: Icons.price_change_rounded,

                                  hint: LocaleKeys.tax_type_hint.tr(),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedtaxType = value;
                                    });
                                  },
                                  itemLabel: (type) => type,
                                  validator: (value) {
                                    if (value == null) {
                                      return LocaleKeys.please_select_tax_type.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  label: LocaleKeys.amount.tr(),
                                  icon: Icons.attach_money_rounded,
                                  hint:LocaleKeys.amount_hint.tr(),
                                  validator: (v) => validateTaxAmount(v),
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

  BoxDecoration _buildDialogDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 24),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.2),
          blurRadius: ResponsiveUI.value(context, 30),
          offset: Offset(0, ResponsiveUI.value(context, 10)),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, TaxesState state) {
    if (state is CreateTaxSuccess || state is UpdateTaxSuccess) {
      Navigator.of(context).pop();
    }

    if (state is CreateTaxError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateTaxError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<TaxesCubit>();

      if (isEditMode) {
        cubit.updateTax(
          taxId: widget.tax!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          taxType: selectedtaxType!.toLowerCase(),
          amount: double.parse(_amountController.text.trim()),
        );
      } else {
        cubit.createTax(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          taxType: selectedtaxType!.toLowerCase(),
          amount: double.parse(_amountController.text.trim()),
        );
      }
    }
  }
}

class TaxDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const TaxDialogHeader({
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
            AppColors.primaryBlue.withOpacity(0.8),
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
              color: AppColors.white.withOpacity(0.2),
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
                  isEditMode ? LocaleKeys.edit_tax.tr() : LocaleKeys.new_tax.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode ? LocaleKeys.update_tax_details.tr() : LocaleKeys.add_new_tax.tr(),
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
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

class TaxDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const TaxDialogButtons({
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
                      isEditMode ? LocaleKeys.update_tax.tr() : LocaleKeys.create_tax.tr(),
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
