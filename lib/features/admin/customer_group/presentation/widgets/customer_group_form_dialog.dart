


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/utils/validators.dart';
import 'package:systego/core/widgets/custom_loading/build_overlay_loading.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CustomerGroupFormDialog extends StatefulWidget {
  const CustomerGroupFormDialog({super.key});

  @override
  State<CustomerGroupFormDialog> createState() => _CustomerGroupFormDialogState();
}

class _CustomerGroupFormDialogState extends State<CustomerGroupFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool status = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
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
        child: BlocConsumer<CustomerCubit, CustomerState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading = state is CreateCustomerGroupLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: ResponsiveUI.screenHeight(context) * 0.55,
              ),
              decoration: _buildDecoration(context),
              child: Column(
                children: [
                  CustomerGroupDialogHeader(
                    onClose: () => Navigator.of(context).pop(),
                  ),
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
                                  label: LocaleKeys.customer_group_name.tr(),
                                  icon: Icons.group,
                                  hint: LocaleKeys.hint_customer_group_name.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                          v, LocaleKeys.customer_group_name.tr()),
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
                  CustomerGroupDialogButtons(
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<CustomerCubit>();
      
      cubit.addCustomerGroup(
        name: _nameController.text.trim(),
        status: status,
      );
    }
  }

  void _handleStateChanges(BuildContext context, CustomerState state) {
    if (state is CreateCustomerGroupSuccess) {
      CustomSnackbar.showSuccess(context, state.message);
      Navigator.pop(context);
    } else if (state is CreateCustomerGroupError) {
      CustomSnackbar.showError(context, state.error);
    }
  }
}

class CustomerGroupDialogButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const CustomerGroupDialogButtons({
    super.key,
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
                    Icons.add_circle_outline,
                    size: iconSize20,
                  ),
                  SizedBox(width: spacing8),
                  Flexible(
                    child: Text(
                      LocaleKeys.create_customer_group.tr(),
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


class CustomerGroupDialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const CustomerGroupDialogHeader({
    super.key,
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
              Icons.group_add,
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
                  LocaleKeys.new_customer_group.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  LocaleKeys.new_customer_group.tr(),
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