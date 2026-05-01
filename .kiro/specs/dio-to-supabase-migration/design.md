# Design Document: Migration from Dio to Supabase

## 1. Overview

### 1.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Flutter Application                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │     UI      │  │   BLoC/Cubit│  │  Use Cases  │  │    Repositories     │ │
│  │   Layer     │◄─┤   Layer     │◄─┤   Layer     │◄─┤     Layer           │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └──────────┬──────────┘ │
│                                                               │             │
│                              ┌────────────────────────────────┘             │
│                              │                                               │
│  ┌───────────────────────────┴─────────────────────────────────────────────┐  │
│  │                     Data Source Layer                                  │  │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐             │  │
│  │  │  Supabase      │  │    Storage     │  │   Real-Time    │             │  │
│  │  │  Client        │  │    Service     │  │   Service      │             │  │
│  │  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘             │  │
│  └──────────┼────────────────────┼────────────────────┼───────────────────┘  │
└─────────────┼────────────────────┼────────────────────┼───────────────────────┘
              │                    │                    │
              ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Supabase Platform                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  PostgreSQL │  │    Auth     │  │   Storage   │  │   Realtime API      │ │
│  │  Database   │  │   Service   │  │   Buckets   │  │   (WebSocket)       │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              Repository Layer                                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────┐ │
│  │ ProductRepository│  │  SaleRepository  │  │PurchaseRepository│  │CustomerRepo │ │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  └──────┬──────┘ │
│           │                     │                    │                  │         │
│  ┌────────▼─────────┐  ┌─────────▼────────┐  ┌────────▼─────────┐  ┌──────▼──────┐ │
│  │  AdminRepository │  │FinancialRepository│  │WarehouseRepository│ │ShiftRepository│ │
│  └────────┬─────────┘  └─────────┬────────┘  └────────┬─────────┘  └──────┬──────┘ │
│           │                      │                    │                   │         │
│  ┌────────▼─────────┐  ┌─────────▼────────┐  ┌────────▼─────────┐  ┌──────▼──────┐ │
│  │  AuthRepository  │  │ NotificationRepo │  │ CategoryRepository│ │  BrandRepo   │ │
│  └────────┬─────────┘  └─────────┬────────┘  └────────┬─────────┘  └──────┬──────┘ │
│           │                      │                    │                   │         │
│           └──────────────────────┼────────────────────┼───────────────────┘         │
│                                  │                    │                             │
└──────────────────────────────────┼────────────────────┼─────────────────────────────┘
                                   │                    │
                                   ▼                    ▼
                     ┌─────────────────────┐  ┌─────────────────────┐
                     │   SupabaseClient    │  │   MigrationService  │
                     │   (Singleton)       │  │   (Feature Flags)   │
                     └──────────┬──────────┘  └─────────────────────┘
                                │
                     ┌──────────▼──────────┐
                     │  Supabase Flutter SDK │
                     └─────────────────────┘
```

### 1.3 Data Flow Diagram

```
┌─────────┐    ┌─────────┐    ┌─────────────┐    ┌──────────────┐    ┌───────────┐
│  User   │───►│   UI    │───►│  Repository │───►│   Supabase   │───►│  Database │
│ Action  │    │  Event  │    │   Method    │    │    Client    │    │  (PostgreSQL)
└─────────┘    └─────────┘    └─────────────┘    └──────────────┘    └───────────┘
                                     │                                    │
                                     │              ┌─────────────────────┘
                                     │              │
                                     │         ┌────▼────┐
                                     │         │  RLS    │
                                     │         │Policies │
                                     │         └────┬────┘
                                     │              │
┌─────────┐    ┌─────────┐    ┌──────▼─────┐    ┌───▼────────┐    ┌───────────┐
│  User   │◄───│  State  │◄───│   Model    │◄───│  Response  │◄───│   Query   │
│ Update  │    │ Update  │    │  (fromJson)│    │  (JSON)    │    │  Result   │
└─────────┘    └─────────┘    └────────────┘    └────────────┘    └───────────┘
```

## 2. Technical Design

### 2.1 Core Services

#### 2.1.1 Supabase Client Configuration

```dart
// lib/core/supabase/supabase_client.dart
class SupabaseClientWrapper {
  static SupabaseClient? _instance;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: kDebugMode,
    );
    _instance = Supabase.instance.client;
  }
  
  static SupabaseClient get instance {
    if (_instance == null) {
      throw Exception('Supabase not initialized');
    }
    return _instance!;
  }
}
```

#### 2.1.2 Migration Service with Feature Flags

```dart
// lib/core/migration/migration_service.dart
class MigrationService {
  static final Map<String, DataSource> _repositorySources = {};
  
