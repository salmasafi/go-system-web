// lib/features/pos/home/presentation/widgets/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import '../../model/checkout_models.dart';
import 'action_botton.dart';
import 'checkout_dialog.dart';
import 'payment_methods_dialog.dart'; // Import the checkout dialog

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
    total = cartItems.fold(
      0.0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
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
      return const SizedBox.shrink();
    }

    return Container(
      height:
          ResponsiveUI.screenHeight(context) *
          0.78, // 78% من الشاشة (مثالي للموبايل)
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.shadowGray.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
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
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
              ),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Dismissible(
                  key: ValueKey('${item.product.id}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  onDismissed: (_) {
                    widget.onRemove(index);
                    _refresh();
                    if (cartItems.length <= 1) Navigator.pop(context);
                  },
                  child: CartItemTile(
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

          // === الجزء السفلي الثابت (Total + Buttons) ===
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.shadowGray.withOpacity(0.2)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new quantity',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            // focusColor: AppColors.primaryBlue,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.7),
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

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (_) =>
          //POSPaymentMethodsDialog(
          //onMethodSelected: (method) {
          //Navigator.pop(context); // إغلاق اختيار الدفع
          // showDialog(
          //context: context,
          // barrierDismissible: false,
          // builder: (_) =>
          POSCheckoutDialog(
            totalAmount: total,
            cartItems: cartItems,
            selectedPaymentMethod: posCubit.selectedPaymentMethod!,
          ),
      // );
      //},
      //),
    );
  }
}

// Updated CartItemTile (unchanged)
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongPress;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: item.product.image != null
            ? NetworkImage(item.product.image!)
            : null,
        child: item.product.image == null
            ? const Icon(Icons.image, size: 20)
            : null,
      ),
      title: Text(
        item.product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: onDecrement,
          ),
          GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
