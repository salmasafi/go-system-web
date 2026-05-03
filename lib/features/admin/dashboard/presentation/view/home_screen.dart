import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/services/cache_helper.dart';
import 'package:GoSystem/features/admin/dashboard/cubit/notifications_cubit.dart';
import 'package:GoSystem/features/admin/dashboard/presentation/view/dashboard_screens.dart';
import 'package:GoSystem/features/admin/settings/presentation/settings_screen.dart';
import 'package:GoSystem/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/main.dart';
import '../../../../pos/home/presentation/view/pos_home_screen.dart';
import '../../../../pos/online_orders/cubit/online_orders_cubit.dart';
import '../../../../pos/online_orders/presentation/view/online_orders_screen.dart';
import '../../../auth/presentation/view/login_screen.dart';
import '../widgets/custom_bottom_app_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tabs: 0=Dashboard, 1=OnlineOrders, 2=POS (center), 3=Settings, 4=Logout
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsCubit>().getNotifications();
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.exit.tr(),
        message: LocaleKeys.exit_confirmation_message.tr(),
        icon: Icons.exit_to_app_rounded,
        iconColor: AppColors.primaryBlue,
        deleteText: LocaleKeys.exit.tr(),
        onDelete: () async {
          Navigator.pop(dialogContext);
          await CacheHelper.clearAllData();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only 4 navigable screens (logout is a dialog, not a screen)
    final List<Widget> screens = [
      DashboardScreen(key: ValueKey(context.locale.languageCode)),
      BlocProvider(
        create: (_) => OnlineOrdersCubit(),
        child: const OnlineOrdersScreen(),
      ),
      const POSHomeScreen(),
      const SettingsScreen(),
    ];

    // Map tab index to screen index (logout tab 4 has no screen)
    final screenIndex = currentIndex < 4 ? currentIndex : 3;

    Widget bodyContent = IndexedStack(
      index: screenIndex,
      children: screens,
    );

    // For web: scale down by using smaller MediaQuery
    if (kIsWeb) {
      bodyContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: bodyContent,
      );
    }

    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: CustomBottomAppBar(
        key: ValueKey(context.locale.languageCode),
        currentIndex: currentIndex > 3 ? 3 : currentIndex,
        onTap: (index) {
          if (index == 4) {
            _showLogoutDialog();
            // Don't update currentIndex — stay on current screen
          } else {
            setState(() {
              currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
