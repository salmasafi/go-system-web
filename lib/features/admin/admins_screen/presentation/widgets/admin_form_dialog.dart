
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
import 'package:GoSystem/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:GoSystem/features/admin/admins_screen/model/admins_model.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';

import 'package:GoSystem/generated/locale_keys.g.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';

class AdminFormDialog extends StatefulWidget {
  final AdminModel? admin;

  const AdminFormDialog({super.key, this.admin});

  @override
  State<AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends State<AdminFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();

  String? selectedWarehouse;
  String? selectedRole; // This will store role_id
  bool selectedStatus = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.admin != null;

  @override
  void initState() {
    super.initState();
     context.read<WareHouseCubit>().getWarehouses();
      context.read<RolesCubit>().getAllRoles(); 
    _initControllers();
    _setupAnimation();
    
  }


  void _initControllers() {
    if (isEditMode) {
      final admin = widget.admin!;
      _usernameController.text = admin.username;
      _emailController.text = admin.email;
      _phoneController.text = admin.phone;
      _companyController.text = admin.companyName;
      
      // Map IDs from the model
      selectedWarehouse = admin.warehouse?.id; // Using the nested object from your model
      selectedRole = admin.roleData?.id; // Using the nested object from your model
      selectedStatus = admin.status == 'active';
    } else {
      // Default status for new admin
      selectedStatus = true;
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
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
        child: BlocConsumer<AdminsCubit, AdminsState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateAdminLoading || state is UpdateAdminLoading;

            return Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: _buildDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AdminDialogHeader(
                    isEditMode: isEditMode,
                    onClose: () => Navigator.pop(context),
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
                                // Username
                                buildTextField(
                                  context,
                                  controller: _usernameController,
                                  hint: LocaleKeys.username.tr(),
                                  label: LocaleKeys.username.tr(),
                                  icon: Icons.person,
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                    v,
                                    LocaleKeys.username.tr(),
                                  ),
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                
                                // Email
                                buildTextField(
                                  context,
                                  controller: _emailController,
                                  label: LocaleKeys.email.tr(),
                                  hint: LocaleKeys.email.tr(),
                                  icon: Icons.email,
                                  validator: LoginValidator.validateEmail,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                
                                // Phone
                                buildTextField(
                                  context,
                                  controller: _phoneController,
                                  label: LocaleKeys.phone.tr(),
                                  hint: LocaleKeys.phone.tr(),
                                  icon: Icons.phone,
                                  validator: LoginValidator.validatePhone,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                
                                // Password (Required for New, Optional for Edit)
                                if(!isEditMode)...[
                                   buildTextField(
                                  context,
                                  controller: _passwordController,
                                  label: LocaleKeys.password.tr(),
                                  hint: isEditMode 
                                      ? "Leave empty to keep current" 
                                      : LocaleKeys.password.tr(),
                                  icon: Icons.lock,
                                  validator: (value) {
                                    if (!isEditMode) {
                                      // Required when creating
                                      return LoginValidator.validatePassword(value);
                                    }
                                    // Optional when updating (validate only if entered)
                                    if (value != null && value.isNotEmpty) {
                                       if (value.length < 6) return "LocaleKeys.password_too_short.tr()";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                ],
                               
                                
                                // Company Name
                                buildTextField(
                                  context,
                                  controller: _companyController,
                                  label: LocaleKeys.company_name.tr(),
                                  hint: LocaleKeys.company_name.tr(),
                                  icon: Icons.business,
                                  validator: (v) => LoginValidator.validateRequired(
                                    v, 
                                    LocaleKeys.company_name.tr()
                                  ),
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),

                                // ================= ROLES =================
                                BlocBuilder<RolesCubit, RolesState>(
                                  builder: (context, state) {
                                    if (state is RolesLoaded) {
                                      final ids = state.roles.map((e) => e.id).toList();
                                      final names = state.roles.map((e) => e.name).toList();

                                      return buildDropdownField<String>(
                                        context,
                                        value: selectedRole,
                                        items: ids,
                                        label: LocaleKeys.role.tr(),
                                        hint: LocaleKeys.select_role.tr(),
                                        icon: Icons.security,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRole = value;
                                          });
                                        },
                                        itemLabel: (id) {
                                           final i = ids.indexOf(id);
                                           return i != -1 ? names[i] : '';
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return LocaleKeys.please_select_role.tr();
                                          }
                                          return null;
                                        },
                                      );
                                    }
                                    return const LinearProgressIndicator(); // Show loading or empty
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),

                                // ================= WAREHOUSE =================
                                BlocBuilder<WareHouseCubit, WarehousesState>(
                                  builder: (context, state) {
                                    if (state is WarehousesLoaded) {
                                      final ids = state.warehouses.map((e) => e.id).toList();
                                      final names = state.warehouses.map((e) => e.name).toList();

                                      return buildDropdownField<String>(
                                        context,
                                        value: selectedWarehouse,
                                        items: ids,
                                        label: LocaleKeys.warehouse.tr(),
                                        hint: LocaleKeys.select_warehouse.tr(),
                                        icon: Icons.store,
                                        onChanged: (v) =>
                                            setState(() => selectedWarehouse = v),
                                        itemLabel: (id) {
                                          final i = ids.indexOf(id);
                                          return i != -1 ? names[i] : '';
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return LocaleKeys.select_warehouse.tr();
                                          }
                                          return null;
                                        },
                                      );
                                    }
                                    return const LinearProgressIndicator();
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),

                                // ================= STATUS =================
                                // buildDropdownField<String>(
                                //   context,
                                //   value: selectedStatus,
                                //   items: ['active', 'inactive'],
                                //   label: "Status", // Add to LocaleKeys later
                                //   hint: "Select Status",
                                //   icon: Icons.toggle_on,
                                //   onChanged: (value) {
                                //     setState(() {
                                //       selectedStatus = value;
                                //     });
                                //   },
                                //   itemLabel: (val) => val.capitalize(),
                                //   validator: (value) =>
                                //       value == null ? "Please select status" : null,
                                // ),

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
                                      value: selectedStatus,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatus = value;
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
                  _AdminDialogButtons(
                    isEditMode: isEditMode,
                    isLoading: isLoading,
                    onCancel: () => Navigator.pop(context),
                    onSubmit: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      );

  void _handleStateChanges(BuildContext context, AdminsState state) {
    if (state is CreateAdminSuccess || state is UpdateAdminSuccess) {
      Navigator.pop(context);
    } else if (state is CreateAdminError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateAdminError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AdminsCubit>();
    final password = _passwordController.text.trim();

    if (isEditMode) {
      cubit.updateAdmin(
        adminId: widget.admin!.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        roleId: selectedRole!,
        companyName: _companyController.text.trim(),
        warehouseId: selectedWarehouse!,
        status: selectedStatus == true ? "active" : "inactive",
        // Only send password if user typed something
        password: password.isNotEmpty ? password : null,
      );
    } else {
      cubit.createAdmin(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        roleId: selectedRole!,
        companyName: _companyController.text.trim(),
        warehouseId: selectedWarehouse!,
         status: selectedStatus == true ? "active" : "inactive",
        password: password,
      );
    }
  }
}

// Helper extension for capitalizing status
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// ... _AdminDialogHeader and _AdminDialogButtons remain the same as your code ...
class _AdminDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const _AdminDialogHeader({
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
                      ? LocaleKeys.edit_admin.tr()
                      : LocaleKeys.new_admin.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode
                      ? LocaleKeys.update_admin.tr()
                      : LocaleKeys.add_new_admin.tr(),
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

class _AdminDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _AdminDialogButtons({
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
                          ? LocaleKeys.update_account.tr()
                          : LocaleKeys.create_account.tr(),
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

