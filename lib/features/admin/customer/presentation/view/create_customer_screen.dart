import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CreateCustomerScreen extends StatefulWidget {
  const CreateCustomerScreen({super.key});

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _customerGroupIdController = TextEditingController();
  final _amountDueController = TextEditingController();
  final _pointsController = TextEditingController();
  bool _isDue = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  color: AppColors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        CustomTextField(
          controller: controller,
          labelText: '',
          hintText: hint,
          hasBoxDecoration: false,
          hasBorder: true,
          prefixIconColor: AppColors.darkGray.withOpacity(0.7),
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String title,
    required String description,
    required bool value,
    required void Function(bool) onChanged,
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
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 16),
            vertical: ResponsiveUI.padding(context, 12),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 8),
            ),
            border: Border.all(color: AppColors.lightGray, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    color: AppColors.darkGray.withOpacity(0.8),
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primaryBlue,
                activeTrackColor: AppColors.primaryBlue.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _validateAndSubmit() {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_customer_name.tr(),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_phone_number.tr(),
      );
      return;
    }

    if (_countryController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_country.tr(),
      );
      return;
    }

    if (_cityController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_city.tr(),
      );
      return;
    }

    // Validate email format
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_isValidEmail(email)) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_valid_email.tr(),
      );
      return;
    }

    // Parse amount due
    double amountDue = 0.0;
    if (_amountDueController.text.trim().isNotEmpty) {
      final parsedAmount = double.tryParse(_amountDueController.text.trim());
      if (parsedAmount == null || parsedAmount < 0) {
        CustomSnackbar.showWarning(
          context,
          LocaleKeys.warning_enter_valid_amount.tr(),
        );
        return;
      }
      amountDue = parsedAmount;
    }

    // Parse points
    int points = 0;
    if (_pointsController.text.trim().isNotEmpty) {
      final parsedPoints = int.tryParse(_pointsController.text.trim());
      if (parsedPoints == null || parsedPoints < 0) {
        CustomSnackbar.showWarning(
          context,
          LocaleKeys.warning_enter_valid_points.tr(),
        );
        return;
      }
      points = parsedPoints;
    }

   context.read<CustomerCubit>().addCustomer(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        customerGroupId: _customerGroupIdController.text.trim().isNotEmpty
            ? _customerGroupIdController.text.trim()
            : null,
        isDue: _isDue,
        amountDue: amountDue,
        totalPointsEarned: points,
      );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is CreateCustomerSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdateCustomerSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreateCustomerError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is UpdateCustomerError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isCreating = state is CreateCustomerLoading;
        final isUpdating = state is UpdateCustomerLoading;
        final isLoading = isCreating || isUpdating;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(
            context,
            title: LocaleKeys.new_customer.tr(),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Information Section
                      Text(
                        LocaleKeys.customer_information.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 8)),

                      _buildTextField(
                        controller: _nameController,
                        title: LocaleKeys.customer_name.tr(),
                        hint: LocaleKeys.enter_customer_name.tr(),
                        required: true,
                      ),

                      _buildTextField(
                        controller: _emailController,
                        title: LocaleKeys.email.tr(),
                        hint: LocaleKeys.enter_email.tr(),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      _buildTextField(
                        controller: _phoneController,
                        title: LocaleKeys.phone_number.tr(),
                        hint: LocaleKeys.enter_phone_number.tr(),
                        keyboardType: TextInputType.phone,
                        required: true,
                      ),

                      _buildTextField(
                        controller: _addressController,
                        title: LocaleKeys.address.tr(),
                        hint: LocaleKeys.enter_address.tr(),
                        maxLines: 2,
                      ),

                      _buildTextField(
                        controller: _countryController,
                        title: LocaleKeys.country.tr(),
                        hint: LocaleKeys.enter_country.tr(),
                        required: true,
                      ),

                      _buildTextField(
                        controller: _cityController,
                        title: LocaleKeys.city.tr(),
                        hint: LocaleKeys.enter_city.tr(),
                        required: true,
                      ),

                      _buildTextField(
                        controller: _customerGroupIdController,
                        title: LocaleKeys.customer_group.tr(),
                        hint: LocaleKeys.enter_customer_group_id.tr(),
                      ),

                      SizedBox(height: ResponsiveUI.spacing(context, 24)),

                      // Financial Information Section
                      Text(
                        LocaleKeys.financial_information.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 8)),

                      _buildSwitchField(
                        title: LocaleKeys.due_status.tr(),
                        description: LocaleKeys.customer_has_due_amount.tr(),
                        value: _isDue,
                        onChanged: (value) {
                          setState(() {
                            _isDue = value;
                          });
                        },
                      ),

                      if (_isDue)
                        _buildTextField(
                          controller: _amountDueController,
                          title: LocaleKeys.amount_due.tr(),
                          hint: LocaleKeys.enter_amount_due.tr(),
                          keyboardType: TextInputType.number,
                        ),

                      _buildTextField(
                        controller: _pointsController,
                        title: LocaleKeys.total_points.tr(),
                        hint: LocaleKeys.enter_total_points.tr(),
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(height: ResponsiveUI.spacing(context, 24)),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveUI.value(context, 48),
                        child: CustomElevatedButton(
                          onPressed: isLoading ? null : _validateAndSubmit,
                          text: isLoading
                              ?  LocaleKeys.saving_customer.tr()
                              :  LocaleKeys.save_customer.tr(),
                          isLoading: isLoading,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 32)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _customerGroupIdController.dispose();
    _amountDueController.dispose();
    _pointsController.dispose();
    super.dispose();
  }
}