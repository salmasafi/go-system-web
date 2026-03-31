// ── Search bar ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';

class POSSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const POSSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onTap,
    super.key,
  });

  @override
  State<POSSearchBar> createState() => _POSSearchBarState();
}

class _POSSearchBarState extends State<POSSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: AppColors.shadowGray.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Scan/Search product by name/code',
          hintStyle: TextStyle(
            color: AppColors.shadowGray,
            fontSize: ResponsiveUI.fontSize(context, 14),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primaryBlue,
            size: ResponsiveUI.iconSize(context, 22),
          ),

          suffixIcon: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                color: AppColors.white,
                size: ResponsiveUI.iconSize(context, 20),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 16),
            vertical: ResponsiveUI.padding(context, 12),
          ),
        ),
      ),
    );
  }
}

