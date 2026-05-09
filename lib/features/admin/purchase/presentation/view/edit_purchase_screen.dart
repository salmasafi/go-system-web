import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class EditPurchaseBottomSheet extends StatefulWidget {
  final Purchase purchase;

  const EditPurchaseBottomSheet({super.key, required this.purchase});

  @override
  State<EditPurchaseBottomSheet> createState() => _EditPurchaseBottomSheetState();
}

class _EditPurchaseBottomSheetState extends State<EditPurchaseBottomSheet> {
  late final TextEditingController _noteController;
  late final TextEditingController _shippingCostController;
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.purchase.note ?? '');
    _shippingCostController = TextEditingController(text: widget.purchase.shippingCost.toString());
    _discountController = TextEditingController(text: widget.purchase.discount.toString());
  }

  @override
  void dispose() {
    _noteController.dispose();
    _shippingCostController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    context.read<PurchaseCubit>().updatePurchase(
      id: widget.purchase.id,
      note: _noteController.text.trim(),
      discount: double.tryParse(_discountController.text.trim().replaceAll(',', '.')),
      shippingCost: double.tryParse(_shippingCostController.text.trim().replaceAll(',', '.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent = BlocConsumer<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is UpdatePurchaseSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdatePurchaseError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdatePurchaseLoading;
        return Scaffold(
          backgroundColor: AppColors.lightBlueBackground,
          appBar: appBarWithActions(
            context,
            title: LocaleKeys.edit_purchase.tr(),
            showBackButton: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card - read-only
                  _buildInfoCard(context),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  // Items list - read-only
                  _buildItemsCard(context),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  // Editable fields
                  _buildEditCard(context),
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 52),
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submitUpdate,
                      icon: isLoading
                          ? SizedBox(
                              width: ResponsiveUI.value(context, 18),
                              height: ResponsiveUI.value(context, 18),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        LocaleKeys.update_admin.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUI.borderRadius(context, 14),
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 32)),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }

  Widget _buildInfoCard(BuildContext context) {
    final p = widget.purchase;
    return _card(
      context,
      title: LocaleKeys.purchase_title.tr(),
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _infoRow(context, LocaleKeys.reference_number.tr(), p.reference),
          _infoRow(context, LocaleKeys.supplier_name.tr(), p.supplier.username.isNotEmpty ? p.supplier.username : p.supplier.companyName),
          _infoRow(context, LocaleKeys.warehouse.tr(), p.warehouse.name),
          _infoRow(context, LocaleKeys.created_at.tr(),
              '${p.date.day}/${p.date.month}/${p.date.year}'),
          _infoRow(context, LocaleKeys.discount_status.tr(), p.paymentStatus),
          _infoRow(context, LocaleKeys.balance.tr(),
              '${p.grandTotal.toStringAsFixed(2)} EGP'),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    return _card(
      context,
      title: LocaleKeys.products.tr(),
      icon: Icons.inventory_2_outlined,
      child: widget.purchase.items.isEmpty
          ? Text(LocaleKeys.at_least_one_product.tr(),
              style: TextStyle(color: AppColors.shadowGray))
          : Column(
              children: widget.purchase.items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.product?.name ?? item.patchNumber ?? '-',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${item.quantity} × ${item.unitCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          color: AppColors.shadowGray,
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 8)),
                      Text(
                        '${item.subtotal.toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildEditCard(BuildContext context) {
    return _card(
      context,
      title: LocaleKeys.edit_purchase.tr(),
      icon: Icons.edit_outlined,
      child: Column(
        children: [
          _buildTextField(
            controller: _noteController,
            title: LocaleKeys.note.tr(),
            hint: LocaleKeys.hint_note.tr(),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildTextField(
            controller: _discountController,
            title: LocaleKeys.discount_amount.tr(),
            hint: '0',
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildTextField(
            controller: _shippingCostController,
            title: LocaleKeys.shipping_cost.tr(),
            hint: '0',
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context,
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
                topRight: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: ResponsiveUI.iconSize(context, 18), color: AppColors.primaryBlue),
                SizedBox(width: ResponsiveUI.spacing(context, 8)),
                Text(title,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    )),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                color: AppColors.shadowGray,
              )),
          Flexible(
            child: Text(
              value ?? '-',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String title, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.value(context, 16)),
        Text(title, style: TextStyle(color: AppColors.darkGray, fontWeight: FontWeight.w500)),
        SizedBox(height: ResponsiveUI.value(context, 8)),
        CustomTextField(controller: controller, labelText: '', hintText: hint, hasBoxDecoration: false, hasBorder: true),
      ],
    );
  }

}
