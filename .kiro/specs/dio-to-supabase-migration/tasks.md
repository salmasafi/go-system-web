# Tasks: Migration from Dio to Supabase

## Phase 1: Foundation & Setup

### 1.1 Supabase Project Setup
- [x] Create Supabase project for development environment
- [x] Create Supabase project for production environment
- [x] Configure database schema matching existing tables (supabase/migrations/001_initial_schema.sql)
- [x] Run initial database migration scripts
- [x] Verify all 50+ tables are created correctly

### 1.2 Environment Configuration
- [x] Add flutter_dotenv dependency to pubspec.yaml
- [x] Create `.env.development` file with Supabase credentials
- [x] Create `.env.production` file with Supabase credentials
- [x] Create `lib/core/config/app_config.dart` configuration loader
- [x] Update .gitignore to exclude environment files
- [x] Document environment setup in README

### 1.3 Supabase Client Setup
- [x] Add supabase_flutter dependency to pubspec.yaml
- [x] Create `lib/core/supabase/supabase_client.dart` singleton
- [x] Implement initialization method in main.dart
- [x] Add debug logging configuration
- [x] Test connection to Supabase

### 1.4 Migration Service (Feature Flags)
- [x] Create `lib/core/migration/migration_service.dart`
- [x] Implement DataSource enum (dio, supabase)
- [x] Create feature flag configuration system
- [x] Add repository source mapping
- [x] Implement migration logging
- [x] Add rollback capability

### 1.5 Error Handler
- [x] Create `lib/core/supabase/supabase_error_handler.dart`
- [x] Implement PostgrestException handler
- [x] Implement AuthException handler
- [x] Implement StorageException handler
- [x] Implement RealtimeException handler
- [x] Add Arabic/English error message mapping
- [x] Test all error scenarios

## Phase 2: Authentication & Core Services

### 2.1 Supabase Auth Service
- [x] Create `lib/features/admin/auth/data/services/supabase_auth_service.dart`
- [x] Implement login with email/password
- [x] Implement logout
- [x] Implement session checking
- [x] Implement token refresh handling
- [x] Store session in CacheHelper
- [x] Create AuthRepository with hybrid support
- [x] Test authentication flow end-to-end

### 2.2 Storage Service
- [x] Create `lib/core/supabase/storage_service.dart`
- [x] Implement image upload with compression
- [x] Implement image deletion
- [x] Create folder structure (products, brands, categories)
- [x] Add image validation (size, format)
- [x] Implement public URL generation
- [x] Test upload/delete operations

### 2.3 Real-Time Service
- [x] Create `lib/core/supabase/realtime_service.dart`
- [x] Implement table subscription method
- [x] Add INSERT event handling
- [x] Add UPDATE event handling
- [x] Add DELETE event handling
- [x] Implement filtering support
- [x] Add connection error handling and reconnection
- [x] Implement unsubscribe cleanup
- [x] Test real-time subscriptions

## Phase 3: Reference Data Repositories

