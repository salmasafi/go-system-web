# Supabase Migration Setup Guide

## Overview
This guide documents the migration from Dio REST API to Supabase for the SysteGo ERP system.

## Phase 1: Foundation & Setup ✅

### 1. Database Schema
All database migrations are located in `supabase/migrations/`:

- `001_initial_schema.sql` - Complete database schema with all tables
- `002_rls_policies.sql` - Row Level Security policies
- `003_rpc_functions.sql` - Stored procedures for transactions

### Tables Created:
- **Foundation**: migration_logs, user_profiles
- **Reference Data**: countries, cities, zones, categories, brands, units, payment_methods
- **Core Business**: products, product_prices, customers, customer_groups, suppliers, warehouses, warehouse_products
- **Transactional**: sales, sale_items, sale_payments, purchases, purchase_items, invoices, due_payments, transfers

### 2. Environment Configuration

#### Required Files:
- `.env.development` - Development environment variables
- `.env.production` - Production environment variables

#### Required Variables:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 3. Dependencies (pubspec.yaml)
```yaml
dependencies:
  supabase_flutter: ^2.8.3
  flutter_dotenv: ^6.0.1
```

## Phase 2: Core Services ✅

### Created Services:
1. **Supabase Client** (`lib/core/supabase/supabase_client.dart`)
   - Singleton pattern
   - Environment-based initialization

2. **Auth Service** (`lib/features/admin/auth/data/services/supabase_auth_service.dart`)
   - Email/password authentication
   - Session management
   - Token refresh

3. **Storage Service** (`lib/core/supabase/storage_service.dart`)
   - Image upload with compression
   - Folder structure: products/, brands/, categories/, suppliers/
   - Public URL generation

4. **Error Handler** (`lib/core/supabase/supabase_error_handler.dart`)
   - Bilingual error messages (Arabic/English)
   - Exception type handling

5. **Migration Service** (`lib/core/migration/migration_service.dart`)
   - Feature flags for gradual migration
   - Repository switching (Dio/Supabase)

## Phase 3-5: Repository Migration ✅

### Completed Hybrid Repositories:
| Repository | Status | File |
|------------|--------|------|
| Category | ✅ | `lib/features/admin/categories/data/repositories/category_repository.dart` |
| Brand | ✅ | `lib/features/admin/brands/data/repositories/brand_repository.dart` |
| Unit | ✅ | `lib/features/admin/units/data/repositories/unit_repository.dart` |
| Product | ✅ | `lib/features/admin/product/data/repositories/product_repository.dart` |
| Customer | ✅ | `lib/features/admin/customer/data/repositories/customer_repository.dart` |
| Supplier | ✅ | `lib/features/admin/suppliers/data/repositories/supplier_repository.dart` |
| Warehouse | ✅ | `lib/features/admin/warehouses/data/repositories/warehouse_repository.dart` |
| Sale | ✅ | `lib/features/pos/sales/data/repositories/sale_repository.dart` |
| Purchase | ✅ | `lib/features/admin/purchase/data/repositories/purchase_repository.dart` |

### Repository Pattern:
Each repository follows the hybrid pattern:
- Interface definition
- Supabase data source implementation
- Dio (legacy) data source implementation
- Hybrid repository with feature flag switching

## Row Level Security (RLS)

### Policies Implemented:
- **Admin/Managers**: Full access to all tables
- **Cashiers**: Read access to products, customers; Create sales
- **Warehouse**: Inventory management access
- **Authenticated Users**: Read access to reference data

### Key Policies:
- Users can only view/modify their own profile
- Sales are filtered by warehouse access
- Purchase data restricted to managers
- Financial data admin-only

## Stored Procedures (RPC)

### Critical Functions:
1. `transfer_product_between_warehouses()` - Atomic warehouse transfers
2. `create_sale_with_items()` - Transactional sale creation
3. `cancel_sale()` - Sale cancellation with inventory restore
4. `create_purchase_with_items()` - Transactional purchase creation
5. `delete_purchase()` - Purchase deletion with inventory adjustment
6. `process_purchase_payment()` - Handle due payments
7. `update_warehouse_stats()` - Maintain warehouse statistics

## Testing

### Manual Testing Checklist:
- [ ] Supabase connection
- [ ] Authentication flow
- [ ] Image upload/delete
- [ ] CRUD operations for each repository
- [ ] Real-time subscriptions
- [ ] Error handling

### Unit Tests: Pending
### Integration Tests: Pending

## Next Steps (Pending):
1. Phase 5.3: Return Repositories (Sale & Purchase returns)
2. Phase 5.4: Adjustment Repository
3. Phase 5.5: Transfer Repository (UI workflow)
4. Phase 6: Financial Repositories (Expenses, Revenue, Bank Accounts)
5. Phase 7: Feature Repositories (Notifications, POS, Online Orders)

## Running Migrations:

```bash
# Apply migrations to Supabase
supabase db push

# Or run via SQL Editor in Supabase Dashboard
# Copy contents of migration files and execute
```

## Important Notes:

1. **Dependencies**: Run `flutter pub get` to resolve all dependencies
2. **RLS**: All tables have RLS enabled - policies control access
3. **Migrations**: Use feature flags to switch between Dio and Supabase
4. **Transactions**: Complex operations use RPC functions for atomicity
