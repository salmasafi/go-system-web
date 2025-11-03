import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
//import 'package:systego/core/constants/app_colors.dart';
//import 'package:systego/core/utils/responsive_ui.dart';

class SearchBarWidget extends StatefulWidget {
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final String text;
  final IconData? suffixIcon;
  final void Function()? suffixOnPressed;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    required this.controller,
    required this.text,
    this.suffixIcon,
    this.suffixOnPressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 12),
      ),
      child: CustomTextField(
        hintText: 'Search ${widget.text}...',
        prefixIcon: Icons.search,
        hasBoxDecoration: true,
        hasBorder: true,
        prefixIconColor: AppColors.darkGray.withOpacity(0.7),
        controller: widget.controller,
        onChanged: widget.onChanged,
        //labelText: 'Search',
        verticalPadding: ResponsiveUI.padding(context, 16),
        backgroundColor: AppColors.white,
        borderColor: AppColors.white,
        suffixIcon: widget.suffixIcon,
        suffixOnPressed: widget.suffixOnPressed,
      ),
    );
    // return Container(
    //   margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
    //   padding: EdgeInsets.symmetric(
    //     horizontal: ResponsiveUI.padding(context, 16),
    //     vertical: ResponsiveUI.padding(context, 12),
    //   ),
    //   decoration: BoxDecoration(
    //     color: AppColors.white,
    //     borderRadius: BorderRadius.circular(
    //       ResponsiveUI.borderRadius(context, 8),
    //     ),
    //     border: Border.all(color: AppColors.shadowGray[300]!),
    //   ),
    //   child: Row(
    //     children: [
    //       Icon(
    //         Icons.search,
    //         color: AppColors.shadowGray[400],
    //         size: ResponsiveUI.iconSize(context, 20),
    //       ),
    //       SizedBox(width: ResponsiveUI.spacing(context, 12)),
    //       Text(
    //         'Search',
    //         style: TextStyle(
    //           color: AppColors.shadowGray[400],
    //           fontSize: ResponsiveUI.fontSize(context, 14),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