### 3.1 Category Repository
- [x] Create `CategorySupabaseDataSource`
- [x] Implement getAllCategories() with hierarchy support
- [x] Implement createCategory() with image upload
- [x] Implement updateCategory() with image replacement
- [x] Implement deleteCategory()
- [x] Create hybrid CategoryRepository with Dio/Supabase switching
- [x] Add RLS policies for categories (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 3.2 Brand Repository
- [x] Create `BrandSupabaseDataSource`
- [x] Implement getAllBrands() with logo URLs
- [x] Implement createBrand() with logo upload
- [x] Implement updateBrand() with logo replacement
- [x] Implement deleteBrand()
- [x] Create hybrid BrandRepository with Dio/Supabase switching
- [x] Add RLS policies for brands (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 3.3 Unit Repository
- [x] Create `UnitSupabaseDataSource`
- [x] Implement getAllUnits()
- [x] Create hybrid UnitRepository with Dio/Supabase switching
- [ ] Implement createUnit() (API endpoint not available)
- [ ] Implement updateUnit() (API endpoint not available)
- [ ] Implement deleteUnit() (API endpoint not available)
- [x] Add RLS policies for units (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 3.4 Location Repositories
- [x] Create `CountrySupabaseDataSource`
- [x] Create `CitySupabaseDataSource` with shipping costs
- [x] Create `ZoneSupabaseDataSource`
- [x] Implement getAll methods with joins
- [x] Create hybrid repositories
- [x] Add RLS policies for location tables (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 3.5 Payment Method Repository
- [x] Create `PaymentMethodSupabaseDataSource`
- [x] Implement getAllPaymentMethods()
- [x] Create hybrid repository
- [x] Add RLS policies for payment_methods (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests

## Phase 4: Core Business Repositories

### 4.1 Product Repository
- [x] Create `ProductSupabaseDataSource`
- [x] Implement getAllProducts() with pagination
- [x] Implement getProductById() with full relations
- [x] Implement getProductsByWarehouse()
- [x] Implement searchProductsByCode() with ilike
- [x] Implement createProduct() with image upload
- [x] Implement updateProduct() with image handling
- [x] Implement deleteProduct()
- [x] Implement getProductVariations()
- [x] Implement getProductBundles()
- [x] Add RLS policies for products
- [x] Write comprehensive unit tests
- [x] Write integration tests

### 4.2 Customer Repository
- [x] Create `CustomerSupabaseDataSource`
- [x] Implement getAllCustomers()
- [x] Implement getCustomerById() with relations
- [x] Implement getCustomersByGroup()
- [x] Implement createCustomer()
- [x] Implement updateCustomer()
- [x] Implement deleteCustomer()
- [x] Implement calculateDueAmount()
- [x] Create hybrid CustomerRepository
- [x] Add customer group management (supabase/migrations/001_initial_schema.sql)
- [x] Add RLS policies for customers (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 4.3 Supplier Repository
- [x] Create `SupplierSupabaseDataSource`
- [x] Implement getAllSuppliers()
- [x] Implement getSupplierById()
- [x] Implement createSupplier() with image upload
- [x] Implement updateSupplier() with image replacement
- [x] Implement deleteSupplier()
- [x] Create hybrid SupplierRepository
- [x] Add RLS policies for suppliers (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 4.4 Warehouse Repository
- [x] Create `WarehouseSupabaseDataSource`
- [x] Implement getAllWarehouses()
- [x] Implement getWarehouseById()
- [x] Implement getWarehouseProducts()
- [x] Implement addProductToWarehouse()
- [x] Implement updateProductQuantity()
- [x] Implement transferBetweenWarehouses()
- [x] Create hybrid WarehouseRepository
- [x] Add low stock notification logic (warehouse_products.low_stock field)
- [x] Add RLS policies for warehouses (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

## Phase 5: Transactional Repositories

### 5.1 Sale Repository
- [x] Create `SaleSupabaseDataSource`
- [x] Implement getAllSales() with pagination
- [x] Implement getSaleById() with full relations
- [x] Implement createSale() with transaction
- [x] Implement getPendingSales()
- [x] Implement getPendingSaleDetails()
- [x] Implement getDueSales()
- [x] Implement searchSalesByReference()
- [x] Implement completePendingSale()
- [x] Implement cancelSale()
- [x] Implement applyCoupon()
- [x] Create hybrid SaleRepository
- [x] Add real-time subscription for new sales (realtime_service.dart)
- [x] Add RLS policies for sales (supabase/migrations/002_rls_policies.sql)
- [ ] Write comprehensive unit tests
- [ ] Write integration tests

### 5.2 Purchase Repository
- [x] Create `PurchaseSupabaseDataSource`
- [x] Implement getAllPurchases()
- [x] Implement getPurchaseById()
- [x] Implement createPurchase() with transaction
- [x] Implement updatePurchase()
- [x] Implement deletePurchase()
- [x] Implement handleDuePayments()
- [x] Implement getPurchasesBySupplier()
- [x] Implement getPurchasesByWarehouse()
- [x] Create hybrid PurchaseRepository
- [ ] Implement purchase returns (moved to 5.3)
- [x] Add RLS policies for purchases (supabase/migrations/002_rls_policies.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 5.3 Return Repositories
- [x] Create `SaleReturnSupabaseDataSource` (supabase/migrations/004_returns_adjustments_transfers.sql)
- [x] Create `PurchaseReturnSupabaseDataSource` (supabase/migrations/004_returns_adjustments_transfers.sql)
- [x] Implement return tables with RLS (sale_returns, purchase_returns)
- [x] Create hybrid ReturnRepository (lib/features/pos/return/data/repositories/return_repository.dart)
- [ ] Implement createSaleReturn() with transaction RPC
- [ ] Implement updateCustomerBalance() within transaction
- [ ] Implement restoreProductQuantities() within transaction
- [ ] Implement validateReturnQuantities()
- [ ] Implement purchase return logic
- [x] Add RLS policies for return tables (supabase/migrations/004_returns_adjustments_transfers.sql)
- [ ] Write unit tests
- [ ] Write integration tests

### 5.4 Adjustment Repository
- [x] Create adjustments tables (supabase/migrations/004_returns_adjustments_transfers.sql)
- [x] Add RLS policies for adjustments (supabase/migrations/004_returns_adjustments_transfers.sql)
- [ ] Create `AdjustmentSupabaseDataSource`
- [ ] Implement createAdjustment()
- [ ] Implement adjustment items handling
- [ ] Implement quantity updates
- [ ] Support increase/decrease types
- [ ] Write unit tests

### 5.5 Transfer Repository
- [x] Create transfers and transfer_items tables (supabase/migrations/003_rpc_functions.sql, 004_returns_adjustments_transfers.sql)
- [x] Add RLS policies for transfers (supabase/migrations/004_returns_adjustments_transfers.sql)
- [ ] Create `TransferSupabaseDataSource`
- [ ] Implement createTransfer()
- [ ] Implement transfer items handling
- [ ] Implement approveTransfer() with quantity updates
- [ ] Implement validateSourceWarehouseQuantity()
- [ ] Write unit tests

## Phase 6: Financial & Admin Repositories

### 6.1 Expense Repository
- [x] Create expenses and expense_categories tables (supabase/migrations/005_financial_tables.sql)
- [x] Add RLS policies for expenses (supabase/migrations/005_financial_tables.sql)
- [ ] Create `ExpenseSupabaseDataSource`
- [ ] Implement getAllExpenses()
- [ ] Implement createExpense()
- [ ] Implement updateBankAccountBalance() within transaction
- [ ] Implement getExpensesByShift()
- [ ] Write unit tests

### 6.2 Revenue Repository
- [x] Create revenues and revenue_categories tables (supabase/migrations/005_financial_tables.sql)
- [x] Add RLS policies for revenues (supabase/migrations/005_financial_tables.sql)
- [ ] Create `RevenueSupabaseDataSource`
- [ ] Implement getAllRevenues()
- [ ] Implement createRevenue()
- [ ] Implement updateBankAccountBalance() within transaction
- [ ] Write unit tests

### 6.3 Bank Account Repository
- [x] Create bank_accounts table (supabase/migrations/005_financial_tables.sql)
- [x] Add RLS policies for bank_accounts (supabase/migrations/005_financial_tables.sql)
- [ ] Create `BankAccountSupabaseDataSource`
- [ ] Implement getAllBankAccounts()
- [ ] Implement getBankAccountById()
- [ ] Implement createBankAccount()
- [ ] Implement updateBankAccount()
- [ ] Implement updateBalance()
- [ ] Support default account selection
- [ ] Write unit tests

### 6.4 Financial Transaction Repository
- [x] Create financial_transactions table (supabase/migrations/005_financial_tables.sql)
- [x] Add RLS policies for financial_transactions (supabase/migrations/005_financial_tables.sql)
- [ ] Create `FinancialTransactionSupabaseDataSource`
- [ ] Implement getAllTransactions()
- [ ] Implement createTransaction()
- [ ] Implement getTransactionsByDateRange()
- [ ] Write unit tests

### 6.5 Shift Repository
- [x] Create shifts table (supabase/migrations/005_financial_tables.sql)
- [x] Add RLS policies for shifts (supabase/migrations/005_financial_tables.sql)
- [ ] Create `ShiftSupabaseDataSource`
- [ ] Implement startShift()
- [ ] Implement endShift()
- [ ] Implement calculateTotalSales()
- [ ] Implement calculateTotalExpenses()
- [ ] Implement getShiftById()
- [ ] Implement getActiveShiftByCashier()
- [ ] Write unit tests
- [ ] Write integration tests

### 6.6 Admin & Roles Repository
- [ ] Create `AdminSupabaseDataSource`
- [ ] Implement getAllAdmins() with role data
- [ ] Implement getAdminById()
- [ ] Implement createAdmin() with password hashing
- [ ] Implement updateAdmin()
- [ ] Implement deleteAdmin()
- [ ] Implement getRoles() with permissions
- [ ] Implement createRole()
- [ ] Implement updateRolePermissions()
- [ ] Implement validatePermissions()
- [ ] Add RLS policies for admins and roles
- [ ] Write unit tests
- [ ] Write integration tests

## Phase 7: Feature Repositories

### 7.1 Notification Repository
- [ ] Create `NotificationSupabaseDataSource`
- [ ] Implement getNotifications() with filtering
- [ ] Implement getUnreadNotificationsCount()
- [ ] Implement markAsRead()
- [ ] Implement markAllAsRead()
- [ ] Add real-time subscription for notifications
- [ ] Support notification types and severity levels
- [ ] Add RLS policies for notifications
- [ ] Write unit tests
- [ ] Write integration tests

### 7.2 POS Repository
- [ ] Create `POSSupabaseDataSource`
- [ ] Implement getPOSProducts() with filters
- [ ] Implement getFeaturedProducts()
- [ ] Implement getCategoryProducts()
- [ ] Implement getBrandProducts()
- [ ] Implement validateCashierShift()
- [ ] Add bundle products support
- [ ] Add product prices and warehouse quantities
- [ ] Optimize queries for POS performance
- [ ] Write unit tests
- [ ] Write integration tests

### 7.3 Online Order Repository
- [ ] Create `OnlineOrderSupabaseDataSource`
- [ ] Implement getAllOnlineOrders()
- [ ] Implement getOnlineOrderById()
- [ ] Implement createOnlineOrder() with items
- [ ] Implement updateOrderStatus()
- [ ] Implement handleCurrencyConversion()
- [ ] Add RLS policies for online_orders
- [ ] Write unit tests

### 7.4 Points & Rewards Service
- [ ] Create `PointsSupabaseService`
- [ ] Implement calculateEarnedPoints()
- [ ] Implement updateCustomerPoints()
- [ ] Implement validateAvailablePoints()
- [ ] Implement deductPoints()
- [ ] Implement points rules configuration
- [ ] Add RLS policies for points-related data
- [ ] Write unit tests

### 7.5 Tax Repository
- [ ] Create `TaxSupabaseDataSource`
- [ ] Implement getAllTaxes()
- [ ] Implement createTax()
- [ ] Implement updateTax()
- [ ] Add RLS policies for taxes
- [ ] Write unit tests

### 7.6 Discount Repository
- [ ] Create `DiscountSupabaseDataSource`
- [ ] Implement getAllDiscounts()
- [ ] Implement createDiscount() with percentage/fixed types
- [ ] Implement updateDiscount()
- [ ] Add RLS policies for discounts
- [ ] Write unit tests

### 7.7 Coupon Repository
- [ ] Create `CouponSupabaseDataSource`
- [ ] Implement getAllCoupons()
- [ ] Implement createCoupon()
- [ ] Implement validateCoupon() with date/usage checks
- [ ] Implement incrementUsageCount()
- [ ] Add RLS policies for coupons
- [ ] Write unit tests

### 7.8 Variation Repository
- [ ] Create `VariationSupabaseDataSource`
- [ ] Implement getAllVariations() with options
- [ ] Implement createVariation()
- [ ] Implement createVariationOptions()
- [ ] Add RLS policies for variations
- [ ] Write unit tests

### 7.9 Bundle Repository
- [ ] Create `BundleSupabaseDataSource`
- [ ] Implement getAllBundles()
- [ ] Implement createBundle() with bundle_products
- [ ] Implement validateBundleAvailability()
- [ ] Add RLS policies for bundles
- [ ] Write unit tests

## Phase 8: Row Level Security (RLS) ✅ COMPLETE

### 8.1 Core Table Policies ✅
- [x] Create RLS policies for products table (supabase/migrations/002_rls_policies.sql)
- [x] Create RLS policies for sales table (supabase/migrations/002_rls_policies.sql)
- [x] Create RLS policies for purchases table (supabase/migrations/002_rls_policies.sql)
- [x] Create RLS policies for customers table (supabase/migrations/002_rls_policies.sql)
- [x] Create RLS policies for suppliers table (supabase/migrations/002_rls_policies.sql)
- [x] Create RLS policies for warehouses table (supabase/migrations/002_rls_policies.sql)

### 8.2 Admin & Auth Policies ✅
- [x] Create RLS policies for user_profiles table (supabase/migrations/002_rls_policies.sql)
- [x] Create RLS policies for return tables (supabase/migrations/004_returns_adjustments_transfers.sql)
- [x] Create RLS policies for adjustment tables (supabase/migrations/004_returns_adjustments_transfers.sql)
- [x] Create RLS policies for shifts table (supabase/migrations/005_financial_tables.sql)
- [ ] Create super_admin bypass policies

### 8.3 Financial Policies
- [ ] Create RLS policies for expenses table
- [ ] Create RLS policies for revenues table
- [ ] Create RLS policies for bank_accounts table
- [ ] Create RLS policies for financial_transactions table

### 8.4 Reference Data Policies
- [ ] Create RLS policies for categories table (read-all)
- [ ] Create RLS policies for brands table (read-all)
- [ ] Create RLS policies for units table (read-all)
- [ ] Create RLS policies for location tables (read-all)
- [ ] Create RLS policies for payment_methods table

### 8.5 Feature Policies
- [ ] Create RLS policies for notifications table
- [ ] Create RLS policies for online_orders table
- [ ] Create RLS policies for taxes, discounts, coupons
- [ ] Create RLS policies for variations, bundles

### 8.6 Transaction Policies
- [ ] Create RLS policies for adjustments table
- [ ] Create RLS policies for transfers table
- [ ] Create RLS policies for sale_returns table
- [ ] Create RLS policies for purchase_returns table

### 8.7 RLS Testing
- [ ] Test RLS policies for admin role
- [ ] Test RLS policies for cashier role
- [ ] Test RLS policies for manager role
- [ ] Test RLS policies for super_admin role
- [ ] Test cross-warehouse data isolation
- [ ] Test unauthorized access attempts
- [ ] Document all RLS policies

## Phase 9: Model Updates

### 9.1 Core Model Updates
- [ ] Update Product model for Supabase JSON structure
- [ ] Update Sale model for Supabase JSON structure
- [ ] Update Purchase model for Supabase JSON structure
- [ ] Update Customer model for Supabase JSON structure
- [ ] Update Admin model for Supabase JSON structure

### 9.2 Supporting Model Updates
- [ ] Update SaleItem model
- [ ] Update PurchaseItem model
- [ ] Update ProductWarehouse model
- [ ] Update FinancialTransaction model
- [ ] Update Notification model

### 9.3 Reference Model Updates
- [ ] Update Category model with nested support
- [ ] Update Brand model with image URL
- [ ] Update Unit model
- [ ] Update City/Country/Zone models

### 9.4 JSON Serialization
- [ ] Add fromJson methods to all models
- [ ] Add toJson methods to all models
- [ ] Handle UUID field parsing
- [ ] Handle nullable fields
- [ ] Handle timestamp with timezone
- [ ] Handle nested object parsing
- [ ] Update freezed annotations if using freezed

## Phase 10: Testing & Validation

### 10.1 Unit Tests
- [ ] Write unit tests for SupabaseClientWrapper
- [ ] Write unit tests for ErrorHandler
- [ ] Write unit tests for MigrationService
- [ ] Write unit tests for StorageService
- [ ] Write unit tests for RealtimeService
- [ ] Write unit tests for AuthService

### 10.2 Repository Unit Tests
- [ ] Write unit tests for ProductRepository
- [ ] Write unit tests for SaleRepository
- [ ] Write unit tests for PurchaseRepository
- [ ] Write unit tests for CustomerRepository
- [ ] Write unit tests for WarehouseRepository
- [ ] Write unit tests for AdminRepository
- [ ] Write unit tests for ShiftRepository
- [ ] Write unit tests for FinancialRepository
- [ ] Write unit tests for NotificationRepository

### 10.3 Integration Tests
- [ ] Write Supabase integration tests
- [ ] Write repository integration tests
- [ ] Write authentication flow tests
- [ ] Write image upload/download tests
- [ ] Write real-time subscription tests
- [ ] Write RLS policy validation tests

### 10.4 Performance Testing
- [ ] Benchmark Supabase queries vs Dio
- [ ] Load test with concurrent users
- [ ] Test pagination performance
- [ ] Test real-time update performance
- [ ] Test image upload performance

### 10.5 Data Integrity Testing
- [ ] Validate all data migrations
- [ ] Test transaction rollbacks
- [ ] Test data consistency after operations
- [ ] Test foreign key constraints
- [ ] Test unique constraints

## Phase 11: Documentation

### 11.1 Technical Documentation
- [ ] Document Supabase client setup
- [ ] Document repository pattern usage
- [ ] Document error handling approach
- [ ] Document migration service usage
- [ ] Document real-time service usage
- [ ] Document storage service usage
- [ ] Document RLS policies

### 11.2 API Documentation
- [ ] Document all repository methods
- [ ] Document Supabase query patterns
- [ ] Document available filters and joins
- [ ] Document real-time event types

### 11.3 Deployment Documentation
- [ ] Document environment setup
- [ ] Document Supabase project configuration
- [ ] Document RLS policy deployment
- [ ] Document migration steps

## Phase 12: Cleanup & Migration

### 12.1 Remove Dio Dependencies
- [ ] Remove dio from pubspec.yaml
- [ ] Delete DioHelper class
- [ ] Delete endpoints.dart
- [ ] Remove Dio interceptors
- [ ] Clean up Dio-related configurations

### 12.2 Final Migration
- [ ] Enable all feature flags for Supabase
- [ ] Disable Dio mode for all repositories
- [ ] Remove hybrid repository wrappers
- [ ] Delete Dio data sources
- [ ] Run full regression tests

### 12.3 Code Cleanup
- [ ] Remove unused imports
- [ ] Remove dead code
- [ ] Refactor if needed
- [ ] Update code documentation
- [ ] Run static analysis
- [ ] Fix all lint warnings

### 12.4 Post-Migration
- [ ] Monitor error rates
- [ ] Monitor performance metrics
- [ ] Collect user feedback
- [ ] Create incident response plan
- [ ] Document lessons learned

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Total Phases | 12 |
| Total Tasks | 200+ |
| Repositories to Migrate | 20+ |
| Tables with RLS | 50+ |
| Unit Tests Required | 30+ |
| Integration Tests Required | 15+ |

## Timeline Estimate

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: Foundation | 1 week | Week 1 |
| Phase 2: Auth & Core | 1 week | Week 2 |
| Phase 3: Reference Data | 1 week | Week 3 |
| Phase 4: Core Business | 1 week | Week 4 |
| Phase 5: Transactional | 1 week | Week 5 |
| Phase 6: Financial & Admin | 1 week | Week 6 |
| Phase 7: Features | 1 week | Week 7 |
| Phase 8: RLS | 1 week | Week 8 |
| Phase 9: Models | 0.5 week | Week 8.5 |
| Phase 10: Testing | 1 week | Week 9.5 |
| Phase 11: Documentation | 0.5 week | Week 10 |
| Phase 12: Cleanup | 0.5 week | Week 10.5 |

**Total Estimated Duration: 10-11 weeks**

**Critical Path:** Phase 1 → Phase 2 → Phase 4 → Phase 5 → Phase 10 → Phase 12
