import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/utils/validators.dart';
import 'package:systego/core/widgets/custom_loading/build_overlay_loading.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:systego/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class ExpenseCategoryFormDialog extends StatefulWidget {
  final ExpenseCategoryModel? category;

  const ExpenseCategoryFormDialog({super.key, this.category});

  @override
  State<ExpenseCategoryFormDialog> createState() =>
      _ExpenseCategoryFormDialogState();
}

class _ExpenseCategoryFormDialogState extends State<ExpenseCategoryFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  bool status = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.category!.name;
      _arNameController.text = widget.category!.arName;
      status = widget.category!.status;
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<ExpenseCategoryCubit, ExpenseCategoryState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateExpenseCategoryLoading ||
                state is UpdateExpenseCategoryLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: ResponsiveUI.screenHeight(context) * 0.7,
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
                                  label: LocaleKeys.name.tr(),
                                  icon: Icons.category,
                                  hint: LocaleKeys.enter_category_name.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.name.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: LocaleKeys.arabic_name.tr(),
                                  icon: Icons.translate,
                                  hint: LocaleKeys.enter_arabic_name.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.arabic_name.tr(),
                                      ),
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
                  ExpenseCategoryDialogButtons(
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
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 24),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.category, color: Colors.white, size: 28),
          SizedBox(width: ResponsiveUI.spacing(context, 15)),
          Text(
            isEditMode
                ? LocaleKeys.edit_expense_category.tr()
                : LocaleKeys.new_expense_category.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<ExpenseCategoryCubit>();

      if (isEditMode) {
        cubit.updateExpenseCategory(
          categoryId: widget.category!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          status: status,
        );
      } else {
        cubit.createExpenseCategory(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          status: status,
        );
      }
    }
  }

  void _handleStateChanges(BuildContext context, ExpenseCategoryState state) {
    if (state is CreateExpenseCategorySuccess ||
        state is UpdateExpenseCategorySuccess) {
      Navigator.pop(context);
    } else if (state is CreateExpenseCategoryError) {
      CustomSnackbar.showError(context, state.errorMessage);
    } else if (state is UpdateExpenseCategoryError) {
      CustomSnackbar.showError(context, state.errorMessage);
    }
  }
}

class ExpenseCategoryDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const ExpenseCategoryDialogButtons({
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
                          ? LocaleKeys.update_category.tr()
                          : LocaleKeys.create_category.tr(),
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
