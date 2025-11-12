// ── Cart bottom-sheet (modal) ──────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../model/pos_models.dart';
import 'action_botton.dart';
import 'cart_item_card.dart';
import 'checkout_dialog.dart';

class POSCartBottomSheet extends StatefulWidget {
  final List<CartItem> cartItems;
  final void Function(int index, int delta) onQuantityChanged;
  final void Function(int index) onRemove;

  const POSCartBottomSheet({
    required this.cartItems,
    required this.onQuantityChanged,
    required this.onRemove,
    super.key,
  });

  @override
  State<POSCartBottomSheet> createState() => _POSCartBottomSheetState();
}

class _POSCartBottomSheetState extends State<POSCartBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scrollController) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
              topRight: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      ResponsiveUI.borderRadius(context, 24),
                    ),
                    topRight: Radius.circular(
                      ResponsiveUI.borderRadius(context, 24),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cart Items (${widget.cartItems.length})',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  itemCount: widget.cartItems.length,
                  itemBuilder: (_, i) => POSCartItemCard(
                    item: widget.cartItems[i],
                    index: i,
                    onQuantityChanged: (delta) =>
                        widget.onQuantityChanged(i, delta),
                    onRemove: () => widget.onRemove(i),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: ResponsiveUI.spacing(context, 32)),
          child: POSActionButton(
            label: 'Checkout',
            icon: Icons.payment,
            color: AppColors.primaryBlue,
            onTap: () => _showCheckoutDialog(),
            // close bottom sheet & open checkout
          ),
        ),
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(context: context, builder: (_) => POSCheckoutDialog());
  }
}