  static void configure(String repository, DataSource source) {
    _repositorySources[repository] = source;
  }
  
  static DataSource getSource(String repository) {
    return _repositorySources[repository] ?? DataSource.supabase;
  }
}

enum DataSource { dio, supabase }
```

#### 2.1.3 Error Handler

```dart
// lib/core/error/supabase_error_handler.dart
class SupabaseErrorHandler {
  static AppException handleError(dynamic error) {
    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    } else if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is StorageException) {
      return _handleStorageError(error);
    } else if (error is RealtimeException) {
      return _handleRealtimeError(error);
    }
    return AppException.unknown(error.toString());
  }
  
  static AppException _handlePostgrestError(PostgrestException error) {
    switch (error.code) {
      case 'PGRST301':
        return AppException.unauthorized('session_expired');
      case '23505':
        return AppException.conflict('duplicate_entry');
      case '23503':
        return AppException.validation('foreign_key_violation');
      default:
        return AppException.server(error.message);
    }
  }
}
```

### 2.2 Repository Pattern

All repositories follow this pattern:

```dart
// lib/features/products/data/repositories/product_repository_impl.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _client;
  final StorageService _storage;
  final MigrationService _migration;
  
  ProductRepositoryImpl(this._client, this._storage, this._migration);
  
  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*, brands(*), categories(*), units(*)')
          .order('created_at', ascending: false);
      
      final products = (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
      
      return Right(products);
    } catch (error) {
      return Left(SupabaseErrorHandler.handleError(error));
    }
  }
}
```

### 2.3 Database Schema Mapping

#### 2.3.1 Table Relationships

```
admins (1) ──────── (N) sales ──────── (N) sale_items
    │                  │
    │                  ├────────────── (N) sale_payments
    │                  │
    │                  └────────────── (1) customers
    │                                     │
    │                                     └─────── (1) customer_groups
    │
    ├──────────── (N) purchases ──────── (N) purchase_items
    │                  │
    │                  └────────────── (1) suppliers
    │
    ├──────────── (N) roles ──────────── (N) role_permissions
    │
    ├──────────── (N) warehouses ─────── (N) product_warehouses ─────── (1) products
    │                                                               │
    │                                                               ├─ (1) brands
    │                                                               ├─ (1) categories
    │                                                               ├─ (1) units
    │                                                               ├─ (N) product_prices ── (N) variation_options
    │                                                               │                                    │
    │                                                               │                                    └─ (1) variations
    │                                                               └─ (N) bundles ─────────── (N) bundle_products
    │
    ├──────────── (N) shifts ────────── (N) shift_transactions
    │
    ├──────────── (N) expenses ──────── (1) expense_categories
    │
    ├──────────── (N) revenues ──────── (1) revenue_categories
    │
    ├──────────── (N) notifications
    │
    ├──────────── (N) adjustments ────── (N) adjustment_items
    │
    ├──────────── (N) transfers ──────── (N) transfer_items
    │
    ├──────────── (N) sale_returns ───── (N) sale_return_items
    │
    ├──────────── (N) purchase_returns ─ (N) purchase_return_items
    │
    ├──────────── (N) online_orders ──── (N) online_order_items
    │
    ├──────────── (N) taxes
    │
    ├──────────── (N) discounts
    │
    ├──────────── (N) coupons
    │
    ├──────────── (N) bank_accounts
    │
    ├──────────── (N) payment_methods
    │
    └──────────── (N) financial_transactions

locations: countries (1) ─── (N) cities (1) ─── (N) zones
```

### 2.4 Real-Time Subscriptions

```dart
// lib/core/supabase/realtime_service.dart
class RealtimeService {
  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};
  
  RealtimeService(this._client);
  
  void subscribeToTable(
    String table, {
    required Function(dynamic payload) onInsert,
    required Function(dynamic payload) onUpdate,
    required Function(dynamic payload) onDelete,
    String? filterColumn,
    dynamic filterValue,
  }) {
    final channelName = '${table}_${filterValue ?? 'all'}';
    
    var query = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: filterColumn != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: filterColumn,
                  value: filterValue,
                )
              : null,
          callback: (payload) {
            switch (payload.eventType) {
              case PostgresChangeEvent.insert:
                onInsert(payload.newRecord);
                break;
              case PostgresChangeEvent.update:
                onUpdate(payload.newRecord);
                break;
              case PostgresChangeEvent.delete:
                onDelete(payload.oldRecord);
                break;
            }
          },
        );
    
    _channels[channelName] = query.subscribe();
  }
  
  void unsubscribe(String channelName) {
    _channels[channelName]?.unsubscribe();
    _channels.remove(channelName);
  }
}
```

### 2.5 Storage Service

```dart
// lib/core/supabase/storage_service.dart
class StorageService {
  final SupabaseClient _client;
  final String _bucketName = 'system-assets';
  
