import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/responsive_ui.dart';

Widget buildTextField(
  BuildContext context, {
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String hint,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  int maxLines = 1,
  bool readOnly = false,
  void Function()? onTap,
}) {
  final fontSizeLabel = ResponsiveUI.fontSize(context, 14);
  final spacing8 = ResponsiveUI.spacing(context, 8);
  final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
  final iconSize22 = ResponsiveUI.iconSize(context, 22);
  final padding16 = ResponsiveUI.padding(context, 16);
  final padding14 = ResponsiveUI.padding(context, 14);
  final fontSizeHint = ResponsiveUI.fontSize(context, 15);
  final value15 = ResponsiveUI.value(context, 1.5);
  final value2 = ResponsiveUI.value(context, 2);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: fontSizeLabel,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      SizedBox(height: spacing8),
      TextFormField(
        readOnly: readOnly,
        onTap: onTap,
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.shadowGray[400],
            fontSize: fontSizeHint,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: iconSize22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(
              color: AppColors.shadowGray[300]!,
              width: value2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(
              color: AppColors.shadowGray[300]!,
              width: value2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: value2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(color: AppColors.red, width: value15),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(color: AppColors.red, width: value2),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: padding16,
            vertical: padding14,
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        
        style: TextStyle(fontSize: fontSizeHint),
      ),
    ],
  );
}
