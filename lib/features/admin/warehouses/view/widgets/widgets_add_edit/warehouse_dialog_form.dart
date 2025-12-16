import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../../../../../generated/locale_keys.g.dart';

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
                    label: LocaleKeys.warehouse_name.tr(),
                    icon: Icons.warehouse_outlined,
                    hint: LocaleKeys.enter_warehouse_name.tr(),
                    validator: (v) =>
                        LoginValidator.validateRequired(
                          v,
                          LocaleKeys.warehouse_name_required.tr(),
                        ),
                  ),
                  SizedBox(height: spacing20),
                  buildTextField(
                    context,
                    controller: addressController,
                    label: LocaleKeys.address.tr(),
                    icon: Icons.location_on_outlined,
                    hint: LocaleKeys.enter_warehouse_address.tr(),
                    maxLines: 2,
                    validator: (v) =>
                        LoginValidator.validateRequired(
                          v,
                          LocaleKeys.address_required.tr(),
                        ),
                  ),
                  SizedBox(height: spacing20),
                  buildTextField(
                    context,
                    controller: phoneController,
                    label: LocaleKeys.phone_number.tr(),
                    icon: Icons.phone_outlined,
                    hint: LocaleKeys.enter_phone_number.tr(),
                    keyboardType: TextInputType.phone,
                    validator: LoginValidator.validatePhone,
                  ),
                  SizedBox(height: spacing20),
                  buildTextField(
                    context,
                    controller: emailController,
                    label: LocaleKeys.email_address.tr(),
                    icon: Icons.email_outlined,
                    hint: LocaleKeys.enter_email_address.tr(),
                    keyboardType: TextInputType.emailAddress,
                    validator: LoginValidator.validateEmail,
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) buildLoadingOverlay(context, 45),
        ],
      ),
    );
  }
}
