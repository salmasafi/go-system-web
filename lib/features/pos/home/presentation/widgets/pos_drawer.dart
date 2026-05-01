import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/services/cache_helper.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/pos/expenses/presentation/expenses_screen.dart';
import 'package:GoSystem/features/pos/history/presentation/views/dues_screen.dart';
import 'package:GoSystem/features/pos/history/presentation/views/history_screen.dart';
import 'package:GoSystem/features/pos/profile/presentation/profile_screen.dart';
import 'package:GoSystem/features/pos/return/widgets/return_search_dialog.dart';
import 'package:GoSystem/features/pos/shift/cubit/pos_shift_cubit.dart';
import 'package:GoSystem/features/admin/auth/cubit/login_cubit.dart';
import 'package:GoSystem/features/admin/auth/presentation/view/login_screen.dart';
import 'package:GoSystem/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/main.dart';

class POSDrawer extends StatelessWidget {
  final String shiftDuration;

  const POSDrawer({super.key, required this.shiftDuration});

  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDeleteDialog(
        title: featureName,
        message: 'This feature will be available soon.',
        icon: Icons.rocket_launch_outlined,
        iconColor: AppColors.primaryBlue,
        deleteText: 'OK',
        cancelText: '',
        onDelete: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showEndShiftDialog(BuildContext context, PosShiftCubit shiftCubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomDeleteDialog(
        title: LocaleKeys.close_shift.tr(),
        message: LocaleKeys.close_shift_confirmation.tr(),
        icon: Icons.stop_circle_outlined,
        iconColor: AppColors.red,
        deleteText: LocaleKeys.close_shift.tr(),
        onDelete: () async {
          Navigator.pop(ctx);
          Navigator.pop(context); // close drawer
          await shiftCubit.endShift();
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, PosShiftCubit shiftCubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomDeleteDialog(
        title: LocaleKeys.exit.tr(),
        message: LocaleKeys.exit_confirmation_message.tr(),
        icon: Icons.logout,
        iconColor: AppColors.darkGray,
        deleteText: LocaleKeys.exit.tr(),
        onDelete: () async {
          Navigator.pop(ctx);
          await shiftCubit.logoutShift();
          await CacheHelper.clearAllData();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shiftCubit = context.read<PosShiftCubit>();
    final user = context.read<LoginCubit>().savedUser;
    final cashier = shiftCubit.selectedCashier;

    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: ResponsiveUI.value(context, 48),
                    height: ResponsiveUI.value(context, 48),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.primaryBlue,
                      size: ResponsiveUI.iconSize(context, 26),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 10)),
                  Text(
                    'AUTHENTICATED AS',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 11),
                      color: AppColors.shadowGray,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 2)),
                  Text(
                    user?.username ?? cashier?.name ?? 'User',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 4)),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: ResponsiveUI.iconSize(context, 14), color: AppColors.successGreen),
                      SizedBox(width: ResponsiveUI.value(context, 4)),
                      Text(
                        shiftDuration,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Menu Items ───────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 8),
                ),
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.translate_rounded,
                    label: 'تغيير للعربية',
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Language');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.format_list_bulleted_rounded,
                    label: 'All Orders',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.assignment_return_outlined,
                    label: 'Return Sale',
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => const ReturnSearchDialog(),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.group_outlined,
                    label: 'Due Users',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DuesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.attach_money_rounded,
                    label: 'Expenses',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ExpensesScreen()),
                      );
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                      vertical: ResponsiveUI.padding(context, 8),
                    ),
                    child: Divider(color: AppColors.lightGray, height: ResponsiveUI.value(context, 1)),
                  ),

                  // Close Shift
                  _DrawerItem(
                    icon: Icons.cancel_outlined,
                    label: LocaleKeys.close_shift.tr(),
                    labelColor: AppColors.red,
                    iconColor: AppColors.red,
                    onTap: () => _showEndShiftDialog(context, shiftCubit),
                  ),

                  // Logout
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: LocaleKeys.exit.tr(),
                    onTap: () => _showLogoutDialog(context, shiftCubit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? AppColors.darkGray;
    final iColor = iconColor ?? AppColors.shadowGray;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 20),
          vertical: ResponsiveUI.padding(context, 14),
        ),
        child: Row(
          children: [
            Icon(icon, size: ResponsiveUI.iconSize(context, 22), color: iColor),
            SizedBox(width: ResponsiveUI.spacing(context, 16)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 15),
                color: color,
                fontWeight: labelColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
