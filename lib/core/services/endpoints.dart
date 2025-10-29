class EndPoint {
  /// Base Url
  static const String baseUrl = 'https://Bcknd.systego.net';

  /// Login
  static const String login = '/api/admin/auth/login';

  /// Warehouses
  static const String getWarehouses = '/api/admin/warehouse';
  static const String createWarehouse = '/api/admin/warehouse';
  static const String updateWarehouse = '/api/admin/warehouse';
  static const String deleteWarehouse = '/api/admin/warehouse';

  /// Supplier
  static const String getSuppliers = '/api/admin/supplier';
  static String getSupplierById(String id) => '/api/admin/supplier/$id';
  static const String createSupplier = '/api/admin/supplier';
  static const String updateSupplier = '/api/admin/supplier';
  static const String deleteSupplier = '/api/admin/supplier';

  /// Category
  static const String getCategories = '/api/admin/category';
  static String getCategoryById(String id) => '/api/admin/category/$id';
  static const String createCategory = '/api/admin/category';

  /// Brand
  static const String createBrand = '/api/admin/brand';
  static const String getBrands = '/api/admin/brand';
  static String getBrandById(String id) => '/api/admin/brand/$id';

  // Currency
  static const String getCurrencies = '/api/admin/currency';
  static String getCurrencyById(String id) => '/api/admin/currency/$id';
  static const String createCurrency = '/api/admin/currency';
  static String updateCurrency(String id) => '/api/admin/currency/$id';

  /// Product
  static const String getProducts = '/api/admin/product';
  static const String productFilter = '/api/admin/product/select';
  static String getProductById(String id) => '/api/admin/product/$id';
  static const String createProduct = '/api/admin/product';
  static String deleteProduct(String id) => '/api/admin/product/$id';

  /// Notifications
  static const String getNotifications = '/api/admin/notification';
  static String markAsRead(String id) => '/api/admin/notification/$id';
}
