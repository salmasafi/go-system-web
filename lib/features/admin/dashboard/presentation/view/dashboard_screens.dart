import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:GoSystem/features/admin/adjustment/presentation/view/adjustments_screen.dart';
import 'package:GoSystem/features/admin/admins_screen/presentation/view/admins_screen.dart';
import 'package:GoSystem/features/admin/bank_account/presentation/view/bank_accounts_screen.dart';
import 'package:GoSystem/features/admin/brands/view/brands_screen.dart';
import 'package:GoSystem/features/admin/cashier/presentation/view/cashier_screen.dart';
import 'package:GoSystem/features/admin/categories/view/categories_screen.dart';
import 'package:GoSystem/features/admin/city/presentation/view/cities_screen.dart';
import 'package:GoSystem/features/admin/country/presentation/view/countries_screen.dart';
import 'package:GoSystem/features/admin/coupon/presentation/view/coupons_screen.dart';
import 'package:GoSystem/features/admin/currency/presentation/view/currencies_screen.dart';
import 'package:GoSystem/features/admin/discount/presentation/view/discounts_screen.dart';
import 'package:GoSystem/features/admin/expences_category/presentation/view/expences_categories_screen.dart';
import 'package:GoSystem/features/admin/points/cubit/points_cubit.dart';
import 'package:GoSystem/features/admin/points/presentation/view/points_screen.dart';
import 'package:GoSystem/features/admin/popup/presentation/view/popup_screen.dart';
import 'package:GoSystem/features/admin/print_labels/presentation/view/print_labels_screen.dart';
import 'package:GoSystem/features/admin/product/presentation/screens/products_screen.dart';
import 'package:GoSystem/features/admin/purchase/presentation/view/purchase_screen.dart';
import 'package:GoSystem/features/admin/reason/presentation/view/reasons_screen.dart';
import 'package:GoSystem/features/admin/redeem_points/cubit/redeem_points_cubit.dart';
import 'package:GoSystem/features/admin/redeem_points/presentation/view/redeem_points_screen.dart';
import 'package:GoSystem/features/admin/suppliers/view/supplier_screen.dart';
import 'package:GoSystem/features/admin/taxes/presentation/view/taxes_screen.dart';
import 'package:GoSystem/features/admin/transfer/presentation/view/transfers_screen.dart';
import 'package:GoSystem/features/admin/units/cubit/units_cubit.dart';
import 'package:GoSystem/features/admin/units/presentation/view/units_screen.dart';
import 'package:GoSystem/features/admin/variations/presentation/view/variation_screen.dart';
import 'package:GoSystem/features/admin/warehouses/view/warehouses_screen.dart';
import 'package:GoSystem/features/admin/zone/presentation/view/zones_screen.dart';
import 'package:GoSystem/features/admin/permission/presentation/view/permissions_screen.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_bar_widgets.dart';
import '../../../payment_methods/presentation/view/payment_methods_screen.dart';
import '../../cubit/notifications_cubit.dart';
import 'notifications_screen.dart';
import 'package:GoSystem/features/admin/revenue/presentation/view/revenue_screen.dart';
import 'package:GoSystem/features/admin/customer_group/presentation/view/customers_group_screen.dart';
import 'package:GoSystem/features/admin/customer/presentation/view/customers_screens.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/presentation/view/roles_screen.dart';
import 'package:GoSystem/features/admin/pandel/presentation/view/pandel_screen.dart';
import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:GoSystem/features/admin/purchase_returns/cubit/purchase_return_cubit.dart';
import 'package:GoSystem/features/admin/purchase_returns/presentation/view/purchase_returns_screen.dart';
import 'package:GoSystem/features/admin/expense_admin/presentation/view/expense_admin_screen.dart';
import 'package:GoSystem/features/admin/expense_admin/cubit/expense_admin_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/filter_product_cubit/product_filter_cubit.dart';
import 'package:GoSystem/features/admin/brands/cubit/brand_cubit.dart';
import 'package:GoSystem/features/admin/categories/cubit/categories_cubit.dart';
import 'package:GoSystem/features/admin/variations/cubit/variation_cubit.dart';
import 'package:GoSystem/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:GoSystem/features/admin/discount/cubit/discount_cubit.dart';
import 'package:GoSystem/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:GoSystem/features/admin/revenue/cubit/revenue_cubit.dart';
import 'package:GoSystem/features/admin/payment_methods/cubit/payment_method_cubit.dart';
import 'package:GoSystem/features/admin/popup/cubit/popup_cubit.dart';
import 'package:GoSystem/features/admin/coupon/cubit/coupon_cubit.dart';
import 'package:GoSystem/features/admin/city/cubit/city_cubit.dart';
import 'package:GoSystem/features/admin/country/cubit/country_cubit.dart';
import 'package:GoSystem/features/admin/zone/cubit/zone_cubit.dart';
import 'package:GoSystem/features/admin/permission/cubit/permission_cubit.dart';
import 'package:GoSystem/features/admin/currency/cubit/currency_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:GoSystem/features/admin/adjustment/cubit/adjustment_cubit.dart';
import 'package:GoSystem/features/admin/reason/cubit/reason_cubit.dart';
import 'package:GoSystem/features/admin/customer/cubit/customer_cubit.dart';
import 'package:GoSystem/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:GoSystem/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:GoSystem/features/admin/pandel/cubit/pandel_cubit.dart';

