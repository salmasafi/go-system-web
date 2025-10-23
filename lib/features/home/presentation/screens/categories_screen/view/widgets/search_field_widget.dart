import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../../../core/widgets/custom_textfield/custom_text_field_widget.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const SearchFieldWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 12),
        vertical: ResponsiveUI.spacing(context, 12),
      ),
      child: CustomTextField(
        controller: controller,
        labelText: '',
        hintText: 'Search by category name',
        prefixIcon: Icons.search,
        hasBoxDecoration: false,
        hasBorder: true,
        prefixIconColor: AppColors.darkGray,
      ),
    );
  }
}