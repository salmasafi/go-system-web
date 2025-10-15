import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../../../../core/utils/validators.dart';

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
                  _buildTextField(
                    context,
                    controller: nameController,
                    label: 'Warehouse Name',
                    icon: Icons.warehouse_outlined,
                    hint: 'Enter warehouse name',
                    validator: (v) => LoginValidator.validateRequired(v, 'Warehouse name'),
                  ),
                  SizedBox(height: spacing20),
                  _buildTextField(
                    context,
                    controller: addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    hint: 'Enter warehouse address',
                    maxLines: 2,
                    validator: (v) => LoginValidator.validateRequired(v, 'Address'),
                  ),
                  SizedBox(height: spacing20),
                  _buildTextField(
                    context,
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    validator: LoginValidator.validatePhone,
                  ),
                  SizedBox(height: spacing20),
                  _buildTextField(
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
          if (isLoading) _buildLoadingOverlay(context),
        ],
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required String hint,
        String? Function(String?)? validator,
        TextInputType? keyboardType,
        int maxLines = 1,
      }) {
    final fontSizeLabel = ResponsiveUI.fontSize(context, 14);
    final spacing8 = ResponsiveUI.spacing(context, 8);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final value3 = ResponsiveUI.value(context, 3);
    final iconSize22 = ResponsiveUI.iconSize(context, 22);
    final padding16 = ResponsiveUI.padding(context, 16);
    final padding14 = ResponsiveUI.padding(context, 14);
    final fontSizeHint = ResponsiveUI.fontSize(context, 15);
    final value15 = ResponsiveUI.value(context, 1.5);
    final value2 = ResponsiveUI.value(context, 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSizeLabel,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: spacing8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: fontSizeHint),
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: iconSize22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: value3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: value3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius12),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: value2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius12),
              borderSide: BorderSide(color: Colors.red, width: value15),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius12),
              borderSide: BorderSide(color: Colors.red, width: value2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: padding16, vertical: padding14),
          ),
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: fontSizeHint),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final borderRadius20 = ResponsiveUI.borderRadius(context, 20);
    final padding30 = ResponsiveUI.padding(context, 30);
    //final value20 = ResponsiveUI.value(context, 20);
    final strokeWidth3 = ResponsiveUI.value(context, 3);
    final spacing20 = ResponsiveUI.spacing(context, 20);
    final fontSize16 = ResponsiveUI.fontSize(context, 16);
    final value10 = ResponsiveUI.value(context, 0.1);
    final value20Blur = ResponsiveUI.value(context, 20);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(borderRadius24),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(padding30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(value10),
                blurRadius: value20Blur,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: strokeWidth3,
              ),
              SizedBox(height: spacing20),
              Text(
                'Processing...',
                style: TextStyle(
                  fontSize: fontSize16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}