// ─── Repository Imports ───────────────────────────────────────
import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';
import 'package:GoSystem/features/admin/categories/data/repositories/category_repository.dart';
import 'package:GoSystem/features/admin/brands/data/repositories/brand_repository.dart';
import 'package:GoSystem/features/admin/variations/data/repositories/variation_repository.dart';
import 'package:GoSystem/features/admin/units/data/repositories/unit_repository.dart';
import 'package:GoSystem/features/admin/taxes/data/repositories/tax_repository.dart';
import 'package:GoSystem/features/admin/discount/data/repositories/discount_repository.dart';
import 'package:GoSystem/features/admin/expences_category/data/repositories/expense_category_repository.dart';
import 'package:GoSystem/features/admin/revenue/data/repositories/revenue_repository.dart';
import 'package:GoSystem/features/admin/payment_methods/data/repositories/payment_method_repository.dart';
import 'package:GoSystem/features/admin/popup/data/repositories/popup_repository.dart';
import 'package:GoSystem/features/admin/coupon/data/repositories/coupon_repository.dart';
import 'package:GoSystem/features/admin/city/data/repositories/city_repository.dart';
import 'package:GoSystem/features/admin/country/data/repositories/country_repository.dart';
import 'package:GoSystem/features/admin/zone/data/repositories/zone_repository.dart';
import 'package:GoSystem/features/admin/permission/data/repositories/permission_repository.dart';
import 'package:GoSystem/features/admin/currency/data/repositories/currency_repository.dart';
import 'package:GoSystem/features/admin/warehouses/data/repositories/warehouse_repository.dart';
import 'package:GoSystem/features/admin/purchase/data/repositories/purchase_repository.dart';
import 'package:GoSystem/features/admin/purchase_returns/data/repositories/purchase_return_repository.dart';
import 'package:GoSystem/features/admin/adjustment/data/repositories/adjustment_repository.dart';
import 'package:GoSystem/features/admin/reason/data/repositories/reason_repository.dart';
import 'package:GoSystem/features/admin/customer/data/repositories/customer_repository.dart';
import 'package:GoSystem/features/admin/admins_screen/data/repositories/admin_repository.dart';
import 'package:GoSystem/features/admin/cashier/data/repositories/cashier_repository.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/data/repositories/role_repository.dart';
import 'package:GoSystem/features/admin/pandel/data/repositories/bundle_repository.dart';
import 'package:GoSystem/features/admin/bank_account/data/repositories/bank_account_repository.dart';
import 'package:GoSystem/features/admin/points/data/repositories/points_repository.dart';
import 'package:GoSystem/features/admin/redeem_points/data/repositories/redeem_points_repository.dart';
import 'package:GoSystem/features/admin/expences/data/repositories/expense_repository.dart';

