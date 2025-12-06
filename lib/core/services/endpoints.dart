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
  static String productByCode = '/api/admin/product/code';

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

  /// City
  static const String getCities = '/api/admin/city';
  static String selectCity(String id) => '/api/admin/city/$id';
  static String createCity = '/api/admin/city';
  static String updateCity(String id) => '/api/admin/city/$id';
  static String deleteCity(String id) => '/api/admin/city/$id';

  /// Zone
  static const String getZones = '/api/admin/zone';
  static String selectZone(String id) => '/api/admin/zone/$id';
  static String createZone = '/api/admin/zone';
  static String updateZone(String id) => '/api/admin/zone/$id';
  static String deleteZone(String id) => '/api/admin/zone/$id';

  /// Payment Method
  static const String getPaymentMethods = '/api/admin/payment_method';
  static String selectPaymentMethod(String id) =>
      '/api/admin/payment_method/$id';
  static String createPaymentMethod = '/api/admin/payment_method';
  static String updatePaymentMethod(String id) =>
      '/api/admin/payment_method/$id';
  static String deletePaymentMethod(String id) =>
      '/api/admin/payment_method/$id';

  /// Notifications
  static const String getNotifications = '/api/admin/notification';
  static String markAsRead(String id) => '/api/admin/notification/$id';

  /// POS home
  static String posSelections = '/api/admin/pos-home/selections';
  static String posFeatured = '/api/admin/pos-home/featured';
  static String posCategories = '/api/admin/pos-home/categories';
  static String posBrands = '/api/admin/pos-home/brands';

  static String posCategoryProducts(String categoryId) =>
      '/api/admin/pos-home/categories/$categoryId/products';

  static String posBrandProducts(String brandId) =>
      '/api/admin/pos-home/brands/$brandId/products';

  /// POS checkout
  static String posCreateSale = '/api/admin/pos/sales';


  /// Tax
  static const String getAllTaxes = '/api/admin/taxes';
  static String selectTax(String id) => '/api/admin/taxes/$id';
  static String createTax = '/api/admin/taxes';
  static String updateTax(String id) => '/api/admin/taxes/$id';
  static String deleteTax(String id) => '/api/admin/taxes/$id';

  /// Bank Accounts
  static const String getAllBankAccounts = '/api/admin/bank_account';
  static String getBankAccount(String id) => '/api/admin/bank_account/$id';
  static String addBankAccount = '/api/admin/bank_account';
  static String updateBankAccount(String id) => '/api/admin/bank_account/$id';
  static String deleteBankAccount(String id) => '/api/admin/bank_account/$id';

  /// popups
  static const String getAllPopups = '/api/admin/popup';
  static String getPopup(String id) => '/api/admin/popup/$id';
  static String addPopup = '/api/admin/popup';
  static String updatePopup(String id) => '/api/admin/popup/$id';
  static String deletePopup(String id) => '/api/admin/popup/$id';

  /// coupons
  static const String getAllCoupons = '/api/admin/coupon';
  static String getCoupon(String id) => '/api/admin/coupon/$id';
  static String addCoupon = '/api/admin/coupon';
  static String updateCoupon(String id) => '/api/admin/coupon/$id';
  static String deleteCoupon(String id) => '/api/admin/coupon/$id';

  /// department
  static const String getAllDepartments = '/api/admin/department';
  static String getDepartment(String id) => '/api/admin/department/$id';
  static String addDepartment = '/api/admin/department';
  static String updateDepartment(String id) => '/api/admin/department/$id';
  static String deleteDepartment(String id) => '/api/admin/department/$id';

}
