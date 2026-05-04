import 'dart:developer' as developer;

/// Data source types for migration
enum DataSource {
  dio,
  supabase,
}

/// Feature flags configuration for gradual migration
class MigrationConfig {
  final DataSource authSource;
  final DataSource productsSource;
  final DataSource salesSource;
  final DataSource purchasesSource;
  final DataSource customersSource;
  final DataSource warehousesSource;
  final DataSource suppliersSource;
  final DataSource categoriesSource;
  final DataSource brandsSource;
  final DataSource unitsSource;
  final DataSource adminSource;
  final DataSource shiftSource;
  final DataSource financialSource;
  final DataSource notificationsSource;
  final DataSource storageSource;
  final DataSource returnsSource;
  final DataSource adjustmentsSource;
  final DataSource transfersSource;
  final DataSource onlineOrdersSource;
  final DataSource pointsSource;
  final DataSource redeemPointsSource;
  final DataSource taxesSource;
  final DataSource discountsSource;
  final DataSource couponsSource;
  final DataSource variationsSource;
  final DataSource bundlesSource;

  const MigrationConfig({
    this.authSource = DataSource.dio,
    this.productsSource = DataSource.dio,
    this.salesSource = DataSource.dio,
    this.purchasesSource = DataSource.dio,
    this.customersSource = DataSource.dio,
    this.warehousesSource = DataSource.dio,
    this.suppliersSource = DataSource.dio,
    this.categoriesSource = DataSource.dio,
    this.brandsSource = DataSource.dio,
    this.unitsSource = DataSource.dio,
    this.adminSource = DataSource.dio,
    this.shiftSource = DataSource.dio,
    this.financialSource = DataSource.dio,
    this.notificationsSource = DataSource.dio,
    this.storageSource = DataSource.dio,
    this.returnsSource = DataSource.dio,
    this.adjustmentsSource = DataSource.dio,
    this.transfersSource = DataSource.dio,
    this.onlineOrdersSource = DataSource.dio,
    this.pointsSource = DataSource.dio,
    this.redeemPointsSource = DataSource.dio,
    this.taxesSource = DataSource.dio,
    this.discountsSource = DataSource.dio,
    this.couponsSource = DataSource.dio,
    this.variationsSource = DataSource.dio,
    this.bundlesSource = DataSource.dio,
  });

  /// All Supabase configuration for full migration
  static const MigrationConfig allSupabase = MigrationConfig(
    authSource: DataSource.supabase,
    productsSource: DataSource.supabase,
    salesSource: DataSource.supabase,
    purchasesSource: DataSource.supabase,
    customersSource: DataSource.supabase,
    warehousesSource: DataSource.supabase,
    suppliersSource: DataSource.supabase,
    categoriesSource: DataSource.supabase,
    brandsSource: DataSource.supabase,
    unitsSource: DataSource.supabase,
    adminSource: DataSource.supabase,
    shiftSource: DataSource.supabase,
    financialSource: DataSource.supabase,
    notificationsSource: DataSource.supabase,
    storageSource: DataSource.supabase,
    returnsSource: DataSource.supabase,
    adjustmentsSource: DataSource.supabase,
    transfersSource: DataSource.supabase,
    onlineOrdersSource: DataSource.supabase,
    pointsSource: DataSource.supabase,
    redeemPointsSource: DataSource.supabase,
    taxesSource: DataSource.supabase,
    discountsSource: DataSource.supabase,
    couponsSource: DataSource.supabase,
    variationsSource: DataSource.supabase,
    bundlesSource: DataSource.supabase,
  );

  /// All Dio configuration (legacy mode)
  static const MigrationConfig allDio = MigrationConfig();
}

/// Service for managing gradual migration from Dio to Supabase
/// Provides feature flags and logging capabilities
class MigrationService {
  MigrationService._();

  static MigrationConfig _config = MigrationConfig.allSupabase;
  static final List<MigrationLogEntry> _logs = [];

  /// Configure the migration service with specific settings
  static void configure(MigrationConfig config) {
    _config = config;
    _log('Migration configured', {
      'config': _configToMap(config),
    });
  }

  /// Get current configuration
  static MigrationConfig get config => _config;

  /// Get the data source for a specific repository
  static DataSource getSource(String repositoryName) {
    final source = _getSourceFromConfig(repositoryName);
    _log('Source lookup', {
      'repository': repositoryName,
      'source': source.toString(),
    });
    return source;
  }

  /// Check if a specific repository is using Supabase
  static bool isUsingSupabase(String repositoryName) {
    return getSource(repositoryName) == DataSource.supabase;
  }

  /// Check if a specific repository is using Dio
  static bool isUsingDio(String repositoryName) {
    return getSource(repositoryName) == DataSource.dio;
  }

