import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:systego/features/admin/cashier/model/cashirer_model.dart';
import 'package:systego/features/admin/cashier/presentation/widgets/animated_cashier_card.dart';
import 'package:systego/features/admin/cashier/presentation/widgets/cashier_form_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class CashierList extends StatelessWidget {
  final List<CashierModel> cashiers;
  const CashierList({super.key, required this.cashiers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: cashiers.length,
      itemBuilder: (context, index) {
        return AnimatedCashierCard(
          cashier: cashiers[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, cashiers[index]),
          onEdit: () => _showEditDialog(context, cashiers[index]),
          onTap: () => _showCashierDetails(context, cashiers[index]), // Fixed: Changed to VoidCallback
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, CashierModel cashier) {
    showDialog(
      context: context,
      builder: (context) => CashierFormDialog(cashier: cashier),
    );
  }

  void _showDeleteDialog(BuildContext context, CashierModel cashier) {
    if (cashier.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_coupon_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_coupon.tr(),
        message:
            '${LocaleKeys.delete_coupon_message.tr()} \n"${cashier.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CashierCubit>().deleteCashier(cashier.id);
        },
      ),
    );
  }

  void _showCashierDetails(BuildContext context, CashierModel cashier) {
    showDialog(
      context: context,
      builder: (context) => _buildCustomerDetailsDialog(context, cashier),
    );
  }

  // Added missing helper widget
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
          size: 20,
          color: Colors.grey[600],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerDetailsDialog(BuildContext context, CashierModel cashier) {
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
              // Header with name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cashier.name,
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
                      color: cashier.status
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      cashier.status
                          ? LocaleKeys.active.tr()
                          : LocaleKeys.inactive.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        fontWeight: FontWeight.bold,
                        color: cashier.status ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Arabic Name
              _buildInfoRow(
                icon: Icons.language,
                label: LocaleKeys.arabic_name.tr(),
                value: 
                // cashier.arName.isNotEmpty 
                    // ? 
                    cashier.arName 
                    // : LocaleKeys.no_arabic_name.tr(),
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Warehouse Information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.warehouse.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 8)),
                  Container(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.store, size: 20, color: Colors.blue),
                        SizedBox(width: ResponsiveUI.spacing(context, 8)),
                        Expanded(
                          child: Text(
                            cashier.warehouse.name,
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Cashier Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.status.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          cashier.status 
                              ? LocaleKeys.active.tr() 
                              : LocaleKeys.inactive.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: cashier.status ? Colors.green : Colors.red,
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
                          LocaleKeys.cashier_active.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          cashier.cashierActive 
                              ? LocaleKeys.yes.tr() 
                              : LocaleKeys.no.tr(),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: cashier.cashierActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Users associated with this cashier
              if (cashier.users.isNotEmpty) ...[
                Text(
                  LocaleKeys.users.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                ...cashier.users.map((user) {
                  return Container(
                    margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 8),
                                vertical: ResponsiveUI.padding(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user.role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user.role,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 12),
                                  color: _getRoleColor(user.role),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 8),
                                vertical: ResponsiveUI.padding(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: user.status == 'active' 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user.status,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 12),
                                  color: user.status == 'active' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
              ],

              // Bank Accounts
              if (cashier.bankAccounts.isNotEmpty) ...[
                Text(
                  LocaleKeys.financial_accounts.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                ...cashier.bankAccounts.map((account) {
                  return Container(
                    margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                account.name,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 8),
                                vertical: ResponsiveUI.padding(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: account.status 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                account.status 
                                    ? LocaleKeys.active.tr() 
                                    : LocaleKeys.inactive.tr(),
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 12),
                                  color: account.status ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.balance.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${account.balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                color: account.balance >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.in_pos.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              account.inPOS ? LocaleKeys.yes.tr() : LocaleKeys.no.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                color: account.inPOS ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
              ],

             
              SizedBox(height: ResponsiveUI.spacing(context, 14)),

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

  // Helper function to get role color
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'cashier':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}