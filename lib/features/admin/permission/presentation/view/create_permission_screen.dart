import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_error/custom_error_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/permission/cubit/permission_cubit.dart';
import 'package:systego/features/admin/permission/model/permission_model.dart';

class CreatePermissionScreen extends StatefulWidget {
  const CreatePermissionScreen({super.key});

  @override
  State<CreatePermissionScreen> createState() => _CreatePermissionScreenState();
}

class _CreatePermissionScreenState extends State<CreatePermissionScreen> {
  final TextEditingController _nameController = TextEditingController();

  final List<String> roleTypes = ["brands", "categories", "products"];
  final List<String> actionsList = ["add", "update", "delete", "get"];

  late Map<String, Set<String>> selectedActions;

  @override
  void initState() {
    super.initState();
    selectedActions = {
      for (var role in roleTypes) role: {},
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // void _validateAndSubmit() {
  //   if (_nameController.text.trim().isEmpty) {
  //     CustomSnackbar.showWarning(context, "Please enter permission name");
  //     return;
  //   }

  //   final roles = roleTypes.map((role) {
  //     return RoleModel(
  //       name: role,
  //       actions: selectedActions[role]!.toList(),
  //     );
  //   }).toList();

  //   context.read<PermissionCubit>().createPermission(
  //         name: _nameController.text.trim(),
  //         roles: roles,
  //       );
  // }
void _validateAndSubmit() {
  if (_nameController.text.trim().isEmpty) {
    CustomSnackbar.showWarning(context, "Please enter permission name");
    return;
  }

  // Keep only roles with selected actions and convert to RoleModel
  final roles = roleTypes
      .where((role) => selectedActions[role]!.isNotEmpty)
      .map((role) => RoleModel(
            name: role, // exact role name
            actions: selectedActions[role]!.toList(),
          ))
      .toList();

  if (roles.isEmpty) {
    CustomSnackbar.showWarning(context, "Please select at least one action for a role");
    return;
  }

  // Call cubit / API
  context.read<PermissionCubit>().createPermission(
        name: _nameController.text.trim(),
        roles: roles,
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
    return BlocConsumer<PermissionCubit, PermissionState>(
      listener: (context, state) {
        if (state is CreatePermissionSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreatePermissionError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is CreatePermissionSuccess) {
          return Scaffold(
            backgroundColor: AppColors.lightBlueBackground,
            appBar: appBarWithActions(context, title: "New Permission"),
            body: CustomErrorState(
              message: state.message,
              onRetry: _validateAndSubmit,
            ),
          );
        }

        final isLoading = state is CreatePermissionLoading;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: "New Permission"),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    title: "Permission Name",
                    hint: "Enter permission name",
                    controller: _nameController,
                  ),

                  // Roles & Actions
                  ...roleTypes.map((role) => _buildRoleActions(role)),

                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                  SizedBox(
                    height: ResponsiveUI.value(context, 48),
                    child: CustomElevatedButton(
                      onPressed: isLoading ? null : _validateAndSubmit,
                      text: isLoading ? "Creating Permission..." : "Create Permission",
                      isLoading: isLoading,
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
