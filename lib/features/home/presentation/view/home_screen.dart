import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/services/cache_helper.dart.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/purchase/view/purchase_screen.dart';
import 'package:systego/features/suppliers/view/supplier_screen.dart';
import 'package:systego/features/warehouses/view/warehouses_screen.dart';
import 'package:systego/main.dart';
import '../../../auth/presentation/view/login_screen.dart';
import '../../../product/presentation/screens/products_screen.dart';
import '../widgets/custom_bottom_app_bar_widget.dart';
import '../widgets/custom_grid_card_widget.dart';
import '../../../brands/view/brands_screen.dart';
import '../../../categories/cubit/categories_cubit.dart';
import '../../../categories/view/categories_screen.dart';

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
    {'icon': Icons.shopping_cart_rounded, 'label': 'Purchase'},
    {'icon': Icons.factory, 'label': 'Suppliers'},
    {'icon': Icons.type_specimen, 'label': 'Variations'},
  ];

  void _navigateToPage(String label) {
    switch (label) {
      case 'Categories':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => CategoriesCubit(),
              child: const CategoriesScreen(),
            ),
          ),
        );
        break;

      case 'Products':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductsScreen()),
        );
        break;

      case 'Brands':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BrandsScreen()),
        );
        break;

      case 'Warehouses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WarehousesScreen()),
        );
        break;

      case 'Purchase':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PurchaseScreen()),
        );
        break;

      case 'Suppliers':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupplierScreen()),
        );
        break;

      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No screen found for $label')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.shadowGray[50],
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.horizontalPadding(context),
          vertical: ResponsiveUI.padding(context, 40),
        ),
        child: GridView.builder(
          itemCount: cardItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: ResponsiveUI.spacing(context, 16),
            crossAxisSpacing: ResponsiveUI.spacing(context, 16),
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = cardItems[index];
            return CustomGridCard(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              onTap: () => _navigateToPage(item['label'] as String),
              delay: Duration(milliseconds: 200 + (index * 150)),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 2) {
            await CacheHelper.clearAllData();
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
