import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Home Screen Content'), // Placeholder for body content
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle print action
        },
        backgroundColor: Colors.purple,
        child: Icon(
          Icons.print,
          color: Colors.white,
          size: ResponsiveUI.iconSize(context),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: ResponsiveUI.bottomNavHeight(context),
        color: Colors.blue[50],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Dashboard
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.dashboard,
                      color: Colors.blue,
                      size: ResponsiveUI.iconSize(context),
                    ),
                    onPressed: () {
                      // Handle dashboard tap
                    },
                  ),
                  Text(
                    'Dashboard',
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context)),
                  ),
                ],
              ),
            ),
            // Product
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.category,
                      color: Colors.blue,
                      size: ResponsiveUI.iconSize(context),
                    ),
                    onPressed: () {
                      // Handle product tap
                    },
                  ),
                  Text(
                    'Product',
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context)),
                  ),
                ],
              ),
            ),
            // Spacer for FAB (responsive)
            SizedBox(width: ResponsiveUI.fabNotchSpacer(context)),
            // Reports
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart,
                      color: Colors.purple,
                      size: ResponsiveUI.iconSize(context),
                    ),
                    onPressed: () {
                      // Handle reports tap
                    },
                  ),
                  Text(
                    'Reports',
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context)),
                  ),
                ],
              ),
            ),
            // More
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.blue,
                      size: ResponsiveUI.iconSize(context),
                    ),
                    onPressed: () {
                      // Handle more tap
                    },
                  ),
                  Text(
                    'More',
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context)),
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