  /// Enable Supabase for a specific repository
  static void enableSupabase(String repositoryName) {
    _config = _copyConfigWithSource(repositoryName, DataSource.supabase);
    _log('Enabled Supabase', {'repository': repositoryName});
  }

  /// Enable Dio for a specific repository (rollback)
  static void enableDio(String repositoryName) {
    _config = _copyConfigWithSource(repositoryName, DataSource.dio);
    _log('Enabled Dio (rollback)', {'repository': repositoryName});
  }

  /// Get all migration logs
  static List<MigrationLogEntry> get logs => List.unmodifiable(_logs);

  /// Clear migration logs
  static void clearLogs() {
    _logs.clear();
  }

  /// Export configuration as a map for debugging
  static Map<String, dynamic> exportConfig() {
    return _configToMap(_config);
  }

  // Private methods

  static DataSource _getSourceFromConfig(String repositoryName) {
    switch (repositoryName.toLowerCase()) {
      case 'auth':
      case 'authentication':
        return _config.authSource;
      case 'products':
      case 'product':
        return _config.productsSource;
      case 'sales':
      case 'sale':
        return _config.salesSource;
      case 'purchases':
      case 'purchase':
        return _config.purchasesSource;
      case 'customers':
      case 'customer':
        return _config.customersSource;
      case 'warehouses':
      case 'warehouse':
        return _config.warehousesSource;
      case 'suppliers':
      case 'supplier':
        return _config.suppliersSource;
      case 'categories':
      case 'category':
        return _config.categoriesSource;
      case 'brands':
      case 'brand':
        return _config.brandsSource;
      case 'units':
      case 'unit':
        return _config.unitsSource;
      case 'admins':
      case 'admin':
        return _config.adminSource;
      case 'shifts':
      case 'shift':
        return _config.shiftSource;
      case 'financial':
      case 'finance':
        return _config.financialSource;
      case 'notifications':
      case 'notification':
        return _config.notificationsSource;
      case 'storage':
        return _config.storageSource;
      case 'returns':
      case 'return':
      case 'purchase_returns':
      case 'purchase_return':
        return _config.returnsSource;
      case 'adjustments':
      case 'adjustment':
        return _config.adjustmentsSource;
      case 'transfers':
      case 'transfer':
        return _config.transfersSource;
      case 'online_orders':
      case 'online_order':
        return _config.onlineOrdersSource;
      case 'points':
        return _config.pointsSource;
      case 'redeem_points':
        return _config.redeemPointsSource;
      case 'taxes':
      case 'tax':
        return _config.taxesSource;
      case 'discounts':
      case 'discount':
        return _config.discountsSource;
      case 'coupons':
      case 'coupon':
        return _config.couponsSource;
      case 'variations':
      case 'variation':
        return _config.variationsSource;
      case 'bundles':
      case 'bundle':
      case 'pandel':
        return _config.bundlesSource;
      default:
        return DataSource.dio;
    }
  }

