import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/utils/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'dart:io';
import '../../model/supplier_model.dart';

class SupplierDialogForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController companyNameController;
  final String? selectedCountryId;
  final String? selectedCityId;
  final List<Country>? countries;
  final List<City>? cities;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;
  final bool isLoading;
  final XFile? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final String? existingImageUrl;

  const SupplierDialogForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.companyNameController,
    required this.selectedCountryId,
    required this.selectedCityId,
    required this.countries,
    required this.cities,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.isLoading,
    required this.selectedImage,
    required this.onPickImage,
    required this.onClearImage,
    this.existingImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final padding24 = ResponsiveUI.padding(context, 24);
    final spacing20 = ResponsiveUI.spacing(context, 20);

    // Filter cities based on selected country
    List<City> filteredCities = [];
    if (selectedCountryId != null && cities != null) {
      filteredCities = cities!
          .where((city) => city.country == selectedCountryId)
          .toList();
    }

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
                  _buildImagePicker(context),
                  SizedBox(height: spacing20),
                  _buildTextField(
                    context,
                    controller: usernameController,
                    label: LocaleKeys.supplier_name.tr(),
                    icon: Icons.person_outline,
                    hint: LocaleKeys.enter_supplier_name.tr(),
                    validator: (v) => LoginValidator.validateRequired(v, LocaleKeys.supplier_name.tr()),
                  ),
                  SizedBox(height: spacing20),
                  _buildTextField(
                    context,
                    controller: companyNameController,
                    label: LocaleKeys.company_name.tr(),
                    icon: Icons.business_outlined,
                    hint: LocaleKeys.enter_company_name.tr(),
                    validator: (v) => LoginValidator.validateRequired(v, LocaleKeys.company_name.tr()),
                  ),
                  SizedBox(height: spacing20),
                  _buildTextField(
                    context,
                    controller: emailController,
                    label: LocaleKeys.email_address.tr(),
                    icon: Icons.email_outlined,
                    hint: LocaleKeys.enter_email_address.tr(),
                    keyboardType: TextInputType.emailAddress,
                    validator: LoginValidator.validateEmail,
                  ),
                  SizedBox(height: spacing20),
                  _buildTextField(
                    context,
                    controller: phoneController,
                    label: LocaleKeys.phone_number.tr(),
                    icon: Icons.phone_outlined,
                    hint: LocaleKeys.enter_phone_number.tr(),
                    keyboardType: TextInputType.phone,
                    validator: LoginValidator.validatePhone,
                  ),
                  SizedBox(height: spacing20),
                  _buildTextField(
                    context,
                    controller: addressController,
                    label: LocaleKeys.address.tr(),
                    icon: Icons.location_on_outlined,
                    hint: LocaleKeys.enter_email_address.tr(),
                    maxLines: 2,
                    validator: (v) => LoginValidator.validateRequired(v, 'Address'),
                  ),
                  SizedBox(height: spacing20),
                  _buildDropdownField(
                    context,
                    label: LocaleKeys.country.tr(),
                    icon: Icons.public,
                    hint: LocaleKeys.select_country.tr(),
                    value: selectedCountryId,
                    items: countries ?? [],
                    onChanged: onCountryChanged,
                    itemBuilder: (country) => country.name ?? '',
                    valueBuilder: (country) => country.id ?? '',
                  ),
                  SizedBox(height: spacing20),
                  _buildDropdownField(
                    context,
                    label: LocaleKeys.city.tr(),
                    icon: Icons.location_city,
                    hint: LocaleKeys.select_city.tr(),
                    value: selectedCityId,
                    items: filteredCities,
                    onChanged: onCityChanged,
                    itemBuilder: (city) => city.name ?? '',
                    valueBuilder: (city) => city.id ?? '',
                    isDisabled: selectedCountryId == null,
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

  Widget _buildImagePicker(BuildContext context) {
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final iconSize40 = ResponsiveUI.iconSize(context, 40);
    final fontSize14 = ResponsiveUI.fontSize(context, 14);
    final height120 = ResponsiveUI.value(context, 120);
    final spacing8 = ResponsiveUI.spacing(context, 8);
    final padding8 = ResponsiveUI.padding(context, 8);
    final iconSize24 = ResponsiveUI.iconSize(context, 24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.supplier_image.tr(),
          style: TextStyle(
            fontSize: fontSize14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: spacing8),
        if (selectedImage != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: double.infinity,
                height: height120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius12),
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius12 - 2),
                  child: Image.file(
                    File(selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onClearImage,
                  child: Container(
                    padding: EdgeInsets.all(padding8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: iconSize24,
                    ),
                  ),
                ),
              ),
            ],
          )
        else if (existingImageUrl != null && existingImageUrl!.isNotEmpty)
          Container(
            width: double.infinity,
            height: height120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius12 - 2),
              child: Image.network(
                existingImageUrl!,
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              width: double.infinity,
              height: height120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: iconSize40,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(height: spacing8),
                  Text(
                    LocaleKeys.tap_to_select_image.tr(),
                    style: TextStyle(
                      fontSize: fontSize14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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

  Widget _buildDropdownField<T>(
      BuildContext context, {
        required String label,
        required IconData icon,
        required String hint,
        required String? value,
        required List<T> items,
        required ValueChanged<String?> onChanged,
        required String Function(T) itemBuilder,
        required String Function(T) valueBuilder,
        bool isDisabled = false,
      }) {
    final fontSizeLabel = ResponsiveUI.fontSize(context, 14);
    final spacing8 = ResponsiveUI.spacing(context, 8);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final value3 = ResponsiveUI.value(context, 3);
    final iconSize22 = ResponsiveUI.iconSize(context, 22);
    final padding16 = ResponsiveUI.padding(context, 16);
    final padding14 = ResponsiveUI.padding(context, 14);
    final fontSizeHint = ResponsiveUI.fontSize(context, 15);
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
        DropdownButtonFormField<String>(
          value: value,
          disabledHint: isDisabled
              ? Text(
            label == LocaleKeys.city.tr() ? LocaleKeys.select_country_first.tr() : LocaleKeys.no_options_available.tr(),
            style: TextStyle(color: Colors.grey[400], fontSize: fontSizeHint),
          )
              : null,
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
            filled: true,
            fillColor: isDisabled ? Colors.grey[100] : Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: padding16, vertical: padding14),
          ),
          items: items.isEmpty
              ? []
              : items.map((item) {
            return DropdownMenuItem<String>(
              value: valueBuilder(item),
              child: Text(
                itemBuilder(item),
                style: TextStyle(fontSize: fontSizeHint),
              ),
            );
          }).toList(),
          onChanged: isDisabled || items.isEmpty ? null : onChanged,
          validator: (v) => v == null || v.isEmpty ? '$label is required' : null,
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final borderRadius20 = ResponsiveUI.borderRadius(context, 20);
    final padding30 = ResponsiveUI.padding(context, 30);
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
                LocaleKeys.processing.tr(),
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