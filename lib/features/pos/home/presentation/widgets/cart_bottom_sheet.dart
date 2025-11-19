// lib/features/pos/home/presentation/widgets/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../cubit/pos_home_cubit.dart';
import '../../cubit/pos_home_state.dart';
import '../../model/pos_models.dart';
import 'action_botton.dart';
import 'selection_option.dart';
import 'checkout_dialog.dart'; // Import the checkout dialog

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
  late Set<int> _updatingIndices;

  late PosCubit cubit;
  late List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    cubit = context.read<PosCubit>();
    cartItems = cubit.cartItems;
    _updatingIndices = {};
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        if (cartItems.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
          return const SizedBox.shrink();
        }

        final total = cartItems.fold(
          0.0,
          (s, i) => s + i.product.price * i.quantity,
        );

        return Scaffold(
          floatingActionButton: Padding(
            padding: EdgeInsets.only(left: ResponsiveUI.padding(context, 35)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                POSActionButton(
                  label: 'Checkout',
                  icon: Icons.payment,
                  color: AppColors.primaryBlue,
                  onTap: () {
                    _showCheckoutDialog();
                  },
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 10)),
                POSActionButton(
                  label: 'Back',
                  icon: Icons.arrow_back_ios,
                  color: AppColors.red,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
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
                          while (cartItems.isNotEmpty) {
                            widget.onRemove(0);
                          }
                          setSheetState(() {});
                          //Navigator.pop(context);
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
                          color: AppColors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: AppColors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          widget.onRemove(index);
                          setSheetState(() {});
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
                            setSheetState(() {});
                            _updatingIndices.remove(index);
                          },
                          onDecrement: () {
                            if (_updatingIndices.contains(index)) return;
                            _updatingIndices.add(index);
                            if (item.quantity > 1) {
                              widget.onQuantityChanged(index, -1);
                            } else {
                              widget.onRemove(index);
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
                  margin: EdgeInsets.only(
                    bottom: ResponsiveUI.padding(context, 16),
                  ),
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBackground,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                      top: Radius.circular(20),
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
                        '\$${total.toStringAsFixed(2)}',
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

  // Inside _showCheckoutDialog()
  void _showCheckoutDialog() {
    final total = cartItems.fold(
      0.0,
      (s, i) => s + i.product.price * i.quantity,
    );
    showDialog(
      context: context,
      builder: (_) => POSPaymentMethodsDialog(
        onMethodSelected: (method) {
          Navigator.pop(context); // close payment method dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => POSCheckoutDialog(
              totalAmount: total,
              cartItems: cartItems,
              selectedPaymentMethod: method,
            ),
          );
        },
      ),
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

// Updated Payment Methods Dialog with callback
class POSPaymentMethodsDialog extends StatelessWidget {
  final Function(PaymentMethod) onMethodSelected;

  const POSPaymentMethodsDialog({super.key, required this.onMethodSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.payment, color: AppColors.primaryBlue),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: BlocBuilder<PosCubit, PosState>(
          builder: (context, state) {
            final cubit = context.read<PosCubit>();
            final paymentMethods = cubit.paymentMethods;

            if (paymentMethods.isEmpty) {
              return CustomEmptyState(
                icon: Icons.attach_money_rounded,
                title: 'No Payment Methods Found',
                message: 'Pull to refresh or check your connection',
                actionLabel: 'Retry',
                onAction: () => cubit.loadPosData(),
              );
            }

            return ListView.builder(
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final paymentMethod = paymentMethods[index];
                return POSSelectionOption(
                  label: paymentMethod.name,
                  icon: Icons.attach_money_rounded,
                  onTap: () {
                    cubit.changePaymentMethodValue(paymentMethod);
                    onMethodSelected(paymentMethod);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.black)),
        ),
      ],
    );
  }
}
