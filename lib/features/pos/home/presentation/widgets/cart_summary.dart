// ── Cart summary (bottom sheet) ───────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../model/pos_models.dart';
import 'action_botton.dart';
import 'checkout_dialog.dart';

class POSCartSummary extends StatefulWidget {
  final double total;
  final List<CartItem> cartItems;

  const POSCartSummary({
    required this.total,
    required this.cartItems,
    super.key,
  });

  @override
  State<POSCartSummary> createState() => _POSCartSummaryState();
}

class _POSCartSummaryState extends State<POSCartSummary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items: ${widget.cartItems.length} '
                      '(${widget.cartItems.fold(0, (s, i) => s + i.quantity)})',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        color: AppColors.shadowGray,
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 4)),
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${widget.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            // SizedBox(height: ResponsiveUI.spacing(context, 16)),
            //   Row(
            //     children: [
            //       Expanded(
            //         child: POSActionButton(
            //           label: 'Draft',
            //           icon: Icons.drafts_outlined,
            //           color: AppColors.warningOrange,
            //           onTap: () {},
            //         ),
            //       ),
            //       SizedBox(width: ResponsiveUI.spacing(context, 8)),
            //       Expanded(
            //         flex: 2,
            //         child: POSActionButton(
            //           label: 'Checkout',
            //           icon: Icons.payment,
            //           color: AppColors.primaryBlue,
            //           onTap: () => _showCheckoutDialog(),
            //           // close bottom sheet & open checkout
            //         ),
            //       ),
            //     ],
            //   ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(context: context, builder: (_) => POSCheckoutDialog());
  }
}
