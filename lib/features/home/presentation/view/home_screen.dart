// Updated UI: home_screen.dart
// Changes:
// - Added imports for notifications cubit and state.
// - Wrapped Scaffold in BlocProvider<NotificationsCubit> with auto-fetch.
// - Used BlocBuilder to dynamically get unreadCount for appBarWithActions (default 0 on loading/error).
// - Removed hardcoded notificationCount: 5; now dynamic.
// - Added onPressed stub for notifications (implement navigation later).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/services/cache_helper.dart.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/city/presentation/view/cities_screen.dart';
import 'package:systego/features/country/presentation/view/countries_screen.dart';
import 'package:systego/features/currency/presentation/view/currencies_screen.dart';
import 'package:systego/features/purchase/view/purchase_screen.dart';
import 'package:systego/features/suppliers/view/supplier_screen.dart';
import 'package:systego/features/warehouses/view/warehouses_screen.dart';
import 'package:systego/main.dart';
import '../../../../core/widgets/app_bar_widgets.dart';
import '../../../auth/presentation/view/login_screen.dart';
import '../../../payment_methods/presentation/view/payment_methods_screen.dart';
import '../../../product/presentation/screens/products_screen.dart';
import '../../../zone/presentation/view/zones_screen.dart';
import '../../cubit/notifications_cubit.dart';
import '../widgets/custom_bottom_app_bar_widget.dart';
import '../widgets/custom_grid_card_widget.dart';
import '../../../brands/view/brands_screen.dart';
import '../../../categories/view/categories_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refresh() async {
    // setState(() {
    //   _searchQuery = '';
    // });
    await context.read<NotificationsCubit>().getNotifications();
  }

  int _currentIndex = 0;

  final cardItems = [
    {'icon': Icons.grid_view_rounded, 'label': 'Categories'},
    {'icon': Icons.inventory_2_rounded, 'label': 'Products'},
    {'icon': Icons.local_offer_rounded, 'label': 'Brands'},
    {'icon': Icons.warehouse_rounded, 'label': 'Warehouses'},
    {'icon': Icons.shopping_cart_rounded, 'label': 'Purchase'},
    {'icon': Icons.factory, 'label': 'Suppliers'},
    {'icon': Icons.type_specimen, 'label': 'Variations'},
    {'icon': Icons.monetization_on_rounded, 'label': 'Currencies'},
    {'icon': Icons.location_on_rounded, 'label': 'Countries'},
    {'icon': Icons.location_city_rounded, 'label': 'Cities'},
    {'icon': Icons.gps_fixed, 'label': 'Zones'},
    {'icon': Icons.attach_money_rounded, 'label': 'Payment Methods'},
  ];

  void _navigateToPage(String label) {
    switch (label) {
      case 'Categories':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
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

      case 'Currencies':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CurrenciesScreen()),
        );
        break;

      case 'Countries':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CountriessScreen()),
        );
        break;

      case 'Cities':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitiesScreen()),
        );
        break;

      case 'Zones':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZonesScreen()),
        );
        break;

      case 'Payment Methods':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
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
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsSuccess
            ? state.unreadCount
            : 0;

        return Scaffold(
          appBar: appBarWithActions(
            context,
            backgroundColor: AppColors.shadowGray[50],
            actionIcon: Icons.notifications,
            showActions: true,
            showBackButton: false,
            title: 'Dashboard',
            notificationCount: unreadCount, // Dynamic unread count
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          backgroundColor: AppColors.shadowGray[50],
          body: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: Padding(
              padding: EdgeInsets.only(
                right: ResponsiveUI.horizontalPadding(context),
                left: ResponsiveUI.horizontalPadding(context),
                bottom: ResponsiveUI.padding(context, 40),
                top: ResponsiveUI.padding(context, 20),
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
          ),
          bottomNavigationBar: CustomBottomAppBar(
            currentIndex: _currentIndex,
            onTap: (index) async {
              if (index == 4) {
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
      },
    );
  }
}
