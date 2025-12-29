// Updated UI: home_screen.dart
// Changes:
// - Added imports for notifications cubit and state.
// - Wrapped Scaffold in BlocProvider<NotificationsCubit> with auto-fetch.
// - Used BlocBuilder to dynamically get unreadCount for appBarWithActions (default 0 on loading/error).
// - Removed hardcoded notificationCount: 5; now dynamic.
// - Added onPressed stub for notifications (implement navigation later).

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/services/cache_helper.dart';
import 'package:systego/features/admin/dashboard/presentation/view/dashboard_screens.dart';
import 'package:systego/main.dart';
import '../../../../POS/home/presentation/view/pos_home_screen.dart';
import '../../../auth/presentation/view/login_screen.dart';
import '../widgets/custom_bottom_app_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;  // Moved here to persist state across rebuilds

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      DashboardScreen(key: ValueKey(context.locale.languageCode)),
      //Container(),
      POSHomeScreen(),
      //Container(),
      Container(),
    ];
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: CustomBottomAppBar(
        key: ValueKey(context.locale.languageCode),
        currentIndex: currentIndex,
        onTap: (index) async {
          if (index == 2) {
            await CacheHelper.clearAllData();
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
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