import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:systego/features/admin/admins_screen/model/admins_model.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:systego/generated/locale_keys.g.dart';

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
  final _roleController = TextEditingController();
  final _passwordController = TextEditingController();

  String? selectedWarehouse;
  String? selectedRole;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

   String? sele;

  bool get isEditMode => widget.admin != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _setupAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WareHouseCubit>().getWarehouses();
    });
  }

  void _initControllers() {
    if (isEditMode) {
      final admin = widget.admin!;
      _usernameController.text = admin.username;
      _emailController.text = admin.email;
      _phoneController.text = admin.phone;
      _companyController.text = admin.companyName;
      _roleController.text = admin.role;
      selectedWarehouse = admin.warehouseId;
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
    _roleController.dispose();
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
                                buildTextField(
                                  context,
                                  controller: _usernameController,
                                  hint: "Username",
                                  label: "Username",
                                  icon: Icons.person,
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                    v,
                                    "Username",
                                  ),
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _emailController,
                                  label: "Email",
                                  hint: "Email",
                                  icon: Icons.email,
                                  validator: LoginValidator.validateEmail,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _phoneController,
                                  label: "Phone",
                                  hint: "phone",
                                  icon: Icons.phone,
                                  validator: LoginValidator.validatePhone,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _passwordController,
                                  label: "Password",
                                  hint: "Password",
                                  icon: Icons.business,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _companyController,
                                  label: "Company name",
                                  hint: "Company name",
                                  icon: Icons.business,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                // buildTextField(
                                //   context,
                                //   controller: _roleController,
                                //   label: "Role",
                                //   hint: "role",
                                //   icon: Icons.security,
                                // ),
                                 buildDropdownField<String>(
                                  context,
                                  value: selectedRole,
                                  items: ["admin", "superadmin"],
                                  label: 'Role',
                                  icon: Icons.security,

                                  hint: 'Select Role',
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRole = value;
                                    });
                                  },
                                  itemLabel: (type) => type,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a Role';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),

                                // ================= WAREHOUSE =================
                                BlocBuilder<WareHouseCubit, WarehousesState>(
                                  builder: (context, state) {
                                    if (state is WarehousesLoaded) {
                                      final ids =
                                          state.warehouses.map((e) => e.id).toList();
                                      final names = state.warehouses
                                          .map((e) => e.name)
                                          .toList();

                                      return buildDropdownField<String>(
                                        context,
                                        value: selectedWarehouse,
                                        items: ids,
                                        label: "Warehouse",
                                        hint: "select warehouse",
                                        onChanged: (v) =>
                                            setState(() => selectedWarehouse = v),
                                        itemLabel: (id) {
                                          final i = ids.indexOf(id);
                                          return i != -1 ? names[i] : '';
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                               
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
            color: AppColors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      );


  void _handleStateChanges(BuildContext context, AdminsState state) {
  if (state is CreateAdminSuccess || state is UpdateAdminSuccess) {
    Navigator.pop(context);
  } 
  else if (state is CreateAdminError) {
    CustomSnackbar.showError(context, state.error);
  } 
  else if (state is UpdateAdminError) {
    CustomSnackbar.showError(context, state.error);
  }
}


  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AdminsCubit>();

    if (isEditMode) {
      cubit.updateAdmin(
        adminId: widget.admin!.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: selectedRole!,
        companyName: _companyController.text.trim(),
        warehouseId: selectedWarehouse,
        // password: _passwordController.text.trim(),
      );
    } else {
      cubit.createAdmin(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: selectedRole!,
        companyName: _companyController.text.trim(),
        warehouseId: selectedWarehouse,
        password: _passwordController.text.trim(),
      );
    }
  }
}



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
                  isEditMode
                      ? "Edit admin"
                      : "New Admin",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode
                      ? "update admin"
                      : "Add new admin",
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
