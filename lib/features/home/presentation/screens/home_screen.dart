import 'package:flutter/material.dart';
import 'package:systego/features/product/presentation/screens/products_screen.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/warehouses_screen.dart';

import '../widgets/custom_bottom_app_bar_widget.dart';
import '../widgets/custom_grid_card_widget.dart';
import 'brands_screen/view/brands_screen.dart';
import 'categories_screen/view/categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final cardItems = [
    {'icon': Icons.grid_view_rounded, 'label': 'Categories'},
    {'icon': Icons.inventory_2_rounded, 'label': 'Products'},
    {'icon': Icons.local_offer_rounded, 'label': 'Brands'},
    {'icon': Icons.warehouse_rounded, 'label': 'Warehouses'},
  ];
  void _navigateToPage(String label) {
    final screenName = '${label}Screen';

    switch (screenName) {
      case 'CategoriesScreen':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
        break;
      case 'ProductsScreen':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
        break;
      case 'BrandsScreen':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandsScreen()));
        break;
      case 'WarehousesScreen':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WarehousesScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No screen found for $label')),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // This prevents the bottom bar from moving up/down with keyboard
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
        child: GridView.builder(
          itemCount: cardItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = cardItems[index];
            return CustomGridCard(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              onTap: () => _navigateToPage(item['label'] as String),
              delay: Duration(milliseconds: 200 + (index * 150)), // Staggered animation
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}