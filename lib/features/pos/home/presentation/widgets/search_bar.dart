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
  bool _hasFocus = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _hasFocus = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _hasFocus ? AppColors.white : AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 14),
        ),
        border: Border.all(
          color: _hasFocus
              ? AppColors.primaryBlue.withValues(alpha: 0.5)
              : AppColors.shadowGray.withValues(alpha: 0.15),
          width: _hasFocus ? 1.8 : 1.0,
        ),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Search icon
          Container(
            margin: EdgeInsetsDirectional.only(
              start: ResponsiveUI.padding(context, 14),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
              decoration: BoxDecoration(
                color: _hasFocus
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              child: Icon(
                Icons.search_rounded,
                color: _hasFocus ? AppColors.primaryBlue : AppColors.shadowGray.withValues(alpha: 0.7),
                size: ResponsiveUI.iconSize(context, 22),
              ),
            ),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w500,
                color: AppColors.darkGray,
              ),
              decoration: InputDecoration(
                hintText: 'Scan/Search product by name or code',
                hintStyle: TextStyle(
                  color: AppColors.shadowGray.withValues(alpha: 0.6),
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 12),
                  vertical: ResponsiveUI.padding(context, 13),
                ),
              ),
            ),
          ),
          // Clear button (when text is not empty)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Container(
                    margin: EdgeInsetsDirectional.only(
                      end: ResponsiveUI.padding(context, 4),
                    ),
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
                    decoration: BoxDecoration(
                      color: AppColors.shadowGray.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.shadowGray,
                      size: ResponsiveUI.iconSize(context, 16),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // QR Scanner button
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 5)),
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryBlue.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.white,
                size: ResponsiveUI.iconSize(context, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
