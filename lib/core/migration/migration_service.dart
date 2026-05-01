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
  );

  /// All Dio configuration (legacy mode)
  static const MigrationConfig allDio = MigrationConfig();
}

/// Service for managing gradual migration from Dio to Supabase
/// Provides feature flags and logging capabilities
class MigrationService {
  MigrationService._();

  static MigrationConfig _config = const MigrationConfig();
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
      default:
        return DataSource.dio;
    }
  }

  static MigrationConfig _copyConfigWithSource(
    String repositoryName,
    DataSource source,
  ) {
    switch (repositoryName.toLowerCase()) {
      case 'auth':
      case 'authentication':
        return MigrationConfig(
          authSource: source,
          productsSource: _config.productsSource,
          salesSource: _config.salesSource,
          purchasesSource: _config.purchasesSource,
          customersSource: _config.customersSource,
          warehousesSource: _config.warehousesSource,
          suppliersSource: _config.suppliersSource,
          categoriesSource: _config.categoriesSource,
          brandsSource: _config.brandsSource,
          unitsSource: _config.unitsSource,
          adminSource: _config.adminSource,
          shiftSource: _config.shiftSource,
          financialSource: _config.financialSource,
          notificationsSource: _config.notificationsSource,
          storageSource: _config.storageSource,
        );
      case 'products':
      case 'product':
        return MigrationConfig(
          authSource: _config.authSource,
          productsSource: source,
          salesSource: _config.salesSource,
          purchasesSource: _config.purchasesSource,
          customersSource: _config.customersSource,
          warehousesSource: _config.warehousesSource,
          suppliersSource: _config.suppliersSource,
          categoriesSource: _config.categoriesSource,
          brandsSource: _config.brandsSource,
          unitsSource: _config.unitsSource,
          adminSource: _config.adminSource,
          shiftSource: _config.shiftSource,
          financialSource: _config.financialSource,
          notificationsSource: _config.notificationsSource,
          storageSource: _config.storageSource,
        );
      // Add more cases as needed
      default:
        return _config;
    }
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