// ─── Reports Imports ────────────────────────────────────────
import 'package:GoSystem/features/admin/reports/presentation/view/sales_report_screen.dart';
import 'package:GoSystem/features/admin/reports/presentation/view/product_report_screen.dart';
import 'package:GoSystem/features/admin/reports/presentation/view/inventory_report_screen.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_cubit.dart';

// ─── Data Models ─────────────────────────────────────────────

enum DashboardItem {
  // Product Management
  products,
  categories,
  brands,
  attributes,
  units,
  printLabels,
  // Financial
  financialAccounts,
  taxes,
  discounts,
  expenses,
  expenseCategories,
  revenue,
  payment,
  payments,
  // Marketing
  popups,
  points,
  redeemPoints,
  bundles,
  coupons,
  // Settings
  barcode,
  cities,
  countries,
  zones,
  permissions,
  currencies,
  decimalSettings,
  serviceFees,
  couriers,
  // Inventory
  warehouses,
  transfers,
  purchase,
  returns,
  adjustments,
  reasons,
  // CRM
  suppliers,
  customers,
  customerGroups,
  // HRM
  admins,
  cashiers,
  roles,
  departments,
  // Reports
  salesReport,
  inventoryReport,
  financialReport,
  customerReport,
  productReport,
  expensesReport,
  revenueReport,
}

class _ModuleItem {
  final IconData icon;
  final String label;
  final DashboardItem id;
  final bool comingSoon;

  const _ModuleItem({
    required this.icon,
    required this.label,
    required this.id,
    this.comingSoon = false,
  });
}

class _DashboardGroup {
  final IconData icon;
  final String title;
  final Color accentColor;
  final List<_ModuleItem> modules;

  const _DashboardGroup({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.modules,
  });
}

