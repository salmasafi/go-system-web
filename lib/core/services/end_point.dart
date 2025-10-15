class EndPoint {
  static const String login = '/api/admin/auth/login';
  static const String warehouses = '/api/admin/warehouse';
  static const String createCategory = '/api/admin/category';
  static const String getCategories = '/api/admin/category';
  static String getCategoryById(String id) => '/api/admin/category/$id';

  static const String createBrand = '/api/admin/brand';
  static const String getBrands = '/api/admin/brand';
  static String getBrandById(String id) => '/api/admin/brand/$id';



  static const String getProducts = '/api/admin/product';
}