  static MigrationConfig _copyConfigWithSource(
    String repositoryName,
    DataSource source,
  ) {
    final Map<String, DataSource> current = {
      'auth': _config.authSource,
      'products': _config.productsSource,
      'sales': _config.salesSource,
      'purchases': _config.purchasesSource,
      'customers': _config.customersSource,
      'warehouses': _config.warehousesSource,
      'suppliers': _config.suppliersSource,
      'categories': _config.categoriesSource,
      'brands': _config.brandsSource,
      'units': _config.unitsSource,
      'admin': _config.adminSource,
      'shift': _config.shiftSource,
      'financial': _config.financialSource,
      'notifications': _config.notificationsSource,
      'storage': _config.storageSource,
      'returns': _config.returnsSource,
      'adjustments': _config.adjustmentsSource,
      'transfers': _config.transfersSource,
      'online_orders': _config.onlineOrdersSource,
      'points': _config.pointsSource,
      'redeem_points': _config.redeemPointsSource,
      'taxes': _config.taxesSource,
      'discounts': _config.discountsSource,
      'coupons': _config.couponsSource,
      'variations': _config.variationsSource,
      'bundles': _config.bundlesSource,
    };

    switch (repositoryName.toLowerCase()) {
      case 'auth':
      case 'authentication':
        current['auth'] = source;
        break;
      case 'products':
      case 'product':
        current['products'] = source;
        break;
      case 'sales':
      case 'sale':
        current['sales'] = source;
        break;
      case 'purchases':
      case 'purchase':
        current['purchases'] = source;
        break;
      case 'customers':
      case 'customer':
        current['customers'] = source;
        break;
      case 'warehouses':
      case 'warehouse':
        current['warehouses'] = source;
        break;
      case 'suppliers':
      case 'supplier':
        current['suppliers'] = source;
        break;
      case 'categories':
      case 'category':
        current['categories'] = source;
        break;
      case 'brands':
      case 'brand':
        current['brands'] = source;
        break;
      case 'units':
      case 'unit':
        current['units'] = source;
        break;
      case 'admins':
      case 'admin':
        current['admin'] = source;
        break;
      case 'shifts':
      case 'shift':
        current['shift'] = source;
        break;
      case 'financial':
      case 'finance':
        current['financial'] = source;
        break;
      case 'notifications':
      case 'notification':
        current['notifications'] = source;
        break;
      case 'storage':
        current['storage'] = source;
        break;
      case 'returns':
      case 'return':
      case 'purchase_returns':
      case 'purchase_return':
        current['returns'] = source;
        break;
      case 'adjustments':
      case 'adjustment':
        current['adjustments'] = source;
        break;
      case 'transfers':
      case 'transfer':
        current['transfers'] = source;
        break;
      case 'online_orders':
      case 'online_order':
        current['online_orders'] = source;
        break;
      case 'points':
        current['points'] = source;
        break;
      case 'redeem_points':
        current['redeem_points'] = source;
        break;
      case 'taxes':
      case 'tax':
        current['taxes'] = source;
        break;
      case 'discounts':
      case 'discount':
        current['discounts'] = source;
        break;
      case 'coupons':
      case 'coupon':
        current['coupons'] = source;
        break;
      case 'variations':
      case 'variation':
        current['variations'] = source;
        break;
      case 'bundles':
      case 'bundle':
      case 'pandel':
        current['bundles'] = source;
        break;
    }

    return MigrationConfig(
      authSource: current['auth']!,
      productsSource: current['products']!,
      salesSource: current['sales']!,
      purchasesSource: current['purchases']!,
      customersSource: current['customers']!,
      warehousesSource: current['warehouses']!,
      suppliersSource: current['suppliers']!,
      categoriesSource: current['categories']!,
      brandsSource: current['brands']!,
      unitsSource: current['units']!,
      adminSource: current['admin']!,
      shiftSource: current['shift']!,
      financialSource: current['financial']!,
      notificationsSource: current['notifications']!,
      storageSource: current['storage']!,
      returnsSource: current['returns']!,
      adjustmentsSource: current['adjustments']!,
      transfersSource: current['transfers']!,
      onlineOrdersSource: current['online_orders']!,
      pointsSource: current['points']!,
      redeemPointsSource: current['redeem_points']!,
      taxesSource: current['taxes']!,
      discountsSource: current['discounts']!,
      couponsSource: current['coupons']!,
      variationsSource: current['variations']!,
      bundlesSource: current['bundles']!,
    );
  }

  static void _log(String action, Map<String, dynamic> details) {
    final entry = MigrationLogEntry(
      timestamp: DateTime.now(),
      action: action,
      details: details,
    );
    _logs.add(entry);

    developer.log(
      '[MigrationService] $action',
      name: 'Migration',
      error: details,
    );
  }

  static Map<String, dynamic> _configToMap(MigrationConfig config) {
    return {
      'auth': config.authSource.toString(),
      'products': config.productsSource.toString(),
      'sales': config.salesSource.toString(),
      'purchases': config.purchasesSource.toString(),
      'customers': config.customersSource.toString(),
      'warehouses': config.warehousesSource.toString(),
      'suppliers': config.suppliersSource.toString(),
      'categories': config.categoriesSource.toString(),
      'brands': config.brandsSource.toString(),
      'units': config.unitsSource.toString(),
      'admin': config.adminSource.toString(),
      'shift': config.shiftSource.toString(),
      'financial': config.financialSource.toString(),
      'notifications': config.notificationsSource.toString(),
      'storage': config.storageSource.toString(),
      'returns': config.returnsSource.toString(),
      'adjustments': config.adjustmentsSource.toString(),
      'transfers': config.transfersSource.toString(),
      'online_orders': config.onlineOrdersSource.toString(),
      'points': config.pointsSource.toString(),
      'redeem_points': config.redeemPointsSource.toString(),
      'taxes': config.taxesSource.toString(),
      'discounts': config.discountsSource.toString(),
      'coupons': config.couponsSource.toString(),
      'variations': config.variationsSource.toString(),
      'bundles': config.bundlesSource.toString(),
    };
  }
}

/// Log entry for migration activities
class MigrationLogEntry {
  final DateTime timestamp;
  final String action;
  final Map<String, dynamic> details;

  MigrationLogEntry({
    required this.timestamp,
    required this.action,
    required this.details,
  });

  @override
  String toString() {
    return '${timestamp.toIso8601String()} - $action: $details';
  }
}
