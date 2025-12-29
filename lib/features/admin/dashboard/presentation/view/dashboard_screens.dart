import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/adjustment/presentation/view/adjustments_screen.dart';
import 'package:systego/features/admin/admins_screen/presentation/view/admins_screen.dart';
import 'package:systego/features/admin/bank_account/presentation/view/bank_accounts_screen.dart';
import 'package:systego/features/admin/brands/view/brands_screen.dart';
import 'package:systego/features/admin/cashier/presentation/view/cashier_screen.dart';
import 'package:systego/features/admin/categories/view/categories_screen.dart';
import 'package:systego/features/admin/city/presentation/view/cities_screen.dart';
import 'package:systego/features/admin/country/presentation/view/countries_screen.dart';
import 'package:systego/features/admin/coupon/presentation/view/coupons_screen.dart';
import 'package:systego/features/admin/currency/presentation/view/currencies_screen.dart';
import 'package:systego/features/admin/discount/presentation/view/discounts_screen.dart';
import 'package:systego/features/admin/expences_category/presentation/view/expences_categories_screen.dart';
import 'package:systego/features/admin/popup/presentation/view/popup_screen.dart';
import 'package:systego/features/admin/product/presentation/screens/products_screen.dart';
import 'package:systego/features/admin/reason/presentation/view/reasons_screen.dart';
import 'package:systego/features/admin/suppliers/view/supplier_screen.dart';
import 'package:systego/features/admin/taxes/presentation/view/taxes_screen.dart';
import 'package:systego/features/admin/variations/presentation/view/variation_screen.dart';
import 'package:systego/features/admin/warehouses/view/warehouses_screen.dart';
import 'package:systego/features/admin/zone/presentation/view/zones_screen.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_bar_widgets.dart';
import '../../../payment_methods/presentation/view/payment_methods_screen.dart';
import '../../cubit/notifications_cubit.dart';
import '../widgets/custom_grid_card_widget.dart';
import 'notifications_screen.dart';
import 'package:systego/features/admin/revenue/presentation/view/revenue_screen.dart';
import 'package:systego/features/admin/customer_group/presentation/view/customers_group_screen.dart';
import 'package:systego/features/admin/customer/presentation/view/customers_screens.dart';
import 'package:systego/features/admin/roloes_and_permissions/presentation/view/roles_screen.dart';
import 'package:systego/features/admin/pandel/presentation/view/pandel_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _refresh() async {
    await context.read<NotificationsCubit>().getNotifications();
  }

  // final cardItems = [
  //   // {'icon': Icons.grid_view_rounded, 'label': 'Categories'},
  //   // {'icon': Icons.inventory_2_rounded, 'label': 'Products'},
  //   // {'icon': Icons.local_offer_rounded, 'label': 'Brands'},
  //   {'icon': Icons.warehouse_rounded, 'label': 'Warehouses'},
  //   //{'icon': Icons.shopping_cart_rounded, 'label': 'Purchase'},
  //   //  {'icon': Icons.factory, 'label': 'Suppliers'},
  //   {'icon': Icons.list_alt, 'label': 'Variations'},
  //   // {'icon': Icons.monetization_on_rounded, 'label': 'Currencies'},
  //   // {'icon': Icons.location_on_rounded, 'label': 'Countries'},
  //   // {'icon': Icons.location_city_rounded, 'label': 'Cities'},
  //   // {'icon': Icons.gps_fixed, 'label': 'Zones'},
  //   // {'icon': Icons.attach_money_rounded, 'label': 'Payment Methods'},
  //   {'icon': Icons.receipt_long, 'label': 'Taxes'},
  //   {'icon': Icons.account_balance, 'label': 'Financial Accounts'},
  //   {'icon': Icons.open_in_new, 'label': 'Pop Ups'},
  //   {'icon': Icons.local_offer, 'label': 'Coupons'},
  //   // {'icon': Icons.business, 'label': 'Departments'},
  //   {'icon': Icons.local_offer, 'label': 'Discounts'},
  //   // {'icon': Icons.business, 'label': 'Permissions'},
  //   {'icon': Icons.business, 'label': 'Adjustment Reasons'},
  //   {'icon': Icons.business, 'label': 'Adjustments'},
  //   {'icon': Icons.business, 'label': 'Admins'},
  //   {'icon': Icons.business, 'label': 'Cashiers'},
  //   {'icon': Icons.business, 'label': 'Expences Categories'},
  // ];

  final cardItems = [
    {
      'icon': Icons.grid_view_rounded,
      'label': 'Categories',
      'id': DashboardItem.categories,
    },
    {
      'icon': Icons.inventory_2_rounded,
      'label': 'Products',
      'id': DashboardItem.products,
    },
    {
      'icon': Icons.local_offer_rounded,
      'label': 'Brands',
      'id': DashboardItem.brands,
    },
    {
      'icon': Icons.factory,
      'label': 'Suppliers',
      'id': DashboardItem.suppliers,
    },
    {
      'icon': Icons.monetization_on_rounded,
      'label': 'Currencies',
      'id': DashboardItem.currencies,
    },
    {
      'icon': Icons.location_on_rounded,
      'label': 'Countries',
      'id': DashboardItem.countries,
    },
    {
      'icon': Icons.location_city_rounded,
      'label': 'Cities',
      'id': DashboardItem.cities,
    },
    {'icon': Icons.gps_fixed, 'label': 'Zones', 'id': DashboardItem.zones},
    {
      'icon': Icons.warehouse_rounded,
      'label': LocaleKeys.warehouses.tr(),
      'id': DashboardItem.warehouses,
    },
    {
      'icon': Icons.list_alt,
      'label': LocaleKeys.variations_title.tr(),
      'id': DashboardItem.variations,
    },
    {
      'icon': Icons.receipt_long,
      'label': LocaleKeys.taxes.tr(),
      'id': DashboardItem.taxes,
    },
    {
      'icon': Icons.account_balance,
      'label': LocaleKeys.financial_accounts.tr(),
      'id': DashboardItem.financialAccounts,
    },
    {
      'icon': Icons.open_in_new,
      'label': LocaleKeys.popups_title.tr(),
      'id': DashboardItem.popups,
    },
    {
      'icon': Icons.local_offer,
      'label': LocaleKeys.coupons_title.tr(),
      'id': DashboardItem.coupons,
    },
    {
      'icon': Icons.local_offer,
      'label': LocaleKeys.discounts_title.tr(),
      'id': DashboardItem.discounts,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.reasons.tr(),
      'id': DashboardItem.reasons,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.adjustments.tr(),
      'id': DashboardItem.adjustments,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.admins.tr(),
      'id': DashboardItem.admins,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.cashiers_title.tr(),
      'id': DashboardItem.cashiers,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.expense_categories_title.tr(),
      'id': DashboardItem.expenseCategories,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.revenues_title.tr(),
      'id': DashboardItem.revenue,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.customer_groups_title.tr(),
      'id': DashboardItem.customerGroups,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.customers_title.tr(),
      'id': DashboardItem.customers,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.roles_title.tr(),
      'id': DashboardItem.roles,
    },
    {
      'icon': Icons.business,
      'label': LocaleKeys.payment_methods_screen_title.tr(),
      'id': DashboardItem.payment,
    },  {
      'icon': Icons.business,
      'label': LocaleKeys.pandels_title.tr(),
      'id': DashboardItem.pandels,
    },
  ];

  void _navigateToPage(DashboardItem id) {
    switch (id) {
      case DashboardItem.brands:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BrandsScreen()),
        );
        break;
      case DashboardItem.countries:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CountriessScreen()),
        );
        break;
      case DashboardItem.cities:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitiesScreen()),
        );
        break;
      case DashboardItem.zones:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZonesScreen()),
        );
        break;
      case DashboardItem.suppliers:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupplierScreen()),
        );
        break;
      case DashboardItem.currencies:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CurrenciesScreen()),
        );
        break;
      case DashboardItem.products:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductsScreen()),
        );
        break;
      case DashboardItem.categories:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
        );
        break;
      case DashboardItem.warehouses:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WarehousesScreen()),
        );
        break;
      case DashboardItem.variations:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VariationScreen()),
        );
        break;
      case DashboardItem.taxes:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaxesScreen()),
        );
        break;
      case DashboardItem.financialAccounts:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BankAccountsScreen()),
        );
        break;
      case DashboardItem.popups:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PopupScreen()),
        );
        break;
      case DashboardItem.coupons:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CouponsScreen()),
        );
        break;
      case DashboardItem.discounts:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DiscountsScreen()),
        );
        break;
      case DashboardItem.reasons:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReasonsScreen()),
        );
        break;
      case DashboardItem.adjustments:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdjustmentsScreen()),
        );
        break;
      case DashboardItem.admins:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminsScreen()),
        );
        break;
      case DashboardItem.cashiers:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CashiersScreen()),
        );
        break;
      case DashboardItem.expenseCategories:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpenseCategoriesScreen()),
        ); // Note: Fix 'expences' typo in import if it's ExpencesCategoriesScreen
        break;
      case DashboardItem.revenue:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RevenueScreen()),
        );
        break;

      case DashboardItem.customerGroups:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerGroupsScreen()),
        );
        break;
      case DashboardItem.customers:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerScreen()),
        );
        break;

      case DashboardItem.roles:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RolesScreen()),
        );
        break;

      case DashboardItem.payment:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
        );
        break;
    case DashboardItem.pandels:
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PandelScreen()));  // Note: Fix 'expences' typo in import if it's ExpencesCategoriesScreen
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
            title: LocaleKeys.dashboard.tr(),
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
                  // return CustomGridCard(
                  //   icon: item['icon'] as IconData,
                  //   label: item['label'] as String,
                  //   onTap: () => _navigateToPage(item['label'] as String),
                  //   delay: Duration(milliseconds: 200 + (index * 150)),
                  // );
                  return CustomGridCard(
                    icon: item['icon'] as IconData,
                    label: item['label'] as String,
                    onTap: () => _navigateToPage(item['id'] as DashboardItem),
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

enum DashboardItem {
  categories,
  brands,
  products,
  suppliers,
  currencies,
  countries,
  cities,
  zones,
  warehouses,
  variations,
  taxes,
  financialAccounts,
  popups,
  coupons,
  discounts,
  reasons,
  adjustments,
  admins,
  cashiers,
  expenseCategories,
  revenue,
  customerGroups,
  pandels,
  customers,
  roles,
  payment,
  // Add more as needed
}
