import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/features/pos/customer/cubit/pos_customer_cubit.dart';

class CustomerCreateDialog extends StatefulWidget {
  const CustomerCreateDialog({super.key});

  @override
  State<CustomerCreateDialog> createState() => _CustomerCreateDialogState();
}

class _CustomerCreateDialogState extends State<CustomerCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _errorMessage = null);
    context.read<PosCustomerCubit>().createCustomer(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PosCustomerCubit, PosCustomerState>(
      listener: (context, state) {
        if (state is PosCustomerCreateSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: ResponsiveUI.value(context, 8)),
                  Expanded(
                    child: Text(
                      'Customer "${state.newCustomer.name}" created successfully',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is PosCustomerCreateError) {
          setState(() => _errorMessage = state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: ResponsiveUI.value(context, 8)),
                  Expanded(
                    child: Text(
                      state.message,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 20),
          vertical: ResponsiveUI.padding(context, 40),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: ResponsiveUI.screenHeight(context) * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTextField(
                          context,
                          controller: _nameCtrl,
                          label: 'Name *',
                          icon: Icons.person_outline,
                          hint: 'Enter customer name',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        buildTextField(
                          context,
                          controller: _phoneCtrl,
                          label: 'Phone Number *',
                          icon: Icons.phone_outlined,
                          hint: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        buildTextField(
                          context,
                          controller: _emailCtrl,
                          label: 'Email (optional)',
                          icon: Icons.email_outlined,
                          hint: 'Enter email address',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        buildTextField(
                          context,
                          controller: _addressCtrl,
                          label: 'Address (optional)',
                          icon: Icons.location_on_outlined,
                          hint: 'Enter address',
                        ),
                        if (_errorMessage != null) ...[
                          SizedBox(height: ResponsiveUI.spacing(context, 12)),
                          _buildErrorBanner(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.person_add_outlined, color: AppColors.white, size: ResponsiveUI.iconSize(context, 26)),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Text(
              'New Customer',
              style: TextStyle(
                color: AppColors.white,
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.red, size: ResponsiveUI.iconSize(context, 18)),
          SizedBox(width: ResponsiveUI.value(context, 8)),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: AppColors.red, fontSize: ResponsiveUI.fontSize(context, 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return BlocBuilder<PosCustomerCubit, PosCustomerState>(
      builder: (context, state) {
        final isLoading = state is PosCustomerCreating;
        return Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUI.padding(context, 14),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? SizedBox(
                          width: ResponsiveUI.value(context, 18),
                          height: ResponsiveUI.value(context, 18),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Icon(Icons.check_circle_outline),
                  label: Text(isLoading ? 'Creating...' : 'Create Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUI.padding(context, 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
