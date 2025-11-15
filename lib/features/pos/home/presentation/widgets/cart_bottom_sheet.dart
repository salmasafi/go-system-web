// lib/features/pos/home/presentation/widgets/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../model/pos_models.dart';
import 'action_botton.dart';
import 'checkout_dialog.dart';

class POSCartBottomSheet extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(int, int) onQuantityChanged;
  final Function(int) onRemove;

  const POSCartBottomSheet({
    super.key,
    required this.cartItems,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<POSCartBottomSheet> createState() => _POSCartBottomSheetState();
}

class _POSCartBottomSheetState extends State<POSCartBottomSheet> {
  late Set<int> _updatingIndices; // To prevent duplicate calls

  @override
  void initState() {
    super.initState();
    _updatingIndices = {};
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        // CRITICAL: Use widget.cartItems directly, NOT a local copy
        final cartItems = widget.cartItems;

        if (cartItems.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          floatingActionButton: Padding(
            padding: EdgeInsets.only(left: ResponsiveUI.padding(context, 35)),

            child: POSActionButton(
              label: 'Checkout',
              icon: Icons.payment,
              color: AppColors.primaryBlue,
              onTap: () => _showCheckoutDialog(),
              // close bottom sheet & open checkout
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.shadowGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cart (${cartItems.length})',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear all via parent
                          while (cartItems.isNotEmpty) {
                            widget.onRemove(0);
                          }
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Items
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Dismissible(
                        key: ValueKey('${item.product.id}_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          widget.onRemove(index);
                          setSheetState(() {}); // Important!
                          if (cartItems.length <= 1) {
                            Navigator.pop(context);
                          }
                        },
                        child: CartItemTile(
                          item: item,
                          onIncrement: () {
                            if (_updatingIndices.contains(index)) return;
                            _updatingIndices.add(index);
                            widget.onQuantityChanged(index, 1);
                            setSheetState(() {}); // Force rebuild
                            _updatingIndices.remove(index);
                          },
                          onDecrement: () {
                            if (_updatingIndices.contains(index)) return;
                            _updatingIndices.add(index);
                            if (item.quantity > 1) {
                              widget.onQuantityChanged(index, -1);
                            } else {
                              widget.onRemove(index);
                              if (cartItems.length <= 1) {
                                Navigator.pop(context);
                              }
                            }
                            setSheetState(() {});
                            _updatingIndices.remove(index);
                          },
                          onLongPress: () async {
                            final controller = TextEditingController(
                              text: item.quantity.toString(),
                            );
                            final newQty = await showDialog<int>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Edit Quantity'),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter quantity',
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
                                  TextButton(
                                    onPressed: () {
                                      final val =
                                          int.tryParse(controller.text) ?? 1;
                                      Navigator.pop(context, val > 0 ? val : 1);
                                    },
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(color: AppColors.black),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (newQty != null && newQty != item.quantity) {
                              final delta = newQty - item.quantity;
                              widget.onQuantityChanged(index, delta);
                              setSheetState(() {});
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Total
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBackground,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${cartItems.fold(0.0, (s, i) => s + i.product.price * i.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCheckoutDialog() {
    showDialog(context: context, builder: (_) => POSCheckoutDialog());
  }
}

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
          // DECREMENT
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: onDecrement, // Only call callback
          ),

          // QUANTITY (long press to edit)
          GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${item.quantity}', // Display current value
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // INCREMENT
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: onIncrement, // Only call callback
          ),
        ],
      ),
    );
  }
}
