/// [EndPoint] is deprecated and scheduled for removal in Phase 12.1 of the Supabase migration.
/// Please use Supabase table names and repository-based data sources instead.
@Deprecated('Use Supabase table names instead. This will be removed in Phase 12.1.')
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
  static String getWareHouseById(String id) => '/api/admin/warehouse/$id';
  static String getWareHouseProducts(String id) => '/api/admin/product_warehouse/$id';
  static String addProductToWarehouse(String id) => '/api/admin/product_warehouse/$id';

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

  static String generateProductCode = '/api/admin/product/generate-code';

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
  static const String posBundles = '/api/admin/pos-home/bundles';

  static String posCategoryProducts(String categoryId) =>
      '/api/admin/pos-home/categories/$categoryId/products';

  static String posBrandProducts(String brandId) =>
      '/api/admin/pos-home/brands/$brandId/products';

  /// Points
  static const String redeemPoints = '/api/admin/redeem-points';

  static String getAllSales = '/api/admin/pos/sales';
  static String posSearchSaleByRef(String ref) => '/api/admin/pos/sales?reference=$ref';
  static const String saleForReturn = '/api/admin/return-sale/sale-for-return';
  static const String createReturn = '/api/admin/return-sale/create-return';
  static String getPendingSales = '/api/admin/pos/sales/pending';
  static String getPendingSaleDetails(String saleId) =>
      '/api/admin/pos/sales/sales/pending/$saleId';
  static String getDueSales = '/api/admin/pos/sales/dues';
  static String payDue = '/api/admin/pos/sales/pay-due';

  /// POS checkout
  static String posCreateSale = '/api/admin/pos/sales';

  /// POS customers
  static const String getPosCustomers = '/api/admin/pos_customer/customers';
  static const String createPosCustomer = '/api/admin/pos_customer/customer';

  /// POS shift
  static String posCashiers = '/api/admin/pos-home/cashiers';
  static String selectCashier = '/api/admin/pos-home/cashiers/select';
  static String logoutShift = '/api/admin/cashier-shift/logout';
  static String endShift = '/api/admin/cashier-shift/end';
  static String startShift = '/api/admin/cashier-shift/start';

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

  /// variation
  static const String getAllVariations = '/api/admin/variation';
  static String getVariation(String id) => '/api/admin/variation/$id';
  static String addVariation = '/api/admin/variation';
  static String updateVariation(String id) => '/api/admin/variation/$id';
  static String deleteVariation(String id) => '/api/admin/variation/$id';
  static String deleteOption(String id) => '/api/admin/variation/option/$id';

  /// variation
  static const String getAllDiscounts = '/api/admin/discount';
  static String getDiscount(String id) => '/api/admin/discount/$id';
  static String addDiscount = '/api/admin/discount';
  static String updateDiscount(String id) => '/api/admin/discount/$id';
  static String deleteDiscount(String id) => '/api/admin/discount/$id';

  /// permissions
  static const String getAllpermissions = '/api/admin/permission';
  static String getUserPermissions(String id) => '/api/admin/permission/$id';
  static String addpermission = '/api/admin/permission';
  static String updatepermission(String id) => '/api/admin/permission/$id';
  static String deletepermission(String id) => '/api/admin/permission/$id';

  /// adjustments
  static const String getAlladjustments = '/api/admin/adjustment';
  static String getadjustment(String id) => '/api/admin/adjustment/$id';
  static String addadjustment = '/api/admin/adjustment';
  static String updateadjustment(String id) => '/api/admin/adjustment/$id';
  static String deleteadjustment(String id) => '/api/admin/adjustment/$id';

  /// reasons
  static const String getAllreasons = '/api/admin/selectreason';
  static String getreason(String id) => '/api/admin/selectreason/$id';
  static String addreason = '/api/admin/selectreason';
  static String updatereason(String id) => '/api/admin/selectreason/$id';
  static String deletereason(String id) => '/api/admin/selectreason/$id';

  /// admins
  static const String getAllAdmins = '/api/admin/admin';
  static String getAdmin(String id) => '/api/admin/admin/$id';
  static String createAdmin = '/api/admin/admin';
  static String updateAdmin(String id) => '/api/admin/admin/$id';
  static String deleteAdmin(String id) => '/api/admin/admin/$id';

  /// cashiers
  static const String getAllCashiers = '/api/admin/cashier';
  static String getCashier(String id) => '/api/admin/cashier/$id';
  static String createCashier = '/api/admin/cashier';
  static String updateCashier(String id) => '/api/admin/cashier/$id';
  static String deleteCashier(String id) => '/api/admin/cashier/$id';

  /// expencesCategories
  static const String getAllexpencesCategories = '/api/admin/expensecategory';
  static String getExpencesCategory(String id) =>
      '/api/admin/expensecategory/$id';
  static String addExpencesCategory = '/api/admin/expensecategory';
  static String updateExpencesCategory(String id) =>
      '/api/admin/expensecategory/$id';
  static String deleteExpencesCategory(String id) =>
      '/api/admin/expensecategory/$id';

  /// pandels
  static const String getAllPandels = '/api/admin/pandel';
  static String getPandelById(String id) => '/api/admin/pandel/$id';
  static const String addPandel = '/api/admin/pandel';
  static String updatePandel(String id) => '/api/admin/pandel/$id';
  static String deletePandel(String id) => '/api/admin/pandel/$id';

  /// customers
  static const String getAllCustomers = '/api/admin/customer';
  static String getCustomerById(String id) => '/api/admin/customer/$id';
  static const String addCustomer = '/api/admin/customer';
  static String updateCustomer(String id) => '/api/admin/customer/$id';
  static String deleteCustomer(String id) => '/api/admin/customer/$id';
  static String createCustomerGroup = '/api/admin/pos_customer';
  static const String getCustomerGroup = '/api/admin/customer/groups';
  static String getCustomerGroupById(String id) => '/api/admin/groups/$id';
  static String getCustomerDue(String id) => '/api/admin/customer/due';

  static String updateCustomerGroup(String id) => '/api/admin/customer/group/$id';
  static String deleteCustomerGroup(String id) => '/api/admin/customer/group/$id';

  /// permission
  static const String getAllRoles = '/api/admin/permission';
  static String getAllRoleSelection(String id) =>
      '/api/admin/permission/selection';
  static const String createRolePermission = '/api/admin/permission';
  static String deleteRole(String id) => '/api/admin/permission/$id';
  static String updateRole(String id) => '/api/admin/permission/$id';

  /// revenue
  static const String getAllRevenues = '/api/admin/revenue';
  static const String addRevenue = '/api/admin/revenue';
  static String deleteRevenue(String id) => '/api/admin/revenue/$id';
  static String getRevenueById(String id) => '/api/admin/revenue/$id';
  static String updateRevenue(String id) => '/api/admin/revenue/$id';
  static String getRevenueSelection = '/api/admin/revenue/selection';

  /// units
  static const String getUnits = '/api/admin/units';
  static const String createUnit = '/api/admin/units';
  static String updateUnit(String id) => '/api/admin/units/$id';
  static String deleteUnit(String id) => '/api/admin/units/$id';
  static String updateUnitStatus(String id) => '/api/admin/units/status/$id';

  /// purchase
  static String getPurchase = '/api/admin/purchase';
  static String getPurchaseByReference(String ref) => '/api/admin/purchase?reference=$ref';

  /// expense admin
  static const String getAllExpenseAdmin = '/api/admin/expenseAdmin';

  /// online orders
  static const String getOnlineOrders = '/cashier/orders/online_orders';

  /// POS expenses
  static const String addPosExpense = '/api/admin/expense';
  static const String getPosExpenses = '/api/admin/expense';
  static String updatePosExpense(String id) => '/api/admin/expense/$id';

  /// Purchase Returns
  static const String getAllPurchaseReturns = '/api/admin/return-purchase/all-returns';
  static const String createPurchaseReturn = '/api/admin/return-purchase';
  static String updatePurchaseReturn(String id) => '/api/admin/return-purchase/$id';
  static String deletePurchaseReturn(String id) => '/api/admin/return-purchase/$id';

  /// Points
  static const String getPoints = '/api/admin/point';
  static const String addPoint = '/api/admin/point';
  static String updatePoint = '/api/admin/point';
  static String deletePoint = '/api/admin/point';
}
