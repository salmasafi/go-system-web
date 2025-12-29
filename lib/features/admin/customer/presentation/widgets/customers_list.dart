import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:systego/features/admin/customer/model/customer_model.dart';
import 'package:systego/features/admin/customer/presentation/view/edit_customer_screen.dart';
import 'package:systego/features/admin/customer/presentation/widgets/animated_customer_card.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class CustomersList extends StatefulWidget {
  final List<CustomerModel> customers;

  const CustomersList({super.key, required this.customers});

  @override
  State<CustomersList> createState() => _CustomersListState();
}

class _CustomersListState extends State<CustomersList> {
  @override
  Widget build(BuildContext context) {
    if (widget.customers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
        bottom: ResponsiveUI.padding(context, 80), // Extra padding for FAB
      ),
      itemCount: widget.customers.length,
      itemBuilder: (context, index) {
        final customer = widget.customers[index];

        return AnimatedCustomerCard(
          customer: customer,
          index: index,
          onDelete: () => _showDeleteDialog(context, customer),
          onEdit: () => _navigateToEditScreen(context, customer),
          onTap: () => _showCustomerDetails(context, customer),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: ResponsiveUI.iconSize(context, 64),
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Text(
              LocaleKeys.no_customers_found.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            Text(
              LocaleKeys.create_first_customer.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, CustomerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(customer: customer),
      ),
    ).then((value) {
      // Refresh data when returning from edit screen
      if (value == true) {
        context.read<CustomerCubit>().getAllCustomers();
      }
    });
  }

  void _showCustomerDetails(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => _buildCustomerDetailsDialog(customer),
    );
  }

  Widget _buildCustomerDetailsDialog(CustomerModel customer) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and due status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 12),
                      vertical: ResponsiveUI.padding(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: customer.isDue
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      customer.isDue
                          ? LocaleKeys.has_due.tr()
                          : LocaleKeys.no_due.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        fontWeight: FontWeight.bold,
                        color: customer.isDue ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Contact Information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.email,
                    label: LocaleKeys.email.tr(),
                    value: customer.email.isNotEmpty 
                        ? customer.email 
                        : LocaleKeys.no_email.tr(),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: LocaleKeys.phone.tr(),
                    value: customer.phoneNumber,
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Address Information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.address.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 4)),
                  Text(
                    customer.address.isNotEmpty 
                        ? customer.address 
                        : LocaleKeys.no_address.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 8)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.country.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 12),
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              customer.country,
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.city.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 12),
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              customer.city,
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Financial Information
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.amount_due.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '\$${customer.amountDue.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: customer.isDue ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.total_points.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          customer.totalPointsEarned.toString(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Customer Group
              if (customer.customerGroupId != null && customer.customerGroupId!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.group,
                      label: LocaleKeys.customer_group.tr(),
                      value: customer.customerGroupId!,
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  ],
                ),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: ResponsiveUI.iconSize(context, 16),
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Text(
                              LocaleKeys.created_at.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          _formatDate(customer.createdAt),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: ResponsiveUI.spacing(context, 20)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: ResponsiveUI.iconSize(context, 16),
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Text(
                              LocaleKeys.updated_at.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          _formatDate(customer.updatedAt),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUI.padding(context, 14),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.close.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: ResponsiveUI.iconSize(context, 18),
          color: Colors.grey[600],
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, CustomerModel customer) {
    if (customer.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_customer_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_customer_title.tr(),
        message: '${LocaleKeys.delete_customer_message.tr()}\n"${customer.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CustomerCubit>().deleteCustomer(customer.id);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}