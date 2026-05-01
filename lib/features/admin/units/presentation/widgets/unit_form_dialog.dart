import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
import 'package:GoSystem/features/admin/units/cubit/units_cubit.dart';
import 'package:GoSystem/features/admin/units/model/unit_model.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../../../../generated/locale_keys.g.dart';

class UnitFormDialog extends StatefulWidget {
  final UnitModel? unit;

  const UnitFormDialog({super.key, this.unit});

  @override
  State<UnitFormDialog> createState() => _UnitFormDialogState();
}

class _UnitFormDialogState extends State<UnitFormDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  final _codeController = TextEditingController();
  final _operatorValueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String? selectedOperator;
  String? selectedBaseUnit;
  bool isBaseUnit = true;
  bool status = true;

  bool get isEditMode => widget.unit != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  String? validateOperatorValue(String? value) {
    if (!isBaseUnit && (value == null || value.trim().isEmpty)) {
      return LocaleKeys.please_enter_operator_value.tr();
    }

    if (!isBaseUnit && value != null && value.trim().isNotEmpty) {
      final number = double.tryParse(value);
      if (number == null) {
        return LocaleKeys.value_must_be_valid_number.tr();
      }

      if (number <= 0) {
        return LocaleKeys.value_must_be_greater_than_zero.tr();
      }
    }

    return null;
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.unit!.name;
      _arNameController.text = widget.unit!.arName;
      _codeController.text = widget.unit!.code;
      selectedOperator = widget.unit!.operator;
      _operatorValueController.text = widget.unit!.operatorValue.toString();
      isBaseUnit = widget.unit!.baseUnit == null;
      status = widget.unit!.status;
      selectedBaseUnit = widget.unit!.baseUnit?.id;
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
    _codeController.dispose();
    _operatorValueController.dispose();
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
        child: BlocConsumer<UnitsCubit, UnitsState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateUnitLoading || state is UpdateUnitLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UnitDialogHeader(
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
                                  label: LocaleKeys.name_english.tr(),
                                  icon: Icons.straighten_rounded,
                                  hint: LocaleKeys.enter_unit_name_english.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.name_english.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: LocaleKeys.name_arabic.tr(),
                                  icon: Icons.straighten_rounded,
                                  hint: LocaleKeys.enter_unit_name_arabic.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.name_arabic.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _codeController,
                                  label: LocaleKeys.unit_code.tr(),
                                  icon: Icons.code_rounded,
                                  hint: LocaleKeys.enter_unit_code.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.unit_code.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                CheckboxListTile(
                                  title: Text(LocaleKeys.is_base_unit.tr()),
                                  value: isBaseUnit,
                                  onChanged: (value) {
                                    setState(() {
                                      isBaseUnit = value ?? false;
                                      if (isBaseUnit) {
                                        selectedBaseUnit = null;
                                        _operatorValueController.clear();
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primaryBlue,
                                ),
                                if (!isBaseUnit) ...[
                                  SizedBox(
                                    height: ResponsiveUI.spacing(context, 12),
                                  ),
                                  buildDropdownField<String>(
                                    context,
                                    value: selectedBaseUnit,
                                    items: ['Base Unit 1', 'Base Unit 2'], // TODO: Fetch from API
                                    label: LocaleKeys.base_unit.tr(),
                                    icon: Icons.straighten_rounded,
                                    hint: LocaleKeys.select_base_unit.tr(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedBaseUnit = value;
                                      });
                                    },
                                    itemLabel: (unit) => unit,
                                    validator: (value) {
                                      if (!isBaseUnit && value == null) {
                                        return LocaleKeys.please_select_base_unit.tr();
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: ResponsiveUI.spacing(context, 12),
                                  ),
                                  buildDropdownField<String>(
                                    context,
                                    value: selectedOperator,
                                    items: ['*', '/'],
                                    label: LocaleKeys.operator.tr(),
                                    icon: Icons.calculate_rounded,
                                    hint: LocaleKeys.select_operator.tr(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedOperator = value;
                                      });
                                    },
                                    itemLabel: (operator) => operator,
                                    validator: (value) {
                                      if (!isBaseUnit && value == null) {
                                        return LocaleKeys.please_select_operator.tr();
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: ResponsiveUI.spacing(context, 12),
                                  ),
                                  buildTextField(
                                    context,
                                    controller: _operatorValueController,
                                    keyboardType: TextInputType.number,
                                    label: LocaleKeys.operator_value.tr(),
                                    icon: Icons.exposure_rounded,
                                    hint: LocaleKeys.enter_operator_value.tr(),
                                    validator: (v) => validateOperatorValue(v),
                                  ),
                                ],
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                CheckboxListTile(
                                  title: Text(LocaleKeys.active_status.tr()),
                                  value: status,
                                  onChanged: (value) {
                                    setState(() {
                                      status = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primaryBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  UnitDialogButtons(
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

  void _handleStateChanges(BuildContext context, UnitsState state) {
    if (state is CreateUnitSuccess || state is UpdateUnitSuccess) {
      Navigator.of(context).pop();
    }

    if (state is CreateUnitError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateUnitError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<UnitsCubit>();

      if (isEditMode) {
        cubit.updateUnit(
          unitId: widget.unit!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          code: _codeController.text.trim(),
          baseUnit: selectedBaseUnit,
          operator: selectedOperator ?? '*',
          operatorValue: isBaseUnit ? 1.0 : double.parse(_operatorValueController.text.trim()),
          status: status,
        );
      } else {
        cubit.createUnit(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          code: _codeController.text.trim(),
          baseUnit: selectedBaseUnit,
          operator: selectedOperator ?? '*',
          operatorValue: isBaseUnit ? 1.0 : double.parse(_operatorValueController.text.trim()),
          status: status,
        );
      }
    }
  }
}

class UnitDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const UnitDialogHeader({
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
                  isEditMode ? LocaleKeys.edit_unit.tr() : LocaleKeys.new_unit.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode ? LocaleKeys.update_unit_details.tr() : LocaleKeys.add_new_unit.tr(),
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

class UnitDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const UnitDialogButtons({
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
                      isEditMode ? LocaleKeys.update_unit.tr() : LocaleKeys.create_unit.tr(),
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
