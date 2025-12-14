import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/adjustment/presentation/view/adjustments_screen.dart';
import 'package:systego/features/admin/bank_account/presentation/view/bank_accounts_screen.dart';
import 'package:systego/features/admin/city/presentation/view/cities_screen.dart';
import 'package:systego/features/admin/country/presentation/view/countries_screen.dart';
import 'package:systego/features/admin/coupon/presentation/view/coupons_screen.dart';
import 'package:systego/features/admin/currency/presentation/view/currencies_screen.dart';
import 'package:systego/features/admin/department/presentation/view/departments_screen.dart';
import 'package:systego/features/admin/discount/presentation/view/discounts_screen.dart';
import 'package:systego/features/admin/permission/presentation/view/permissions_screen.dart';
import 'package:systego/features/admin/popup/presentation/view/popup_screen.dart';
import 'package:systego/features/admin/reason/presentation/view/reasons_screen.dart';
import 'package:systego/features/admin/suppliers/view/supplier_screen.dart';
import 'package:systego/features/admin/taxes/presentation/view/taxes_screen.dart';
import 'package:systego/features/admin/variations/presentation/view/variation_screen.dart';
import 'package:systego/features/admin/warehouses/view/warehouses_screen.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_bar_widgets.dart';
import '../../../../home/presentation/view/notifications_screen.dart';
import '../../../payment_methods/presentation/view/payment_methods_screen.dart';
import '../../../product/presentation/screens/products_screen.dart';
import '../../../zone/presentation/view/zones_screen.dart';
import '../../../../home/cubit/notifications_cubit.dart';
import '../widgets/custom_grid_card_widget.dart';
import '../../../brands/view/brands_screen.dart';
import '../../../categories/view/categories_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _refresh() async {
    // setState(() {
    //   _searchQuery = '';
    // });
    await context.read<NotificationsCubit>().getNotifications();
  }

  final cardItems = [
    {'icon': Icons.grid_view_rounded, 'label': 'Categories'},
    {'icon': Icons.inventory_2_rounded, 'label': 'Products'},
    {'icon': Icons.local_offer_rounded, 'label': 'Brands'},
    {'icon': Icons.warehouse_rounded, 'label': 'Warehouses'},
    //{'icon': Icons.shopping_cart_rounded, 'label': 'Purchase'},
    {'icon': Icons.factory, 'label': 'Suppliers'},
    {'icon': Icons.list_alt, 'label': 'Variations'},
    {'icon': Icons.monetization_on_rounded, 'label': 'Currencies'},
    {'icon': Icons.location_on_rounded, 'label': 'Countries'},
    {'icon': Icons.location_city_rounded, 'label': 'Cities'},
    {'icon': Icons.gps_fixed, 'label': 'Zones'},
    // {'icon': Icons.attach_money_rounded, 'label': 'Payment Methods'},
    {'icon': Icons.receipt_long, 'label': 'Taxes'},
    {'icon': Icons.account_balance, 'label': 'Financial Accounts'},
    {'icon': Icons.open_in_new, 'label': 'Pop Ups'},
    {'icon': Icons.local_offer, 'label': 'Coupons'},
    // {'icon': Icons.business, 'label': 'Departments'},
    {'icon': Icons.local_offer, 'label': 'Discounts'},
    {'icon': Icons.business, 'label': 'Permissions'},
    {'icon': Icons.business, 'label': 'Adjustment Reasons'},
    {'icon': Icons.business, 'label': 'Adjustments'},
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

      // case 'Purchase':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (_) => const PurchaseScreen()),
      //   );
      //   break;

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

      case 'Taxes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaxesScreen()),
        );
        break;

      case 'Financial Accounts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BankAccountsScreen()),
        );
        break;

      case 'Pop Ups':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PopupScreen()),
        );
        break;

       case 'Coupons':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CouponsScreen()),
        );
        break;

      case 'Departments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DepartmentScreen()),
        );
        break;

      case 'Variations':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VariationScreen()),
        );
        break;

      case 'Discounts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DiscountsScreen()),
        );
        break;

      case 'Permissions':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PermissionScreen()),
        );
        break;

       case 'Adjustment Reasons':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReasonsScreen()),
        );
        break;

      case 'Adjustments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdjustmentsScreen()),
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
        );
      },
    );
  }
}
