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
  static String updateCategory(String id) => '/api/admin/category/$id';
  static String deleteCategory(String id) => '/api/admin/category/$id';

  /// Brand
  static const String getBrands = '/api/admin/brand';
  static String getBrandById(String id) => '/api/admin/brand/$id';
  static const String createBrand = '/api/admin/brand';
  static String updateBrand(String id) => '/api/admin/brand/$id';
  static String deleteBrand(String id) => '/api/admin/brand/$id';

  /// Product
  static const String getProducts = '/api/admin/product';
  static const String productFilter = '/api/admin/product/select';
  static String getProductById(String id) => '/api/admin/product/$id';
  static const String createProduct = '/api/admin/product';
  static String updateProduct(String id) => '/api/admin/product/$id';
  static String deleteProduct(String id) => '/api/admin/product/$id';

  // Currency
  static const String getCurrencies = '/api/admin/currency';
  static String getCurrencyById(String id) => '/api/admin/currency/$id';
  static const String createCurrency = '/api/admin/currency';
  static String updateCurrency(String id) => '/api/admin/currency/$id';
  static String deleteCurrency(String id) => '/api/admin/currency/$id';

  /// Country
  static const String getCountries = '/api/admin/country';
  static String selectCountry(String id) => '/api/admin/country/$id';
  static String createCountry = '/api/admin/country';
  static String updateCountry(String id) => '/api/admin/country/$id';
  static String deleteCountry(String id) => '/api/admin/country/$id';

  /// Notifications
  static const String getNotifications = '/api/admin/notification';
  static String markAsRead(String id) => '/api/admin/notification/$id';
}
