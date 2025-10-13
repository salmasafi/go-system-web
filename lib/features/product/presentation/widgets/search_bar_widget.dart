import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
//import 'package:systego/core/constants/app_colors.dart';
//import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_text_field_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final void Function(String)? onChanged;
  final TextEditingController controller;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    required this.controller,
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
        controller: widget.controller,
        onChanged: widget.onChanged,
        labelText: 'Search',
        prefixIcon: Icons.search,
        prefixIconColor: AppColors.black,
        verticalPadding: ResponsiveUI.padding(context, 10),
        hasBoxDecoration: true,
        backgroundColor: AppColors.white,
        borderColor: AppColors.white,
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