// ─── Main Screen ─────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Set<int> _expandedGroups = {};

  Future<void> _refresh() async {
    await context.read<NotificationsCubit>().getNotifications();
  }

  // ── Coming Soon modules ──────────────────────────────────

  static const _comingSoonItems = <DashboardItem>{
    DashboardItem.payments,
    DashboardItem.barcode,
    DashboardItem.departments,
    DashboardItem.decimalSettings,
    DashboardItem.serviceFees,
    DashboardItem.couriers,
    // Note: Reports are now implemented and available
  };

  // ─── Groups Definition ────────────────────────────────────

  List<_DashboardGroup> _buildGroups() {
    return [
      _DashboardGroup(
        icon: Icons.layers_rounded,
        title: LocaleKeys.product_management_group.tr(),
        accentColor: const Color(0xFF2E7D32),
        modules: [
          _ModuleItem(
            icon: Icons.inventory_2_rounded,
            label: LocaleKeys.products.tr(),
            id: DashboardItem.products,
          ),
          _ModuleItem(
            icon: Icons.grid_view_rounded,
            label: LocaleKeys.categories_title.tr(),
            id: DashboardItem.categories,
          ),
          _ModuleItem(
            icon: Icons.local_offer_rounded,
            label: LocaleKeys.brands_title.tr(),
            id: DashboardItem.brands,
          ),
          _ModuleItem(
            icon: Icons.tune_rounded,
            label: LocaleKeys.attributes_title.tr(),
            id: DashboardItem.attributes,
          ),
          _ModuleItem(
            icon: Icons.straighten_rounded,
            label: LocaleKeys.units_title.tr(),
            id: DashboardItem.units,
          ),
          _ModuleItem(
            icon: Icons.qr_code_rounded,
            label: LocaleKeys.print_labels_title.tr(),
            id: DashboardItem.printLabels,
          ),
        ],
      ),
      _DashboardGroup(
        icon: Icons.account_balance_wallet_rounded,
        title: LocaleKeys.financial_group.tr(),
        accentColor: const Color(0xFF8D1515),
        modules: [
          _ModuleItem(
            icon: Icons.account_balance_rounded,
            label: LocaleKeys.financial_accounts.tr(),
            id: DashboardItem.financialAccounts,
          ),
          _ModuleItem(
            icon: Icons.receipt_long_rounded,
            label: LocaleKeys.taxes.tr(),
            id: DashboardItem.taxes,
          ),
          _ModuleItem(
            icon: Icons.discount_rounded,
            label: LocaleKeys.discounts_title.tr(),
            id: DashboardItem.discounts,
          ),
          _ModuleItem(
            icon: Icons.money_off_rounded,
            label: LocaleKeys.expenses_title.tr(),
            id: DashboardItem.expenses,
          ),
          _ModuleItem(
            icon: Icons.category_rounded,
            label: LocaleKeys.expense_categories_title.tr(),
            id: DashboardItem.expenseCategories,
          ),
          _ModuleItem(
            icon: Icons.trending_up_rounded,
            label: LocaleKeys.revenues_title.tr(),
            id: DashboardItem.revenue,
          ),
          _ModuleItem(
            icon: Icons.payment_rounded,
            label: LocaleKeys.payment_methods_screen_title.tr(),
            id: DashboardItem.payment,
          ),
          _ModuleItem(
            icon: Icons.payments_rounded,
            label: LocaleKeys.payments_title.tr(),
            id: DashboardItem.payments,
            comingSoon: true,
          ),
        ],
      ),
      _DashboardGroup(
        icon: Icons.campaign_rounded,
        title: LocaleKeys.marketing_group.tr(),
        accentColor: const Color(0xFFE65100),
        modules: [
          _ModuleItem(
            icon: Icons.open_in_new_rounded,
            label: LocaleKeys.popups_title.tr(),
            id: DashboardItem.popups,
          ),
          _ModuleItem(
            icon: Icons.stars_rounded,
            label: LocaleKeys.points_title.tr(),
            id: DashboardItem.points,
          ),
          _ModuleItem(
            icon: Icons.redeem_rounded,
            label: LocaleKeys.redeem_points_title.tr(),
            id: DashboardItem.redeemPoints,
          ),
          _ModuleItem(
            icon: Icons.inventory_rounded,
            label: LocaleKeys.bundles_title.tr(),
            id: DashboardItem.bundles,
          ),
          _ModuleItem(
            icon: Icons.local_offer_rounded,
            label: LocaleKeys.coupons_title.tr(),
            id: DashboardItem.coupons,
          ),
        ],
      ),
      _DashboardGroup(
        icon: Icons.settings_rounded,
        title: LocaleKeys.settings_group.tr(),
        accentColor: const Color(0xFF546E7A),
        modules: [
          _ModuleItem(
            icon: Icons.qr_code_scanner_rounded,
            label: LocaleKeys.barcode_title.tr(),
            id: DashboardItem.barcode,
            comingSoon: true,
          ),
          _ModuleItem(
            icon: Icons.location_city_rounded,
            label: LocaleKeys.cities_title.tr(),
            id: DashboardItem.cities,
          ),
          _ModuleItem(
            icon: Icons.flag_rounded,
            label: LocaleKeys.countries_title.tr(),
            id: DashboardItem.countries,
          ),
          _ModuleItem(
            icon: Icons.gps_fixed_rounded,
            label: LocaleKeys.zones_screen_title.tr(),
            id: DashboardItem.zones,
          ),
          _ModuleItem(
            icon: Icons.lock_rounded,
            label: LocaleKeys.permissions.tr(),
            id: DashboardItem.permissions,
          ),
          _ModuleItem(
            icon: Icons.monetization_on_rounded,
            label: LocaleKeys.currencies_title.tr(),
            id: DashboardItem.currencies,
          ),
        ],
      ),
      _DashboardGroup(
        icon: Icons.warehouse_rounded,
        title: LocaleKeys.inventory_group.tr(),
        accentColor: const Color(0xFF6A1B9A),
        modules: [
          _ModuleItem(
            icon: Icons.warehouse_rounded,
            label: LocaleKeys.warehouses.tr(),
            id: DashboardItem.warehouses,
          ),
          _ModuleItem(
            icon: Icons.swap_horiz_rounded,
            label: LocaleKeys.transfers_title.tr(),
            id: DashboardItem.transfers,
          ),
          _ModuleItem(
            icon: Icons.shopping_cart_rounded,
            label: LocaleKeys.purchase_title.tr(),
            id: DashboardItem.purchase,
          ),
          _ModuleItem(
            icon: Icons.assignment_return_rounded,
            label: LocaleKeys.returns_title.tr(),
            id: DashboardItem.returns,
          ),
          _ModuleItem(
            icon: Icons.build_rounded,
            label: LocaleKeys.adjustments.tr(),
            id: DashboardItem.adjustments,
          ),
          _ModuleItem(
            icon: Icons.rule_rounded,
            label: LocaleKeys.reasons.tr(),
            id: DashboardItem.reasons,
          ),
        ],
      ),
      _DashboardGroup(
        icon: Icons.people_alt_rounded,
        title: LocaleKeys.crm_group.tr(),
        accentColor: const Color(0xFFC62828),
        modules: [
          _ModuleItem(
            icon: Icons.factory_rounded,
            label: LocaleKeys.suppliers_title.tr(),
            id: DashboardItem.suppliers,
          ),
          _ModuleItem(
            icon: Icons.person_rounded,
            label: LocaleKeys.customers_title.tr(),
            id: DashboardItem.customers,
          ),
          _ModuleItem(
            icon: Icons.group_rounded,
            label: LocaleKeys.customer_groups_title.tr(),
            id: DashboardItem.customerGroups,
          ),
        ],
      ),
      _DashboardGroup(
        icon: Icons.supervised_user_circle_rounded,
        title: LocaleKeys.hrm_group.tr(),
        accentColor: const Color(0xFF546E7A),
        modules: [
          _ModuleItem(
            icon: Icons.admin_panel_settings_rounded,
            label: LocaleKeys.admins.tr(),
            id: DashboardItem.admins,
          ),
          _ModuleItem(
            icon: Icons.point_of_sale_rounded,
            label: LocaleKeys.cashiers_title.tr(),
            id: DashboardItem.cashiers,
          ),
          _ModuleItem(
            icon: Icons.security_rounded,
            label: LocaleKeys.roles_title.tr(),
            id: DashboardItem.roles,
          ),
        ],
      ),
      _DashboardGroup(
        icon: Icons.bar_chart_rounded,
        title: LocaleKeys.reports_group.tr(),
        accentColor: const Color(0xFFFF8F00),
        modules: [
          _ModuleItem(
            icon: Icons.point_of_sale_rounded,
            label: LocaleKeys.cashier_shifts.tr(),
            id: DashboardItem.cashiers,
            comingSoon: true,
          ),
          _ModuleItem(
            icon: Icons.shopping_cart_rounded,
            label: LocaleKeys.orders_report.tr(),
            id: DashboardItem.salesReport,
          ),
          _ModuleItem(
            icon: Icons.assessment_rounded,
            label: LocaleKeys.product_report.tr(),
            id: DashboardItem.productReport,
          ),
          _ModuleItem(
            icon: Icons.account_balance_rounded,
            label: LocaleKeys.financial_report.tr(),
            id: DashboardItem.financialReport,
          ),
          _ModuleItem(
            icon: Icons.inventory_rounded,
            label: LocaleKeys.product_movement_report.tr(),
            id: DashboardItem.inventoryReport,
          ),
        ],
      ),
    ];
  }

  // ─── Navigation ───────────────────────────────────────────

  void _navigateToPage(DashboardItem id) {
    if (_comingSoonItems.contains(id)) {
      _showComingSoonDialog();
      return;
    }

    Widget? screen;
    switch (id) {
      case DashboardItem.products:
        screen = MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProductsCubit(ProductRepository())),
            BlocProvider(create: (_) => ProductFiltersCubit(ProductRepository())),
          ],
          child: const ProductsScreen(),
        );
        break;
      case DashboardItem.categories:
        screen = BlocProvider(
          create: (_) => CategoriesCubit(CategoryRepository()),
          child: const CategoriesScreen(),
        );
        break;
      case DashboardItem.brands:
        screen = BlocProvider(
          create: (_) => BrandsCubit(BrandRepository()),
          child: const BrandsScreen(),
        );
        break;
      case DashboardItem.attributes:
        screen = BlocProvider(
          create: (_) => VariationCubit(VariationRepository()),
          child: const VariationScreen(),
        );
        break;
      case DashboardItem.units:
        screen = BlocProvider(
          create: (_) => UnitsCubit(UnitRepository()),
          child: const UnitsScreen(),
        );
        break;
      case DashboardItem.printLabels:
        screen = const PrintLabelsScreen();
        break;
      case DashboardItem.financialAccounts:
        screen = BlocProvider(
          create: (_) => BankAccountCubit(BankAccountRepository()),
          child: const BankAccountsScreen(),
        );
        break;
      case DashboardItem.taxes:
        screen = BlocProvider(
          create: (_) => TaxesCubit(TaxRepository()),
          child: const TaxesScreen(),
        );
        break;
      case DashboardItem.discounts:
        screen = BlocProvider(
          create: (_) => DiscountsCubit(DiscountRepository()),
          child: const DiscountsScreen(),
        );
        break;
      case DashboardItem.expenseCategories:
        screen = BlocProvider(
          create: (_) => ExpenseCategoryCubit(ExpenseCategoryRepository()),
          child: const ExpenseCategoriesScreen(),
        );
        break;
      case DashboardItem.revenue:
        screen = BlocProvider(
          create: (_) => RevenueCubit(RevenueRepository()),
          child: const RevenueScreen(),
        );
        break;
      case DashboardItem.expenses:
        screen = BlocProvider(
          create: (_) => ExpenseAdminCubit(ExpenseRepository()),
          child: const ExpenseAdminScreen(),
        );
        break;
      case DashboardItem.payment:
        screen = BlocProvider(
          create: (_) => PaymentMethodCubit(PaymentMethodRepository()),
          child: const PaymentMethodsScreen(),
        );
        break;
      case DashboardItem.popups:
        screen = BlocProvider(
          create: (_) => PopupCubit(PopupRepository()),
          child: const PopupScreen(),
        );
        break;
      case DashboardItem.bundles:
        screen = BlocProvider(
          create: (_) => PandelCubit(BundleRepository()),
          child: const PandelScreen(),
        );
        break;
      case DashboardItem.coupons:
        screen = BlocProvider(
          create: (_) => CouponsCubit(CouponRepository()),
          child: const CouponsScreen(),
        );
        break;
      case DashboardItem.cities:
        screen = BlocProvider(
          create: (_) => CityCubit(CityRepository()),
          child: const CitiesScreen(),
        );
        break;
      case DashboardItem.countries:
        screen = BlocProvider(
          create: (_) => CountryCubit(CountryRepository()),
          child: const CountriessScreen(),
        );
        break;
      case DashboardItem.zones:
        screen = MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ZoneCubit(ZoneRepository())),
            BlocProvider(create: (_) => CityCubit(CityRepository())),
          ],
          child: const ZonesScreen(),
        );
        break;
      case DashboardItem.permissions:
        screen = BlocProvider(
          create: (_) => PermissionCubit(PermissionRepository()),
          child: const PermissionScreen(),
        );
        break;
      case DashboardItem.currencies:
        screen = BlocProvider(
          create: (_) => CurrencyCubit(CurrencyRepository()),
          child: const CurrenciesScreen(),
        );
        break;
      case DashboardItem.warehouses:
        screen = BlocProvider(
          create: (_) => WareHouseCubit(WarehouseRepository()),
          child: const WarehousesScreen(),
        );
        break;
      case DashboardItem.transfers:
        screen = const TransfersScreen();
        break;
      case DashboardItem.purchase:
        screen = BlocProvider(
          create: (_) => PurchaseCubit(PurchaseRepository()),
          child: const PurchaseScreen(),
        );
        break;
      case DashboardItem.returns:
        screen = MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PurchaseReturnCubit(PurchaseReturnRepository()),
            ),
            BlocProvider(
              create: (_) => BankAccountCubit(BankAccountRepository()),
            ),
          ],
          child: const PurchaseReturnsScreen(),
        );
        break;
      case DashboardItem.adjustments:
        screen = BlocProvider(
          create: (_) => AdjustmentCubit(AdjustmentRepository()),
          child: const AdjustmentsScreen(),
        );
        break;
      case DashboardItem.reasons:
        screen = BlocProvider(
          create: (_) => ReasonCubit(ReasonRepository()),
          child: const ReasonsScreen(),
        );
        break;
      case DashboardItem.suppliers:
        screen = const SupplierScreen();
        break;
      case DashboardItem.customers:
        screen = BlocProvider(
          create: (_) => CustomerCubit(CustomerRepository()),
          child: const CustomerScreen(),
        );
        break;
      case DashboardItem.customerGroups:
        screen = BlocProvider(
          create: (_) => CustomerCubit(CustomerRepository()),
          child: const CustomerGroupsScreen(),
        );
        break;
      case DashboardItem.admins:
        screen = BlocProvider(
          create: (_) => AdminsCubit(AdminRepository()),
          child: const AdminsScreen(),
        );
        break;
      case DashboardItem.cashiers:
        screen = BlocProvider(
          create: (_) => CashierCubit(CashierRepository()),
          child: const CashiersScreen(),
        );
        break;
      case DashboardItem.roles:
        screen = BlocProvider(
          create: (_) => RolesCubit(RoleRepository()),
          child: const RolesScreen(),
        );
        break;
      case DashboardItem.points:
        screen = BlocProvider(
          create: (_) => PointsCubit(PointsRepository()),
          child: const PointsScreen(),
        );
        break;
      case DashboardItem.redeemPoints:
        screen = BlocProvider(
          create: (_) => RedeemPointsCubit(RedeemPointsRepository()),
          child: const RedeemPointsScreen(),
        );
        break;
      // Reports
      case DashboardItem.salesReport:
        screen = BlocProvider(
          create: (_) => ReportsCubit(),
          child: const SalesReportScreen(),
        );
        break;
      case DashboardItem.productReport:
        screen = BlocProvider(
          create: (_) => ReportsCubit(),
          child: const ProductReportScreen(),
        );
        break;
      case DashboardItem.inventoryReport:
        screen = BlocProvider(
          create: (_) => ReportsCubit(),
          child: const InventoryReportScreen(),
        );
        break;
      case DashboardItem.financialReport:
        // Financial report can reuse the same cubit with different method
        screen = BlocProvider(
          create: (_) => ReportsCubit(),
          child: const SalesReportScreen(), // Placeholder - create FinancialReportScreen later
        );
        break;
      default:
        _showComingSoonDialog();
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
        ),
        contentPadding: EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                size: ResponsiveUI.iconSize(context, 48),
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            Text(
              LocaleKeys.coming_soon_title.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: ResponsiveUI.value(context, 10)),
            Text(
              LocaleKeys.coming_soon_message.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray.withValues(alpha: 0.7),
                height: ResponsiveUI.value(context, 1.5),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
              ),
              child: Text(
                LocaleKeys.ok.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();

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
            showSettingsIcon: true,
            title: LocaleKeys.dashboard.tr(),
            notificationCount: unreadCount,
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
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.horizontalPadding(context),
                vertical: ResponsiveUI.padding(context, 16),
              ),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return _buildGroupCard(groups[index], index);
              },
            ),
          ),
        );
      },
    );
  }

  // ─── Group Card ───────────────────────────────────────────

  Widget _buildGroupCard(_DashboardGroup group, int groupIndex) {
    final isExpanded = _expandedGroups.contains(groupIndex);
    final borderRadius = BorderRadius.circular(
      ResponsiveUI.borderRadius(context, 16),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: group.accentColor.withValues(
                alpha: isExpanded ? 0.12 : 0.06,
              ),
              blurRadius: isExpanded ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isExpanded
                ? group.accentColor.withValues(alpha: 0.25)
                : AppColors.lightGray.withValues(alpha: 0.5),
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // ── Header ──
            Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedGroups.remove(groupIndex);
                    } else {
                      _expandedGroups.add(groupIndex);
                    }
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                    vertical: ResponsiveUI.padding(context, 18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveUI.padding(context, 10),
                        ),
                        decoration: BoxDecoration(
                          color: group.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUI.borderRadius(context, 12),
                          ),
                        ),
                        child: Icon(
                          group.icon,
                          color: group.accentColor,
                          size: ResponsiveUI.iconSize(context, 22),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 14)),
                      Expanded(
                        child: Text(
                          group.title,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 20),
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: group.accentColor,
                          size: ResponsiveUI.iconSize(context, 26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Expandable Body ──
            AnimatedCrossFade(
              firstChild: SizedBox(width: double.infinity),
              secondChild: _buildModulesGrid(group),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Modules Grid ─────────────────────────────────────────

  Widget _buildModulesGrid(_DashboardGroup group) {
    return Container(
      padding: EdgeInsets.only(
        left: ResponsiveUI.padding(context, 16),
        right: ResponsiveUI.padding(context, 16),
        bottom: ResponsiveUI.padding(context, 16),
      ),
      child: Column(
        children: [
          Divider(
            color: AppColors.lightGray.withValues(alpha: 0.5),
            height: ResponsiveUI.value(context, 1),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.modules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUI.screenWidth(context) < 400 ? 2 : (ResponsiveUI.isMobile(context) ? 3 : 4),
              mainAxisSpacing: ResponsiveUI.spacing(context, 12),
              crossAxisSpacing: ResponsiveUI.spacing(context, 12),
              childAspectRatio: ResponsiveUI.isMobile(context) ? 0.85 : 1.3,
            ),
            itemBuilder: (context, index) {
              final module = group.modules[index];
              return _buildModuleCard(module, group.accentColor);
            },
          ),
        ],
      ),
    );
  }

  // ─── Module Card ──────────────────────────────────────────

  Widget _buildModuleCard(_ModuleItem module, Color accentColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1E2C).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: ResponsiveUI.value(context, 1.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToPage(module.id),
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          child: Stack(
            children: [
              // Subtle background glow
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: ResponsiveUI.value(context, 80),
                  height: ResponsiveUI.value(context, 80),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUI.padding(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: module.comingSoon
                            ? accentColor.withValues(alpha: 0.05)
                            : accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        module.icon,
                        size: ResponsiveUI.iconSize(context, ResponsiveUI.isMobile(context) ? 26 : 32),
                        color: module.comingSoon
                            ? accentColor.withValues(alpha: 0.4)
                            : accentColor,
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 12)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUI.padding(context, 8),
                      ),
                      child: Text(
                        module.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, ResponsiveUI.isMobile(context) ? 13 : 16),
                          fontWeight: FontWeight.w600,
                          color: module.comingSoon
                              ? (isDarkMode
                                    ? Colors.white54
                                    : AppColors.darkGray.withValues(alpha: 0.5))
                              : (isDarkMode
                                    ? Colors.white
                                    : AppColors.darkGray),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (module.comingSoon)
                Positioned(
                  top: ResponsiveUI.padding(context, 6),
                  right: ResponsiveUI.padding(context, 6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 6),
                      vertical: ResponsiveUI.padding(context, 2),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 6),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.soon_label.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 10),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
