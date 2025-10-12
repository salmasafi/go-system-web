class EndPoint {
  static const String login = '/api/admin/auth/login';
  static const String createCategory = '/api/admin/category';
  static const String getCategories = '/api/admin/category';
  static String getCategoryById(String id) => '/api/admin/category/$id';


}