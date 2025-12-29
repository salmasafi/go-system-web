import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_error/custom_error_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/features/admin/customer/model/customer_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class EditCustomerScreen extends StatefulWidget {
  final CustomerModel customer;

  const EditCustomerScreen({super.key, required this.customer});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _customerGroupIdController;
  
  bool _isDue = false;
  double _amountDue = 0.0;
  int _totalPointsEarned = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _emailController = TextEditingController(text: widget.customer.email);
    _phoneController = TextEditingController(text: widget.customer.phoneNumber);
    _addressController = TextEditingController(text: widget.customer.address);
    _countryController = TextEditingController(text: widget.customer.country);
    _cityController = TextEditingController(text: widget.customer.city);
    _customerGroupIdController = TextEditingController(
      text: widget.customer.customerGroupId ?? ''
    );
    _isDue = widget.customer.isDue;
    _amountDue = widget.customer.amountDue;
    _totalPointsEarned = widget.customer.totalPointsEarned;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
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
            if (isRequired)
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
              Text(
                value 
                  ? LocaleKeys.yes.tr() 
                  : LocaleKeys.no.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  color: value ? AppColors.successGreen : AppColors.red,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primaryBlue,
                inactiveTrackColor: AppColors.lightGray,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required double value,
    required String title,
    required String hint,
    required void Function(double) onChanged,
    bool isInteger = false,
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
            vertical: ResponsiveUI.padding(context, 14),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 8),
            ),
            border: Border.all(color: AppColors.lightGray, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                    text: isInteger ? value.toInt().toString() : value.toString(),
                  ),
                  onChanged: (text) {
                    final parsedValue = isInteger 
                      ? int.tryParse(text)?.toDouble() ?? 0.0
                      : double.tryParse(text) ?? 0.0;
                    onChanged(parsedValue);
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
                  decoration: InputDecoration.collapsed(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: AppColors.darkGray.withOpacity(0.5),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.darkGray,
                  ),
                ),
              ),
              if (isInteger)
                Text(
                  LocaleKeys.points.tr(),
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: ResponsiveUI.fontSize(context, 12),
                  ),
                )
              // else
              //   Text(
              //     widget.customer.country == 'USA' ? '\$' : '€',
              //     style: TextStyle(
              //       color: AppColors.primaryBlue,
              //       fontSize: ResponsiveUI.fontSize(context, 12),
              //     ),
              //   ),
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
    if (email.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_valid_email.tr(),
      );
      return;
    }

    // Call update customer
    context.read<CustomerCubit>().updateCustomer(
      customerId: widget.customer.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      customerGroupId: _customerGroupIdController.text.trim().isNotEmpty 
          ? _customerGroupIdController.text.trim() 
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is UpdateCustomerSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdateCustomerError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is UpdateCustomerSuccess) {
          return Scaffold(
            backgroundColor: AppColors.lightBlueBackground,
            appBar: appBarWithActions(
              context,
              title: LocaleKeys.edit_customer.tr(),
            ),
            body: CustomErrorState(
              message: state.message,
              onRetry: _validateAndSubmit,
            ),
          );
        }

        final isLoading = state is UpdateCustomerLoading;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(
            context,
            title: LocaleKeys.edit_customer.tr(),
            // actions: [
            //   if (widget.customer.isDue)
            //     IconButton(
            //       icon: Icon(
            //         Icons.money_off,
            //         color: AppColors.red,
            //         size: ResponsiveUI.iconSize(context, 24),
            //       ),
            //       onPressed: () {
            //         CustomSnackbar.showInfo(
            //           context,
            //           LocaleKeys.customer_has_due_amount.tr(
            //             namedArgs: {'amount': widget.customer.amountDue.toString()}
            //           ),
            //         );
            //       },
            //     ),
            // ],
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
                      // Basic Information Section
                      Text(
                        LocaleKeys.basic_information.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      _buildTextField(
                        controller: _nameController,
                        title: LocaleKeys.customer_name.tr(),
                        hint: LocaleKeys.enter_customer_name.tr(),
                        isRequired: true,
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
                        isRequired: true,
                      ),

                      // Address Information Section
                      SizedBox(height: ResponsiveUI.spacing(context, 24)),
                      Text(
                        LocaleKeys.address_information.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
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
                        isRequired: true,
                      ),

                      _buildTextField(
                        controller: _cityController,
                        title: LocaleKeys.city.tr(),
                        hint: LocaleKeys.enter_city.tr(),
                        isRequired: true,
                      ),

                      // Customer Group Section
                      SizedBox(height: ResponsiveUI.spacing(context, 24)),
                      Text(
                        LocaleKeys.customer_group.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _buildTextField(
                        controller: _customerGroupIdController,
                        title: LocaleKeys.customer_group_id.tr(),
                        hint: LocaleKeys.enter_customer_group_id.tr(),
                      ),

                      // Financial Information Section
                      SizedBox(height: ResponsiveUI.spacing(context, 24)),
                      Text(
                        LocaleKeys.financial_information.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _buildSwitchField(
                        title: LocaleKeys.has_due_amount.tr(),
                        value: _isDue,
                        onChanged: (value) {
                          setState(() {
                            _isDue = value;
                          });
                        },
                      ),

                      if (_isDue)
                        _buildNumberField(
                          value: _amountDue,
                          title: LocaleKeys.due_amount.tr(),
                          hint: LocaleKeys.enter_due_amount.tr(),
                          onChanged: (value) {
                            setState(() {
                              _amountDue = value;
                            });
                          },
                        ),

                      _buildNumberField(
                        value: _totalPointsEarned.toDouble(),
                        title: LocaleKeys.total_points_earned.tr(),
                        hint: LocaleKeys.enter_points.tr(),
                        onChanged: (value) {
                          setState(() {
                            _totalPointsEarned = value.toInt();
                          });
                        },
                        isInteger: true,
                      ),                    

                      // Submit Button
                      SizedBox(height: ResponsiveUI.spacing(context, 32)),
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveUI.value(context, 48),
                        child: CustomElevatedButton(
                          onPressed: isLoading ? null : _validateAndSubmit,
                          text: isLoading
                              ? LocaleKeys.updating_customer.tr()
                              : LocaleKeys.update_customer.tr(),
                          isLoading: isLoading,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 32)),
                    ],
                  ),
                ),
              ),

              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
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
    super.dispose();
  }
}