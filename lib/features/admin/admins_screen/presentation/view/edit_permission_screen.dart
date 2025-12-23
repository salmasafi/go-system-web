import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/admins_screen/cubit/permissions_cubit.dart';
import 'package:systego/features/admin/admins_screen/model/permission_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class EditPermissionsBottomSheet extends StatefulWidget {
  final String userId;
  final String username;
  final String email;
  const EditPermissionsBottomSheet({
    super.key,
    required this.userId,
    required this.username,
    required this.email,
  });
  @override
  State<EditPermissionsBottomSheet> createState() =>
      _EditPermissionsBottomSheetState();
}

class _EditPermissionsBottomSheetState
    extends State<EditPermissionsBottomSheet> {
  List<ModulePermission> _permissions = [];
  final List<String> _allActions = ['View', 'Add', 'Edit', 'Delete'];
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
  @override
  void initState() {
    super.initState();
    // Fetch permissions when bottom sheet opens
    context.read<PermissionsCubit>().getUserPermissions(widget.userId);
  }
  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;
    return BlocConsumer<PermissionsCubit, PermissionsState>(
      listener: (context, state) {
        if (state is PermissionsLoaded) {
          setState(() {
            _permissions = List.from(state.permissions.permissions);
          });
        }
        if (state is PermissionsUpdateSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context);
        } else if (state is PermissionsUpdateError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is PermissionsLoading || state is PermissionsUpdating;
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
                 
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
                          child: Text(
                            widget.username.isNotEmpty
                                ? widget.username[0].toUpperCase()
                                : '?',
                            style: TextStyle(
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
                                widget.username,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGray,
                                ),
                              ),
                              Text(
                                widget.email,
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
                    child: Text(
                      LocaleKeys.edit_admin_permissions.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                 
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                 
                  // Permissions List
                  Expanded(
                    child: state is PermissionsError
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: ResponsiveUI.iconSize(context, 48),
                                  color: AppColors.red,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                Text(
                                  state.error,
                                  style: TextStyle(
                                    fontSize: ResponsiveUI.fontSize(context, 14),
                                    color: AppColors.darkGray,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                                CustomElevatedButton(
                                  onPressed: () => context
                                      .read<PermissionsCubit>()
                                      .getUserPermissions(widget.userId),
                                  text: LocaleKeys.retry.tr(),
                                ),
                              ],
                            ),
                          )
                        : _buildPermissionsList(),
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
          orElse: () => ModulePermission(module: module, actions: []),
        );
       
        return _buildPermissionItem(module, permission);
      },
    );
  }
  Widget _buildPermissionItem(String module, ModulePermission permission) {
    final hasAllActions = _allActions.every(permission.actions.contains);
   
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
              children: _allActions.map((action) {
                final isSelected = permission.actions.contains(action);
               
                return SizedBox(
                  width: ResponsiveUI.value(context, 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            _toggleAction(module, action, selected ?? false);
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Text(
                        action,
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
  void _toggleAction(String module, String action, bool enable) {
    final index = _permissions.indexWhere((p) => p.module == module);
    if (index >= 0) {
      final currentActions = List<String>.from(_permissions[index].actions);
      if (enable) {
        if (!currentActions.contains(action)) {
          currentActions.add(action);
        }
      } else {
        currentActions.remove(action);
      }
      _permissions[index] = _permissions[index].copyWith(
        actions: currentActions,
      );
    } else {
      if (enable) {
        _permissions.add(ModulePermission(
          module: module,
          actions: [action],
        ));
      }
    }
  }
  void _setModuleActions(String module, List<String> actions) {
    final index = _permissions.indexWhere((p) => p.module == module);
    if (index >= 0) {
      _permissions[index] = _permissions[index].copyWith(actions: actions);
    } else {
      _permissions.add(ModulePermission(module: module, actions: actions));
    }
  }
  void _submitUpdate() {
    // Filter out modules with no actions
    final filteredPermissions = _permissions
        .where((p) => p.actions.isNotEmpty)
        .toList();
   
    context.read<PermissionsCubit>().updatePermissions(
      userId: widget.userId,
      permissions: filteredPermissions,
    );
  }
}