import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_ui.dart';

Widget buildDropdownField<T>(
  BuildContext context, {
  required T? value,
  required List<T> items,
  required String label,
  IconData? icon,
  required String hint,
  required void Function(T?) onChanged,
  required String Function(T) itemLabel,
  String? Function(T?)? validator,
}) {
  final fontSizeLabel = ResponsiveUI.fontSize(context, 14);
  final spacing8 = ResponsiveUI.spacing(context, 8);
  final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
  final value3 = ResponsiveUI.value(context, 3);
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
      DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.shadowGray[400],
            fontSize: fontSizeHint,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primaryBlue, size: iconSize22)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(
              color: AppColors.shadowGray[300]!,
              width: value3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(
              color: AppColors.shadowGray[300]!,
              width: value3,
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
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: TextStyle(
                fontSize: fontSizeHint,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primaryBlue,
          size: iconSize22,
        ),
        style: TextStyle(
          fontSize: fontSizeHint,
          fontFamily: 'Rubik',
          color: Colors.grey[800],
        ),

        dropdownColor: AppColors.white,
        isExpanded: true,
      ),
    ],
  );
}

Widget buildMultiSelectDropdownField<T>(
  BuildContext context, {
  required List<T> items,
  required String hint,
  required void Function(List<T>)? onChanged,
  required String Function(T) itemLabel,
}) {
  return DropdownSearch<T>.multiSelection(
    onChanged: onChanged,
    items: items,
    itemAsString: itemLabel,
    //dropdownButtonProps: DropdownButtonProps(color: AppColors.lightBlueBackground),
    popupProps: PopupPropsMultiSelection.menu(
      
      menuProps: MenuProps(
        
        backgroundColor: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      
      // showSearchBox: true,
      // searchFieldProps: TextFieldProps(
      //   decoration: InputDecoration(
      //     hintText: hint,
      //     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.circular(15),
      //       borderSide: BorderSide(color: AppColors.white),
      //     ),
      //   ),
      // ),
    ),
    dropdownDecoratorProps: DropDownDecoratorProps(

      dropdownSearchDecoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.shadowGray[300]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.shadowGray[300]!, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
        hintText: hint,
        
        // suffixIcon: Icon(
        //   Icons.keyboard_arrow_down_rounded,
        //   color: AppColors.primaryBlue,
        // ),
      ),
    ),
    dropdownButtonProps: DropdownButtonProps(
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primaryBlue,
      ),
    ),
  );
}
