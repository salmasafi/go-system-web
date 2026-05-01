// lib/features/pos/home/presentation/widgets/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/pos/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/pos/customer/cubit/pos_customer_cubit.dart';
import 'package:systego/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/pos/customer/presentation/widgets/customer_picker_sheet.dart';
import '../../model/checkout_models.dart';
import 'action_botton.dart';
import 'cart_item_tile.dart';
import 'checkout_dialog.dart';

class POSCartBottomSheet extends StatefulWidget {
  final Function(int, int) onQuantityChanged;
  final Function(int) onRemove;

  const POSCartBottomSheet({
    super.key,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<POSCartBottomSheet> createState() => _POSCartBottomSheetState();
}

class _POSCartBottomSheetState extends State<POSCartBottomSheet> {
  late CheckoutCubit cubit;
  late PosCubit posCubit;
  late List<CartItem> cartItems;
  late double total;

  @override
  void initState() {
    super.initState();
    posCubit = context.read<PosCubit>();
    cubit = context.read<CheckoutCubit>();
    cartItems = List.from(
      cubit.cartItems,
    ); // نسخة محلية عشان ما يتغيرش أثناء السكرول
    _calculateTotal();
  }

  void _calculateTotal() {
    total = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  void _refresh() {
    setState(() {
      cartItems = List.from(cubit.cartItems);
      _calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    // إذا الكارت فاضي → نقفل الشيت
    if (cartItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return SizedBox.shrink();
    }

    return Container(
      height:
          ResponsiveUI.screenHeight(context) *
          0.78, // 78% من الشاشة (مثالي للموبايل)
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Column(
        children: [
          // === الـ Handle + Header ===
          Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUI.padding(context, 12),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: ResponsiveUI.value(context, 45),
                  height: ResponsiveUI.value(context, 5),
                  decoration: BoxDecoration(
                    color: AppColors.shadowGray.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 3),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),

                // العنوان + Clear All
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cart (${cartItems.length})',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          cubit.updateCartWithEmptyList();
                          posCubit.refreshCartProducts();
                          _refresh();
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w800,
                            fontSize: ResponsiveUI.fontSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // === قائمة المنتجات (تسكرول) ===
          // lib/features/pos/home/presentation/widgets/cart_bottom_sheet.dart
          // Replace the ListView.builder section with this updated version

          // In the Expanded ListView.builder section, replace the entire builder:
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
              ),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Dismissible(
                  key: ValueKey(
                    '${item.product.id}_${item.selectedVariation?.code ?? 'no_var'}_$index',
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: ResponsiveUI.padding(context, 6),
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 16),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(
                      right: ResponsiveUI.padding(context, 24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: ResponsiveUI.iconSize(context, 32),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 4)),
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUI.fontSize(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    widget.onRemove(index);
                    _refresh();
                    if (cartItems.length <= 1) Navigator.pop(context);
                  },
                  child: CartItemTile(
                    key: ValueKey(
                      '${item.product.id}_${item.selectedVariation?.id ?? ''}_${item.quantity}',
                    ),
                    item: item,
                    onIncrement: () {
                      widget.onQuantityChanged(index, 1);
                      _refresh();
                    },
                    onDecrement: () {
                      if (item.quantity > 1) {
                        widget.onQuantityChanged(index, -1);
                      } else {
                        widget.onRemove(index);
                      }
                      _refresh();
                    },
                    onLongPress: () async {
                      final newQty = await _showQuantityDialog(item.quantity);
                      if (newQty != null && newQty != item.quantity) {
                        widget.onQuantityChanged(index, newQty - item.quantity);
                        _refresh();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Don't forget to add these imports at the top of cart_bottom_sheet.dart:
          // import 'enhanced_cart_item_tile.dart';
          // import 'cart_item_details_dialog.dart';
          // === الجزء السفلي الثابت (Total + Buttons) ===
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.shadowGray.withValues(alpha: 0.2),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 22),
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 26),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 20)),

                  // الأزرار
                  Row(
                    children: [
                      // Back Button
                      Expanded(
                        child: POSActionButton(
                          label: 'Back',
                          icon: Icons.arrow_back_ios_new_rounded,
                          color: AppColors.red,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 12)),

                      // Hold Button
                      Expanded(
                        child: POSActionButton(
                          label: 'Hold',
                          icon: Icons.pause_circle_outline,
                          color: Colors.orange,
                          onTap: () => _holdSale(),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 12)),

                      // Checkout Button
                      Expanded(
                        flex: 2,
                        child: POSActionButton(
                          label: 'Checkout',
                          icon: Icons.payment_rounded,
                          color: AppColors.primaryBlue,
                          onTap: () => _showCheckoutDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دايلوج تعديل الكمية
  Future<int?> _showQuantityDialog(int current) async {
    final controller = TextEditingController(text: current.toString());
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
        ),
        title: const Text('Edit Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new quantity',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            // focusColor: AppColors.primaryBlue,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: ResponsiveUI.value(context, 1.7),
              ),
            ),
            // enabledBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: AppColors.primaryBlue),
            // ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? 1;
              Navigator.pop(context, val > 0 ? val : 1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('OK', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _holdSale() async {
    final success = await cubit.createSale(
      totalAmount: total,
      paidAmount: 0,
      note: "Sale on Hold",
      isPending: true,
      customerId: context.read<PosCustomerCubit>().selectedCustomer?.id ?? '',
      warehouseId: posCubit.selectedWarhouse?.id,
    );

    if (success && mounted) {
      Navigator.pop(context);
      CustomSnackbar.showSuccess(context, "Sale put on hold successfully");
    }
  }

  void _showCheckoutDialog() {
    final selectedCustomer = context.read<PosCustomerCubit>().selectedCustomer;

    showDialog(
      context: context,
      builder: (_) => POSCheckoutDialog(
        totalAmount: total,
        cartItems: cartItems,
        selectedPaymentMethod: posCubit.selectedPaymentMethod!,
        customerId: selectedCustomer?.id ?? '',
      ),
    );
  }
}
