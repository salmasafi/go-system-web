import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/utils/validators.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:systego/features/admin/roloes_and_permissions/model/role_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class AddRoleScreen extends StatefulWidget {
  const AddRoleScreen({
    super.key,
  });
  @override
  State<AddRoleScreen> createState() => _AddRoleScreenState();
}

class _AddRoleScreenState extends State<AddRoleScreen> {
  List<Permission> _permissions = [];
  final List<String> _allActions = ['View', 'Add', 'Edit', 'Delete', 'Status'];
  final List<String> _allModules = [
    'user',
    'category',
    'product',
    'warehouse',
    'payment_method',
    'brand',
    'city',
    'country',
    'zone',
    'POS',
    'notification',
    'variation',
    'transfer',
    'product_warehouse',
    'Taxes',
    'discount',
    'coupon',
    'Supplier',
    'customer',
    'gift_card',
    'financial_account',
    'pandel',
    'customer_group',
    'purchase',
    'popup',
    'offer',
    'point',
    'redeem_points',
    'adjustment',
    'Admin',
    'Booking',
    'cashier',
    'cashier_shift',
    'cashier_shift_report',
    'currency',
    'expense_category',
    'generate_label',
    'stock',
    'payment',
    'paymob',
    'material',
    'recipe',
    'adjustment_reason',
    'Category_Material',
  ];
  final _nameController = TextEditingController();
  bool status = true;
  @override
  void initState() {
    super.initState();
    // Fetch permissions when bottom sheet opens
    // context.read<RolesCubit>().getRolePermissions(widget.roleId);
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;
    return BlocConsumer<RolesCubit, RolesState>(
      listener: (context, state) {
        // if (state is PermissionsLoaded) {
        //   setState(() {
        //     _permissions = List.from(state.permissions.permissions);
        //   });
        // }
        if (state is RolesCreateSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context);
        } else if (state is RolesCreateError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is RolesCreating;
        return Scaffold(
          appBar: appBarWithActions(
        context,
        title: LocaleKeys.add_new_role.tr(),
      ),
          body: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? ResponsiveUI.padding(context, 20) : 0,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 249, 254),
              // borderRadius: BorderRadius.vertical(
              //   top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
              // ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 16),
                ),
                child: SingleChildScrollView(
                  // physics: const BouncingScrollPhysics(),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveUI.spacing(context, 8)),
                  
                        // // Title
                        // Text(
                        //   LocaleKeys.edit_admin_permissions.tr(),
                        //   style: TextStyle(
                        //     fontSize: ResponsiveUI.fontSize(context, 20),
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                  
                        // SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  
                        buildTextField(
                          context,
                          controller: _nameController,
                          label: LocaleKeys.role_name.tr(),
                          icon: Icons.people_rounded,
                          hint: LocaleKeys.role_name_hint.tr(),
                          validator: (v) => LoginValidator.validateRequired(
                            v,
                            LocaleKeys.reason_text.tr(),
                          ),
                        ),
                  
                        SizedBox(height: ResponsiveUI.spacing(context, 20)),
                        Row(
                          children: [
                            Text(
                              LocaleKeys.active.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
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
                  
                         SizedBox(height: ResponsiveUI.spacing(context, 20)),
                  
                  
                         Text(
                          LocaleKeys.permissions.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  
                        // Permissions List
                        state is RolesError
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: ResponsiveUI.iconSize(context, 48),
                                      color: AppColors.red,
                                    ),
                                    SizedBox(
                                      height: ResponsiveUI.spacing(context, 12),
                                    ),
                                    Text(
                                      state.error,
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(
                                          context,
                                          14,
                                        ),
                                        color: AppColors.darkGray,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: ResponsiveUI.spacing(context, 16),
                                    ),
                                    CustomElevatedButton(
                                      onPressed: () {},
                                      // => context
                                      //     .read<PermissionsCubit>()
                                      //     .getUserPermissions(widget.userId),
                                      text: LocaleKeys.retry.tr(),
                                    ),
                                  ],
                                ),
                              )
                            : _buildPermissionsList(),
                  
                        // Buttons
                        Row(
                          children: [
                            // Expanded(
                            //   child: CustomElevatedButton(
                            //     onPressed: () => Navigator.pop(context),
                            //     text: LocaleKeys.cancel.tr(),
                            //     // backgroundColor: AppColors.lightGray,
                            //     // textColor: AppColors.darkGray,
                            //   ),
                            // ),
                            SizedBox(width: ResponsiveUI.spacing(context, 12)),
                            Expanded(
                              child: CustomElevatedButton(
                                onPressed: isLoading ? null : _submitUpdate,
                                text: isLoading
                                    ? LocaleKeys.saving.tr()
                                    : LocaleKeys.save.tr(),
                                isLoading: isLoading,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      itemCount: _allModules.length,
      itemBuilder: (context, index) {
        final module = _allModules[index];
        final permission = _permissions.firstWhere(
          (p) => p.module == module,
          orElse: () => Permission(module: module, actions: []),
        );

        return _buildPermissionItem(module, permission);
      },
    );
  }

  Widget _buildPermissionItem(String module, Permission permission) {
    final hasAllActions = _allActions.every(
      (action) => _hasAction(permission, action),
    );
    return Card(
      color: AppColors.lightBlueBackground,
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module header with master checkbox
            Row(
              children: [
                Checkbox(
                  value: hasAllActions,
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _setModuleActions(module, List.from(_allActions));
                      } else {
                        _setModuleActions(module, []);
                      }
                    });
                  },
                  activeColor: AppColors.primaryBlue,
                ),
                Expanded(
                  child: Text(
                    _formatModuleName(module),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            Wrap(
              spacing: ResponsiveUI.spacing(context, 12),
              runSpacing: ResponsiveUI.spacing(context, 8),
              children: _allActions.map((actionName) {
                // FIX: Check existence by comparing String to ActionModel.action
                final isSelected = _hasAction(permission, actionName);

                return SizedBox(
                  width: ResponsiveUI.value(context, 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            _toggleAction(
                              module,
                              actionName,
                              selected ?? false,
                            );
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Text(
                        actionName,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatModuleName(String module) {
    // Convert snake_case or kebab-case to Title Case
    return module
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  // void _toggleAction(String module, String action, bool enable) {
  //   final index = _permissions.indexWhere((p) => p.module == module);
  //   if (index >= 0) {
  //     final currentActions = List<String>.from(_permissions[index].actions);
  //     if (enable) {
  //       if (!currentActions.contains(action)) {
  //         currentActions.add(action);
  //       }
  //     } else {
  //       currentActions.remove(action);
  //     }
  //     _permissions[index] = _permissions[index].copyWith(
  //       actions: currentActions,
  //     );
  //   } else {
  //     if (enable) {
  //       _permissions.add(Permission(
  //         module: module,
  //         actions: [action],
  //       ));
  //     }
  //   }
  // }

  void _toggleAction(String module, String actionName, bool enable) {
    final index = _permissions.indexWhere((p) => p.module == module);

    // Create the ActionModel object
    // Note: We use an empty ID ('') because this is a new assignment.
    // The backend should handle generating IDs or looking them up.
    final actionObj = ActionModel(id: '', action: actionName);

    if (index >= 0) {
      final currentActions = List<ActionModel>.from(
        _permissions[index].actions,
      );

      if (enable) {
        // Prevent duplicates based on the action string
        if (!currentActions.any((a) => a.action == actionName)) {
          currentActions.add(actionObj);
        }
      } else {
        // Remove based on the action string name
        currentActions.removeWhere((a) => a.action == actionName);
      }

      _permissions[index] = _permissions[index].copyWith(
        actions: currentActions,
      );
    } else {
      if (enable) {
        _permissions.add(Permission(module: module, actions: [actionObj]));
      }
    }
  }

  bool _hasAction(Permission permission, String actionName) {
    return permission.actions.any((a) => a.action == actionName);
  }

  // void _setModuleActions(String module, List<String> actions) {
  //   final index = _permissions.indexWhere((p) => p.module == module);
  //   if (index >= 0) {
  //     _permissions[index] = _permissions[index].copyWith(actions: actions);
  //   } else {
  //     _permissions.add(Permission(module: module, actions: actions));
  //   }
  // }

  // FIX: This method converts a list of Strings to a list of ActionModels
  void _setModuleActions(String module, List<String> actionNames) {
    final index = _permissions.indexWhere((p) => p.module == module);

    // Convert Strings to ActionModels
    final actionModels = actionNames
        .map((name) => ActionModel(id: '', action: name))
        .toList();

    if (index >= 0) {
      _permissions[index] = _permissions[index].copyWith(actions: actionModels);
    } else {
      _permissions.add(Permission(module: module, actions: actionModels));
    }
  }

  void _submitUpdate() {
    // Filter out modules with no actions
    final filteredPermissions = _permissions
        .where((p) => p.actions.isNotEmpty)
        .toList();

    context.read<RolesCubit>().createRole(
      name: _nameController.text,
      status: status ? 'active': 'inactive',
      permissions: filteredPermissions,
    );
  }
}
