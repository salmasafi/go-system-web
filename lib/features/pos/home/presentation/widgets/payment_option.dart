import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';

class POSPaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;

  const POSPaymentOption({
    required this.label,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          onTap: () {
            Navigator.pop(context);
            // TODO: handle payment selection
          },
          child: Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.white, AppColors.lightBlueBackground],
              ),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue),
                SizedBox(width: ResponsiveUI.spacing(context, 12)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}