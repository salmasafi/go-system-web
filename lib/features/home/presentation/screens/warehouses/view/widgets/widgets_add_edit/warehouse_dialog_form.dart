import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../../../../core/utils/validators.dart';
import '../../../../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../../../../core/widgets/custom_textfield/build_text_field.dart';

class WarehouseDialogForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool isLoading;

  const WarehouseDialogForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final padding24 = ResponsiveUI.padding(context, 24);
    final spacing20 = ResponsiveUI.spacing(context, 20);

    return Flexible(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(padding24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTextField(
                    context,
                    controller: nameController,
                    label: 'Warehouse Name',
                    icon: Icons.warehouse_outlined,
                    hint: 'Enter warehouse name',
                    validator: (v) =>
                        LoginValidator.validateRequired(v, 'Warehouse name'),
                  ),
                  SizedBox(height: spacing20),
                  buildTextField(
                    context,
                    controller: addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    hint: 'Enter warehouse address',
                    maxLines: 2,
                    validator: (v) =>
                        LoginValidator.validateRequired(v, 'Address'),
                  ),
                  SizedBox(height: spacing20),
                  buildTextField(
                    context,
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    validator: LoginValidator.validatePhone,
                  ),
                  SizedBox(height: spacing20),
                  buildTextField(
                    context,
                    controller: emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    hint: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: LoginValidator.validateEmail,
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) buildLoadingOverlay(context),
        ],
      ),
    );
  }
}