  StorageService(this._client);
  
  Future<String> uploadImage({
    required File file,
    required String folder, // products, brands, categories
    required String fileName,
    int? maxWidth,
    int quality = 85,
  }) async {
    try {
      // Compress image if needed
      File processedFile = file;
      if (maxWidth != null) {
        processedFile = await _compressImage(file, maxWidth, quality);
      }
      
      final uniqueFileName = '${folder}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      final response = await _client.storage
          .from(_bucketName)
          .upload(uniqueFileName, processedFile);
      
      return _client.storage.from(_bucketName).getPublicUrl(uniqueFileName);
    } catch (e) {
      throw SupabaseErrorHandler.handleError(e);
    }
  }
  
  Future<void> deleteImage(String path) async {
    await _client.storage.from(_bucketName).remove([path]);
  }
}
```

### 2.6 Authentication Service

```dart
// lib/features/auth/data/services/supabase_auth_service.dart
class SupabaseAuthService implements AuthService {
  final SupabaseClient _client;
  final CacheHelper _cache;
  
  SupabaseAuthService(this._client, this._cache);
  
  @override
  Future<Either<Failure, Admin>> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return Left(AuthFailure('authentication_failed'));
      }
      
      // Fetch admin details
      final adminData = await _client
          .from('admins')
          .select('*, roles(*)')
          .eq('email', email)
          .single();
      
      final admin = Admin.fromJson(adminData);
      
      // Store session
      await _cache.saveToken(response.session!.accessToken);
      await _cache.saveAdminData(admin);
      
      return Right(admin);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }
  
  @override
  Future<void> logout() async {
    await _client.auth.signOut();
    await _cache.clearCache();
  }
  
  @override
  Future<Either<Failure, Admin?>> checkSession() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return Right(null);
    }
    
    final admin = await _cache.getAdminData();
    return Right(admin);
  }
}
```

### 2.7 RLS Policies Strategy

```sql
-- Row Level Security Policies Template

-- Enable RLS on all tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
-- ... repeat for all 50+ tables

-- Products: Admins can view products from their warehouse
CREATE POLICY "Admins view products from their warehouse" ON products
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM admins a
            WHERE a.id = auth.uid()
            AND a.warehouse_id = ANY(products.warehouse_ids)
        )
    );

-- Sales: Cashiers can create sales, managers can view all
CREATE POLICY "Cashiers create sales" ON sales
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM admins a
            JOIN roles r ON a.role_id = r.id
            WHERE a.id = auth.uid()
            AND (r.permissions->>'can_create_sales')::boolean = true
        )
    );

-- Reference tables: Allow read access to all authenticated users
CREATE POLICY "Authenticated read categories" ON categories
    FOR SELECT TO authenticated USING (true);

-- Super admin: Full access
CREATE POLICY "Super admin full access" ON products
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM admins a
            JOIN roles r ON a.role_id = r.id
            WHERE a.id = auth.uid()
            AND r.name = 'super_admin'
        )
    );
```

## 3. Migration Strategy

### 3.1 Phased Migration Approach

```
Phase 1: Foundation (Week 1-2)
├── Setup Supabase project
├── Configure Supabase Client
├── Setup Environment variables
├── Create base repositories
├── Implement Auth Service
└── Add Migration Service with feature flags

Phase 2: Reference Data (Week 2-3)
├── Categories Repository
├── Brands Repository
├── Units Repository
├── Countries/Cities/Zones Repositories
├── Payment Methods Repository
└── Testing & Validation

Phase 3: Core Entities (Week 3-4)
├── Products Repository (with variations, bundles)
├── Customers Repository
├── Suppliers Repository
├── Warehouses Repository
└── Testing & Validation

Phase 4: Transactional Data (Week 4-5)
├── Sales Repository (with items, payments)
├── Purchases Repository
├── Returns Repositories
├── Adjustments & Transfers
└── Testing & Validation

Phase 5: Financial & Admin (Week 5-6)
├── Expenses & Revenues Repository
├── Bank Accounts Repository
├── Shifts Repository
├── Admin & Roles Repository
└── Testing & Validation

Phase 6: Features (Week 6-7)
├── Notifications Repository
├── POS Features
├── Online Orders
├── Points & Rewards
└── Testing & Validation

Phase 7: Storage & Real-Time (Week 7-8)
├── Storage Service (Images)
├── Real-Time Service
├── RLS Policies
└── Full Integration Testing

