import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/permission/cubit/permission_cubit.dart';
import 'package:systego/features/admin/permission/model/permission_model.dart';

class EditPermissionBottomSheet extends StatefulWidget {
  final PermissionModel permission;

  const EditPermissionBottomSheet({super.key, required this.permission});

  @override
  State<EditPermissionBottomSheet> createState() =>
      _EditPermissionBottomSheetState();
}

class _EditPermissionBottomSheetState extends State<EditPermissionBottomSheet> {
  late final TextEditingController _nameController;

  final List<String> roleTypes = ["brands", "categories", "products"];
  final List<String> actionsList = ["add", "update", "delete", "get"];

  late Map<String, Set<String>> selectedActions;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.permission.name);

    selectedActions = {
      for (var role in roleTypes) role: {},
    };

    for (var role in widget.permission.roles) {
      selectedActions[role.name] = role.actions.toSet();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, "Please enter permission name");
      return;
    }

    final updatedRoles = roleTypes.map((role) {
      return RoleModel(
        name: role,
        actions: selectedActions[role]!.toList(),
      );
    }).toList();

    context.read<PermissionCubit>().updatePermission(
          id: widget.permission.id,
          name: _nameController.text.trim(),
          roles: updatedRoles,
        );
  }

  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        CustomTextField(
          controller: controller,
          labelText: '',
          hintText: hint,
          hasBorder: true,
          hasBoxDecoration: false,
          prefixIconColor: AppColors.darkGray.withOpacity(0.7),
        ),
      ],
    );
  }

  Widget _buildRoleActions(String role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          "Role: ${role[0].toUpperCase()}${role.substring(1)}",
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: actionsList.map((action) {
            final isChecked = selectedActions[role]!.contains(action);
            return FilterChip(
              selected: isChecked,
              label: Text(action),
              onSelected: (_) {
                setState(() {
                  if (isChecked) {
                    selectedActions[role]!.remove(action);
                  } else {
                    selectedActions[role]!.add(action);
                  }
                });
              },
              selectedColor: AppColors.primaryBlue.withOpacity(0.15),
              checkmarkColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;

    return BlocConsumer<PermissionCubit, PermissionState>(
      listener: (context, state) {
        if (state is UpdatePermissionSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdatePermissionError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdatePermissionLoading;

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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: ResponsiveUI.value(context, 40),
                        height: ResponsiveUI.value(context, 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                            ResponsiveUI.borderRadius(context, 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 12)),
                    Text(
                      "Edit Permission",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// Permission Name
                    _buildTextField(
                      title: "Permission Name",
                      hint: "Enter permission name",
                      controller: _nameController,
                    ),

                    /// Roles & Actions
                    ...roleTypes.map((role) => _buildRoleActions(role)),

                    SizedBox(height: ResponsiveUI.spacing(context, 24)),

                    SizedBox(
                      height: ResponsiveUI.value(context, 48),
                      child: CustomElevatedButton(
                        onPressed: isLoading ? null : _submitUpdate,
                        text: isLoading ? "Updating Permission..." : "Update Permission",
                        isLoading: isLoading,
                      ),
                    ),

                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
