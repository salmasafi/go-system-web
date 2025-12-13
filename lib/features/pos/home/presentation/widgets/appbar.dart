// lib/features/pos/home/presentation/widgets/pos_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/features/admin/auth/cubit/login_cubit.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';

class POSAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  const POSAppBar({super.key});

  @override
  State<POSAppBar> createState() => _POSAppBarState();
}

class _POSAppBarState extends State<POSAppBar> {
  DateTime _selectedDate = DateTime.now();

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get username from LoginCubit (works after restart)
    final username = context.read<LoginCubit>().savedUser?.username ?? 'Guest';

    return appBarWithActionsWidget(
      context,
      backgroundColor: AppColors.lightBlueBackground,
      actionWidget: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 10),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 12),
              vertical: ResponsiveUI.padding(context, 6),
            ),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              border: Border.all(
                color: AppColors.black.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.black,
                  size: ResponsiveUI.iconSize(context, 16),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 6)),
                Text(
                  username,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      showActions: true,
      showBackButton: false,
      title: 'POS', 
    );
    // AppBar(
    //       elevation: 0,
    //       backgroundColor: AppColors.primaryBlue,
    //       foregroundColor: AppColors.white,
    //        title:  // GestureDetector(
    //       //   onTap: () => _selectDate(context),
    //       //   child: Container(
    //       //     padding: EdgeInsets.symmetric(
    //       //       horizontal: ResponsiveUI.padding(context, 12),
    //       //       vertical: ResponsiveUI.padding(context, 6),
    //       //     ),
    //       //     decoration: BoxDecoration(
    //       //       color: AppColors.white.withOpacity(0.15),
    //       //       borderRadius: BorderRadius.circular(
    //       //         ResponsiveUI.borderRadius(context, 12),
    //       //       ),
    //       //       border: Border.all(
    //       //         color: AppColors.white.withOpacity(0.3),
    //       //         width: 1.5,
    //       //       ),
    //       //     ),
    //       //     child: Row(
    //       //       mainAxisSize: MainAxisSize.min,
    //       //       children: [
    //       //         // Date Box
    //       //         Container(
    //       //           padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
    //       //           decoration: BoxDecoration(
    //       //             color: AppColors.white,
    //       //             borderRadius: BorderRadius.circular(
    //       //               ResponsiveUI.borderRadius(context, 8),
    //       //             ),
    //       //           ),
    //       //           child: Column(
    //       //             mainAxisSize: MainAxisSize.min,
    //       //             children: [
    //       //               Text(
    //       //                 '${_selectedDate.day}',
    //       //                 style: TextStyle(
    //       //                   color: AppColors.primaryBlue,
    //       //                   fontSize: ResponsiveUI.fontSize(context, 16),
    //       //                   fontWeight: FontWeight.bold,
    //       //                   height: 1,
    //       //                 ),
    //       //               ),
    //       //               Text(
    //       //                 _getMonthName(_selectedDate.month),
    //       //                 style: TextStyle(
    //       //                   color: AppColors.primaryBlue,
    //       //                   fontSize: ResponsiveUI.fontSize(context, 10),
    //       //                   fontWeight: FontWeight.w600,
    //       //                   height: 1.2,
    //       //                 ),
    //       //               ),
    //       //             ],
    //       //           ),
    //       //         ),
    //       //         SizedBox(width: ResponsiveUI.spacing(context, 10)),

    //       //         // Date Text + Hint
    //       //         Column(
    //       //           crossAxisAlignment: CrossAxisAlignment.start,
    //       //           mainAxisSize: MainAxisSize.min,
    //       //           children: [
    //       //             Text(
    //       //               _formatDate(_selectedDate),
    //       //               style: TextStyle(
    //       //                 color: AppColors.white,
    //       //                 fontSize: ResponsiveUI.fontSize(context, 15),
    //       //                 fontWeight: FontWeight.bold,
    //       //               ),
    //       //             ),
    //       //             Text(
    //       //               'Tap to change',
    //       //               style: TextStyle(
    //       //                 color: AppColors.white.withOpacity(0.8),
    //       //                 fontSize: ResponsiveUI.fontSize(context, 11),
    //       //               ),
    //       //             ),
    //       //           ],
    //       //         ),
    //       //         SizedBox(width: ResponsiveUI.spacing(context, 8)),

    //       //         // Calendar Icon
    //       //         Icon(
    //       //           Icons.calendar_today,
    //       //           color: AppColors.white,
    //       //           size: ResponsiveUI.iconSize(context, 18),
    //       //         ),
    //       //       ],
    //       //     ),
    //       //   ),
    //       // ),

    //       actions: [
    //         // User Info Button
    //         Padding(
    //           padding: EdgeInsets.symmetric(
    //             horizontal: ResponsiveUI.padding(context, 16),
    //           ),
    //           child: Center(
    //             child: Container(
    //               padding: EdgeInsets.symmetric(
    //                 horizontal: ResponsiveUI.padding(context, 12),
    //                 vertical: ResponsiveUI.padding(context, 6),
    //               ),
    //               decoration: BoxDecoration(
    //                 color: AppColors.white.withOpacity(0.15),
    //                 borderRadius: BorderRadius.circular(
    //                   ResponsiveUI.borderRadius(context, 10),
    //                 ),
    //                 border: Border.all(
    //                   color: AppColors.white.withOpacity(0.3),
    //                   width: 1.5,
    //                 ),
    //               ),
    //               child: Row(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Icon(
    //                     Icons.person_outline,
    //                     color: AppColors.white,
    //                     size: ResponsiveUI.iconSize(context, 16),
    //                   ),
    //                   SizedBox(width: ResponsiveUI.spacing(context, 6)),
    //                   Text(
    //                     username,
    //                     style: TextStyle(
    //                       color: AppColors.white,
    //                       fontSize: ResponsiveUI.fontSize(context, 13),
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     );
  }
}
