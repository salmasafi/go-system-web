import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/roloes_and_permissions/model/role_model.dart'; 
import 'package:systego/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class EditRolesBottomSheet extends StatefulWidget {
  final String roleName;
  final String roleId;
  final int permissionCount;
  final String status;
  // Added: Pass existing permissions here
  final List<Permission> currentPermissions; 

  const EditRolesBottomSheet({
    super.key,
    required this.roleName,
    required this.roleId,
    required this.permissionCount,
    required this.status,
    required this.currentPermissions,
  });

  @override
  State<EditRolesBottomSheet> createState() => _EditRolesBottomSheetState();
}

class _EditRolesBottomSheetState extends State<EditRolesBottomSheet> {
  // Changed to Permission model to match AddScreen
  List<Permission> _permissions = []; 
  
  // Aligned actions with AddScreen
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

  late TextEditingController _nameController;
  late bool status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.roleName);
    status = widget.status == 'active';

    // Initialize local permissions from the passed widget data.
    // We create a deep-ish copy to avoid modifying the parent list directly before saving.
    _permissions = widget.currentPermissions.map((p) => Permission(
      module: p.module,
      actions: List.from(p.actions),
    )).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;

    // Switched to RolesCubit
    return BlocConsumer<RolesCubit, RolesState>(
      listener: (context, state) {
        if (state is RolesUpdateSuccess) { // Assuming you have this state
          CustomSnackbar.showSuccess(context, LocaleKeys.role_updated.tr());
          Navigator.pop(context);
        } else if (state is RolesError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is RolesUpdating; // Assuming you have this state

        return Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? ResponsiveUI.padding(context, 20) : 0,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 243, 249, 254),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Draggable handle
                  Container(
                    width: ResponsiveUI.value(context, 40),
                    height: ResponsiveUI.value(context, 4),
                    margin: EdgeInsets.only(
                      top: ResponsiveUI.spacing(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          ResponsiveUI.borderRadius(context, 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  // Header / Role Info
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
                          child: Text(
                            widget.roleName.isNotEmpty
                                ? widget.roleName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveUI.spacing(context, 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.roleName,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGray,
                                ),
                              ),
                              Text(
                                "${widget.permissionCount} ${LocaleKeys.permissions.tr()}",
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 12),
                                  color: AppColors.darkGray.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.edit_role_permissions.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  Padding(
                     padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                    ),
                    child: Row(
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
                  ),

                        // SizedBox(height: ResponsiveUI.spacing(context, 10)),

                  // Permissions List
                  Expanded(
                    child: _buildPermissionsList(),
                  ),

                  // Buttons
                  Padding(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            text: LocaleKeys.cancel.tr(),
                            // backgroundColor: AppColors.lightGray,
                            // textColor: AppColors.darkGray,
                          ),
                        ),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionsList() {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
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
    // Check if current permission has all actions in the list
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
    return module
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // --- Logic synchronized with AddRoleScreen ---

  bool _hasAction(Permission permission, String actionName) {
    return permission.actions.any((a) => a.action == actionName);
  }

  void _toggleAction(String module, String actionName, bool enable) {
    final index = _permissions.indexWhere((p) => p.module == module);
    
    // We create a new ActionModel. 
    // Note: If you need to preserve IDs for editing, you might need to check
    // if the ID existed in widget.currentPermissions, but usually for updates
    // creating a new object with ID '' or matching the name is fine depending on backend.
    final actionObj = ActionModel(id: '', action: actionName);

    if (index >= 0) {
      final currentActions = List<ActionModel>.from(
        _permissions[index].actions,
      );

      if (enable) {
        if (!currentActions.any((a) => a.action == actionName)) {
          currentActions.add(actionObj);
        }
      } else {
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

    context.read<RolesCubit>().updateRole(
      roleId: widget.roleId, // Assuming updateRole requires ID
      name: widget.roleName, // Or _nameController.text if you allow name editing here
      status: status ? 'active' : 'inactive',
      permissions: filteredPermissions,
    );
  }
}