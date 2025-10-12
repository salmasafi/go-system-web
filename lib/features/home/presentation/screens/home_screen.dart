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
          size: ResponsiveUI.iconSize(context, 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: ResponsiveUI.value(context, 80),
        color: Colors.blue[50],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Dashboard
            Expanded(
              child: NavBarItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                color: Colors.blue,
                onPressed: () {
                  // Handle dashboard tap
                },
              ),
            ),
            // Product
            Expanded(
              child: NavBarItem(
                icon: Icons.category,
                label: 'Product',
                color: Colors.blue,
                onPressed: () {
                  // Handle product tap
                },
              ),
            ),
            // Spacer for FAB (responsive)
            SizedBox(width: ResponsiveUI.value(context, 60)),
            // Reports
            Expanded(
              child: NavBarItem(
                icon: Icons.bar_chart,
                label: 'Reports',
                color: Colors.purple,
                onPressed: () {
                  // Handle reports tap
                },
              ),
            ),
            // More
            Expanded(
              child: NavBarItem(
                icon: Icons.more_horiz,
                label: 'More',
                color: Colors.blue,
                onPressed: () {
                  // Handle more tap
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: color,
            size: ResponsiveUI.iconSize(context, 24),
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}