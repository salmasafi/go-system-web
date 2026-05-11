import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/pos/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';
import 'package:GoSystem/features/pos/customer/cubit/pos_customer_cubit.dart';
import 'package:GoSystem/features/pos/customer/presentation/widgets/customer_selector_widget.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:GoSystem/features/pos/shift/cubit/pos_shift_cubit.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'action_botton.dart';
import 'cart_item_tile.dart';
import 'checkout_dialog.dart';

class POSCartSidePanel extends StatelessWidget {
  final Function(int, int) onQuantityChanged;
  final Function(int) onRemove;

  const POSCartSidePanel({
    super.key,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, _) {
        final cubit = context.read<CheckoutCubit>();
        final posCubit = context.read<PosCubit>();
        final cartItems = cubit.cartItems;
        final summary = cubit.calculateSummary(
          selectedTax: posCubit.selectedTax,
          selectedDiscount: posCubit.selectedDiscount,
          selectedCoupon: posCubit.selectedCoupon,
        );
        final total = summary.grandTotal;

        return Container(
          width: 340,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: BorderDirectional(
              start: BorderSide(
                color: AppColors.lightGray.withValues(alpha: 0.5),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context, cartItems, cubit, posCubit),
              _buildCustomerSelector(context),
              Expanded(
                child: cartItems.isEmpty
                    ? _buildEmptyState(context)
                    : _buildCartList(context, cartItems),
              ),
              if (cartItems.isNotEmpty) _buildFooter(context, summary, cartItems),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, List<CartItem> cartItems,
      CheckoutCubit cubit, PosCubit posCubit) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGray.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.primaryBlue,
                size: ResponsiveUI.iconSize(context, 20),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 8)),
              Text(
                LocaleKeys.cart.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              if (cartItems.isNotEmpty) ...[
                SizedBox(width: ResponsiveUI.spacing(context, 6)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 8),
                    vertical: ResponsiveUI.padding(context, 2),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12)),
                  ),
                  child: Text(
                    '${cartItems.length}',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                cubit.updateCartWithEmptyList();
                posCubit.refreshCartProducts();
              },
              child: Text(
                LocaleKeys.clear_all.tr(),
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveUI.fontSize(context, 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 12),
        vertical: ResponsiveUI.padding(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightGray.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: const CustomerSelectorWidget(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: ResponsiveUI.iconSize(context, 60),
            color: AppColors.lightGray,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          Text(
            LocaleKeys.cart_is_empty.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 15),
              color: AppColors.shadowGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 6)),
          Text(
            LocaleKeys.add_products_from_side.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: AppColors.shadowGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, List<CartItem> cartItems) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 10),
        vertical: ResponsiveUI.padding(context, 8),
      ),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Dismissible(
          key: ValueKey(
              '${item.product.id}_${item.getAttributesDisplay()}_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin:
                EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 4)),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12)),
            ),
            alignment: AlignmentDirectional.centerEnd,
            padding: EdgeInsetsDirectional.only(end: ResponsiveUI.padding(context, 16)),
            child: Icon(Icons.delete_forever,
                color: Colors.white, size: ResponsiveUI.iconSize(context, 26)),
          ),
          onDismissed: (_) => onRemove(index),
          child: CartItemTile(
            key: ValueKey(
                '${item.product.id}_${item.getAttributesDisplay()}_${item.quantity}'),
            item: item,
            onIncrement: () => onQuantityChanged(index, 1),
            onDecrement: () {
              if (item.quantity > 1) {
                onQuantityChanged(index, -1);
              } else {
                onRemove(index);
              }
            },
            onLongPress: () async {
              final newQty = await _showQuantityDialog(context, item.quantity);
              if (newQty != null && newQty != item.quantity) {
                onQuantityChanged(index, newQty - item.quantity);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(
      BuildContext context, CartSummary summary, List<CartItem> cartItems) {
    final total = summary.grandTotal;
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top:
              BorderSide(color: AppColors.shadowGray.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Total display
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${LocaleKeys.cart_items.tr()}: ${cartItems.length} (${cartItems.fold(0, (s, i) => s + i.quantity)})',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 11),
                          color: AppColors.shadowGray,
                        ),
                      ),
                      Text(
                        LocaleKeys.grand_total.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} ${'currency_symbol'.tr()}',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 10)),
            Row(
              children: [
                Expanded(
                  child: POSActionButton(
                    label: LocaleKeys.hold.tr(),
                    icon: Icons.pause_circle_outline,
                    color: AppColors.warningOrange,
                    onTap: () => _holdSale(context, summary),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 8)),
                Expanded(
                  flex: 2,
                  child: POSActionButton(
                    label: LocaleKeys.checkout.tr(),
                    icon: Icons.payment_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => _showCheckoutDialog(context, total, cartItems),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _showQuantityDialog(BuildContext context, int current) async {
    final controller = TextEditingController(text: current.toString());
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
        title: Text(LocaleKeys.edit_quantity_title.tr()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: LocaleKeys.enter_new_quantity.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12)),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: ResponsiveUI.value(context, 1.7),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.cancel.tr(), style: const TextStyle(color: AppColors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? 1;
              Navigator.pop(context, val > 0 ? val : 1);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: Text(LocaleKeys.ok.tr(), style: const TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _holdSale(BuildContext context, CartSummary summary) async {
    final cubit = context.read<CheckoutCubit>();
    final posCubit = context.read<PosCubit>();
    final shiftCubit = context.read<PosShiftCubit>();
    final customerCubit = context.read<PosCustomerCubit>();

    final success = await cubit.createSale(
      totalAmount: summary.grandTotal,
      paidAmount: 0,
      note: LocaleKeys.sale_on_hold_note.tr(),
      isPending: true,
      customerId: customerCubit.selectedCustomer?.id,
      warehouseId: posCubit.selectedWarhouse?.id,
      shiftId: shiftCubit.currentShift?.id,
      cashierId: shiftCubit.selectedCashier?.id,
      taxAmount: summary.taxAmount,
      discountAmount: summary.discountAmount + summary.couponAmount,
      taxId: posCubit.selectedTax?.id == 'null' ? null : posCubit.selectedTax?.id,
      discountId: posCubit.selectedDiscount?.id == 'null' ? null : posCubit.selectedDiscount?.id,
      couponCode: (posCubit.selectedCoupon != null && posCubit.selectedCoupon!.id != 'null')
          ? posCubit.selectedCoupon!.couponCode
          : null,
    );

    if (success && context.mounted) {
      CustomSnackbar.showSuccess(context, LocaleKeys.sale_put_on_hold.tr());
    }
  }

  void _showCheckoutDialog(
      BuildContext context, double total, List<CartItem> cartItems) {
    final posCubit = context.read<PosCubit>();
    final customerCubit = context.read<PosCustomerCubit>();

    showDialog(
      context: context,
      builder: (_) => POSCheckoutDialog(
        totalAmount: total,
        cartItems: cartItems,
        selectedPaymentMethod: posCubit.selectedPaymentMethod,
        customerId: customerCubit.selectedCustomer?.id,
      ),
    );
  }
}
