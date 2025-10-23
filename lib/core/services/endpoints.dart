class EndPoint {
  static const String login = '/api/admin/auth/login';

  /// Warehouses
  static const String warehouses = '/api/admin/warehouse';
  static const String createWarehouse = '/api/admin/warehouse';
  static const String updateWarehouse = '/api/admin/warehouse';
  static const String deleteWarehouse = '/api/admin/warehouse';

  /// Supplier
  static const String createSupplier = '/api/admin/supplier';
  static const String getSuppliers = '/api/admin/supplier';
  static String getSupplierById(String id) => '/api/admin/supplier/$id';
  static const String updateSupplier = '/api/admin/supplier';
  static const String deleteSupplier = '/api/admin/supplier';

  /// Category
  static const String createCategory = '/api/admin/category';
  static const String getCategories = '/api/admin/category';
  static String getCategoryById(String id) => '/api/admin/category/$id';

  /// Brand
  static const String createBrand = '/api/admin/brand';
  static const String getBrands = '/api/admin/brand';
  static String getBrandById(String id) => '/api/admin/brand/$id';

  /// Product
  static const String getProducts = '/api/admin/product';
  static const String createProduct = '/api/admin/product';
  static String getProductById(String id) => '/api/admin/product/$id';
  static String deleteProduct(String id) => '/api/admin/product/$id';
  static const String productSelect = '/api/admin/product/select';
}
