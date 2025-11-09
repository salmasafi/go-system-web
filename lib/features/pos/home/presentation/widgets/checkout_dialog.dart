// ── Checkout dialog ───────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import 'payment_option.dart';

class POSCheckoutDialog extends StatelessWidget {
  const POSCheckoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
      title: Row(
        children: [
          const Icon(Icons.payment, color: AppColors.primaryBlue),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Text(
            'Select Payment',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          POSPaymentOption(label: 'Card', icon: Icons.credit_card),
          POSPaymentOption(label: 'Cash', icon: Icons.money),
          POSPaymentOption(label: 'Multiple Payment', icon: Icons.payments),
        ],
      ),
    );
  }
}