Phase 8: Cleanup (Week 8)
├── Remove Dio dependencies
├── Remove old endpoints
├── Code cleanup
└── Performance optimization
```

### 3.2 Repository Migration Pattern

Each repository migration follows this pattern:

```dart
// Dual-mode repository during migration
class HybridProductRepository implements ProductRepository {
  final DioProductRepository _dioRepo;
  final SupabaseProductRepository _supabaseRepo;
  
  HybridProductRepository(this._dioRepo, this._supabaseRepo);
  
  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    if (MigrationService.getSource('products') == DataSource.supabase) {
      return _supabaseRepo.getAllProducts();
    }
    return _dioRepo.getAllProducts();
  }
}
```

## 4. Dependencies

### 4.1 Updated pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.8.0
  
  # State Management
  flutter_bloc: ^8.1.4
  
  # Functional Programming
  dartz: ^0.10.1
  
  # Caching
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # Image Handling
  image_picker: ^1.0.7
  flutter_image_compress: ^2.3.0
  cached_network_image: ^3.3.1
  
  # Utils
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  
dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
```

## 5. Environment Configuration

### 5.1 Environment Variables

```
# .env.development
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
ENVIRONMENT=development

# .env.production
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ENVIRONMENT=production
```

### 5.2 Configuration Loader

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final String environment;
  
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env.${kReleaseMode ? 'production' : 'development'}');
    
    supabaseUrl = dotenv.env['SUPABASE_URL']!;
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
    environment = dotenv.env['ENVIRONMENT']!;
    
    _validateConfig();
  }
  
  static void _validateConfig() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Missing required environment variables');
    }
  }
}
```

## 6. Testing Strategy

### 6.1 Test Structure

```
test/
├── unit/
│   ├── core/
│   │   ├── supabase_client_test.dart
│   │   ├── error_handler_test.dart
│   │   └── migration_service_test.dart
│   └── features/
│       ├── auth/
│       │   └── supabase_auth_service_test.dart
│       └── products/
│           └── product_repository_test.dart
├── integration/
│   ├── supabase_integration_test.dart
│   └── repositories_integration_test.dart
└── fixtures/
    └── supabase_responses/
```

### 6.2 Repository Test Template

```dart
// test/unit/features/products/product_repository_test.dart
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late ProductRepositoryImpl repository;
  late MockSupabaseClient mockClient;
  
  setUp(() {
    mockClient = MockSupabaseClient();
    repository = ProductRepositoryImpl(mockClient, MockStorageService(), MockMigrationService());
  });
  
  group('getAllProducts', () {
    test('should return list of products on success', () async {
      // Arrange
      final expectedProducts = [ProductModel(...)];
      when(mockClient.from('products').select(any)).thenAnswer(
        (_) async => [...productJsonList],
      );
      
      // Act
      final result = await repository.getAllProducts();
      
      // Assert
      expect(result, Right(expectedProducts));
    });
    
    test('should return failure on error', () async {
      // Arrange
      when(mockClient.from('products').select(any))
          .thenThrow(PostgrestException(message: 'Error'));
      
      // Act
      final result = await repository.getAllProducts();
      
      // Assert
      expect(result, Left(ServerFailure('Error')));
    });
  });
}
```

## 7. Performance Considerations

### 7.1 Query Optimization

- Use selective columns in `.select()` instead of `*`
- Implement pagination with `.range()`
- Use `.limit()` for single record queries
- Add appropriate PostgreSQL indexes
- Use materialized views for complex reports

### 7.2 Caching Strategy

```dart
class CacheStrategy {
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  
  static Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    Duration? cacheDuration,
  }) async {
    final cached = await CacheHelper.get<T>(key);
    if (cached != null) {
      return cached;
    }
    
    final data = await fetch();
    await CacheHelper.set(key, data, duration: cacheDuration ?? defaultCacheDuration);
    return data;
  }
}
```

## 8. Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Data migration issues | Medium | High | Implement dual-mode repositories with feature flags |
| RLS policy misconfiguration | Medium | High | Thorough testing in staging environment |
| Performance degradation | Low | Medium | Query optimization, caching, load testing |
| Supabase service downtime | Low | High | Implement offline-first with local caching |
| Breaking changes in Supabase SDK | Low | Medium | Pin SDK versions, regular updates |

## 9. Success Criteria

1. All 30 requirements from requirements.md are implemented
2. All existing unit tests pass
3. Integration tests for all repositories pass
4. RLS policies validated for all user roles
5. Real-time subscriptions working for critical tables
6. Image upload and retrieval functional
7. Authentication flow end-to-end tested
8. Performance meets or exceeds current Dio implementation
9. Zero data loss during migration
10. Feature parity with existing system
