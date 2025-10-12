import 'package:flutter/material.dart';
//import 'package:systego/core/constants/app_colors.dart';
//import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_text_faild_widget.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CustomTextField(controller: controller, labelText: 'Search');
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
