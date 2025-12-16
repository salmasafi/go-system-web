import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/currency/model/currency_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../cubit/currency_cubit.dart';

class CurrencyFormDialog extends StatefulWidget {
  final CurrencyModel? currency;

  const CurrencyFormDialog({super.key, this.currency});

  @override
  State<CurrencyFormDialog> createState() => _CurrencyFormDialogState();
}

class _CurrencyFormDialogState extends State<CurrencyFormDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool status = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.currency != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.currency!.name;
      _arNameController.text = widget.currency!.arName;
      _amountController.text = widget.currency!.amount.toString();
      status = widget.currency!.isDefault;
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
    _arNameController.dispose();
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
        child: BlocConsumer<CurrencyCubit, CurrencyState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateCurrencyLoading ||
                state is UpdateCurrencyLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CurrencyDialogHeader(
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
                                  label: LocaleKeys.currency_name_en_label.tr(),
                                  icon: Icons.monetization_on_rounded,
                                  hint: LocaleKeys.hint_currency_name_en.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.currency_name_en_label.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _amountController,
                                  label: "Amount",
                                  icon: Icons.monetization_on_rounded,
                                  hint: "Amount",
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        "Amount",
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: LocaleKeys.currency_name_ar_label.tr(),
                                  icon: Icons.monetization_on_rounded,
                                  hint: LocaleKeys.hint_currency_name_ar_dialog.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.currency_name_ar_label.tr(),
                                      ),
                                ),

                                 SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Default",
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
                  CurrencyDialogButtons(
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

  void _handleStateChanges(BuildContext context, CurrencyState state) {
    if (state is CreateCurrencySuccess || state is UpdateCurrencySuccess) {
      Navigator.of(context).pop();
    }

    if (state is CreateCurrencyError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateCurrencyError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<CurrencyCubit>();

      final amount = double.tryParse(_amountController.text) ?? 0.0;

      if (isEditMode) {
        cubit.updateCurrency(
          currencyId: widget.currency!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          isDefault: status,
          amount: amount,
        );
      } else {
        cubit.createCurrency(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          isDefault: status,
          amount: amount,
        );
      }
    }
  }
}

class CurrencyDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const CurrencyDialogHeader({
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
                  isEditMode ? LocaleKeys.edit_currency.tr() : LocaleKeys.new_currency.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode ? LocaleKeys.update_currency_details.tr() : LocaleKeys.add_new_currency.tr(),
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

class CurrencyDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const CurrencyDialogButtons({
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
    //final value3 = ResponsiveUI.value(context, 300);

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
                      isEditMode ? LocaleKeys.update_currency_button.tr() : LocaleKeys.create_currency_button.tr(),
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

