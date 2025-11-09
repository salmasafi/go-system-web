// ── Cart bottom-sheet (modal) ──────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../model/pos_models.dart';
import 'cart_item_card.dart';

class POSCartBottomSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
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
                  colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
                  topRight: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart Items (${cartItems.length})',
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
                itemCount: cartItems.length,
                itemBuilder: (_, i) => POSCartItemCard(
                  item: cartItems[i],
                  index: i,
                  onQuantityChanged: (delta) => onQuantityChanged(i, delta),
                  onRemove: () => onRemove(i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
