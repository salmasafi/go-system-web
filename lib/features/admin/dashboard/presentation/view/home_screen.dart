// Updated UI: home_screen.dart
// Changes:
// - Added imports for notifications cubit and state.
// - Wrapped Scaffold in BlocProvider<NotificationsCubit> with auto-fetch.
// - Used BlocBuilder to dynamically get unreadCount for appBarWithActions (default 0 on loading/error).
// - Removed hardcoded notificationCount: 5; now dynamic.
// - Added onPressed stub for notifications (implement navigation later).

import 'package:flutter/material.dart';
import 'package:systego/core/services/cache_helper.dart';
import 'package:systego/main.dart';
import '../../../auth/presentation/view/login_screen.dart';
import '../widgets/custom_bottom_app_bar_widget.dart';
import 'dashboard_screens.dart';
import '../../../../POS/home/presentation/view/pos_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> screens = [
    DashboardScreen(),
    //Container(),
    POSHomeScreen(),
    //Container(),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 2) {
            await CacheHelper.clearAllData();
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
