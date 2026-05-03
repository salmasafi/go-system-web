# Design Document

## Introduction

هذه الوثيقة تحدد التصميم التقني لمجموعة اختبارات CRUD الشاملة لجميع الكيانات في لوحة التحكم. التصميم يتبع معمارية Clean Architecture المستخدمة في المشروع ويستخدم مكتبات الاختبار القياسية في Flutter.

## System Architecture

### Test Suite Structure

```
test/
├── core/
│   ├── base/
│   │   ├── base_repository_test.dart
│   │   ├── base_cubit_test.dart
│   │   └── base_integration_test.dart
│   ├── fixtures/
│   │   ├── mock_data_generator.dart
│   │   ├── test_fixtures.dart
│   │   └── test_constants.dart
│   └── helpers/
│       ├── test_helpers.dart
│       ├── mock_helpers.dart
│       └── assertion_helpers.dart
├── features/
│   ├── admin/
│   │   ├── adjustments/
│   │   │   ├── repository/
│   │   │   │   ├── adjustment_repository_test.dart
│   │   │   │   └── adjustment_repository_mock.dart
│   │   │   ├── cubit/
│   │   │   │   ├── adjustment_cubit_test.dart
│   │   │   │   └── adjustment_state_test.dart
│   │   │   └── integration/
│   │   │       └── adjustment_integration_test.dart
│   │   ├── admins/
│   │   │   ├── repository/
│   │   │   ├── cubit/
│   │   │   └── integration/
│   │   ├── brands/
│   │   │   ├── repository/
│   │   │   ├── cubit/
│   │   │   └── integration/
│   │   └── ... (جميع الكيانات الـ 36)
├── integration/
│   ├── setup/
│   │   ├── test_database_setup.dart
│   │   ├── test_environment.dart
│   │   └── test_cleanup.dart
│   └── flows/
│       ├── crud_flow_test.dart
│       ├── authentication_flow_test.dart
│       └── error_flow_test.dart
└── utils/
    ├── test_runner.dart
    ├── coverage_generator.dart
    └── report_generator.dart
```

## Design Patterns

### 1. Base Test Classes Pattern

```dart
// base_repository_test.dart
abstract class BaseRepositoryTest<T extends BaseRepository, M extends BaseModel> {
  late T repository;
  late MockSupabaseClient mockSupabaseClient;
  
  void setUpRepositoryTest() {
    mockSupabaseClient = MockSupabaseClient();
    repository = createRepository(mockSupabaseClient);
  }
  
  T createRepository(SupabaseClient client);
  
  Future<void> testCreateSuccess();
  Future<void> testCreateValidationError();
  Future<void> testCreateNetworkError();
  
  Future<void> testGetAllSuccess();
  Future<void> testGetAllEmpty();
  Future<void> testGetAllNetworkError();
  
  Future<void> testGetByIdSuccess();
  Future<void> testGetByIdNotFound();
  
  Future<void> testUpdateSuccess();
  Future<void> testUpdateNotFound();
  
  Future<void> testDeleteSuccess();
  Future<void> testDeleteNotFound();
}
```

### 2. Cubit Test Pattern

```dart
// base_cubit_test.dart
abstract class BaseCubitTest<C extends Cubit<S>, S extends BaseState, R extends BaseRepository> {
  late C cubit;
  late Mock<R> mockRepository;
  
  void setUpCubitTest() {
    mockRepository = Mock<R>();
    cubit = createCubit(mockRepository);
  }
  
  C createCubit(R repository);
  
  void testInitialState();
  
  void testLoadSuccess();
  void testLoadEmpty();
  void testLoadError();
  
  void testCreateSuccess();
  void testCreateValidationError();
  void testCreateNetworkError();
  
  void testUpdateSuccess();
  void testUpdateError();
  
  void testDeleteSuccess();
  void testDeleteError();
}
```

### 3. Mock Data Generator Pattern

```dart
// mock_data_generator.dart
class MockDataGenerator {
  static Map<String, dynamic> generateAdjustment({
    String? id,
    String? name,
    String? description,
    double? amount,
    DateTime? date,
  }) {
    return {
      'id': id ?? 'adj_${Uuid().v4()}',
      'name': name ?? 'Adjustment ${DateTime.now().millisecondsSinceEpoch}',
      'description': description ?? 'Test adjustment description',
      'amount': amount ?? 100.0,
      'date': date ?? DateTime.now(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
  
  static Map<String, dynamic> generateBrand({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
  }) {
    return {
      'id': id ?? 'brand_${Uuid().v4()}',
      'name': name ?? 'Brand ${DateTime.now().millisecondsSinceEpoch}',
      'description': description ?? 'Test brand description',
      'logo_url': logoUrl ?? 'https://example.com/logo.png',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
  
  // ... generate methods for all 36 entities
}
```

## Technical Design

### 1. Repository Layer Testing

**Design Principles:**
- Mock SupabaseClient لتجنب الاتصال بقاعدة البيانات الحقيقية
- اختبار جميع عمليات CRUD لكل Repository
- اختبار تحويل البيانات من/إلى النماذج (Models)
- اختبار معالجة الأخطاء

**Example Implementation:**

```dart
// adjustment_repository_test.dart
class AdjustmentRepositoryTest extends BaseRepositoryTest<AdjustmentRepository, AdjustmentModel> {
  @override
  AdjustmentRepository createRepository(SupabaseClient client) {
    return AdjustmentRepository(client);
  }
  
  @override
  Future<void> testCreateSuccess() async {
    // Arrange
    final adjustmentData = MockDataGenerator.generateAdjustment();
    when(() => mockSupabaseClient.from('adjustments').insert(any())).thenAnswer(
      (_) async => [adjustmentData]
    );
    
    // Act
    final result = await repository.create(AdjustmentModel.fromJson(adjustmentData));
    
    // Assert
    expect(result.id, adjustmentData['id']);
    expect(result.name, adjustmentData['name']);
  }
}
```

### 2. Cubit Layer Testing

**Design Principles:**
- Mock Repository لتجنب الاتصال بطبقة البيانات
- اختبار جميع انتقالات الحالة (State Transitions)
- اختبار معالجة الأخطاء في Cubit
- اختبار التفاعل مع Repository

**Example Implementation:**

```dart
// adjustment_cubit_test.dart
class AdjustmentCubitTest extends BaseCubitTest<AdjustmentCubit, AdjustmentState, AdjustmentRepository> {
  @override
  AdjustmentCubit createCubit(AdjustmentRepository repository) {
    return AdjustmentCubit(repository);
  }
  
  @override
  void testLoadSuccess() {
    // Arrange
    final adjustments = List.generate(3, (i) => AdjustmentModel.fromJson(
      MockDataGenerator.generateAdjustment(name: 'Adjustment $i')
    ));
    
    when(() => mockRepository.getAll()).thenAnswer((_) async => adjustments);
    
    // Act & Assert
    blocTest<AdjustmentCubit, AdjustmentState>(
      'should emit [Loading, Loaded] when getAll succeeds',
      build: () => cubit,
      act: (cubit) => cubit.getAll(),
      expect: () => [
        AdjustmentLoading(),
        AdjustmentLoaded(adjustments),
      ],
    );
  }
}
```

### 3. Integration Testing

**Design Principles:**
- استخدام قاعدة بيانات اختبارية منفصلة
- تنظيف البيانات بعد كل اختبار
- ا��تبار التدفق الكامل من UI إلى Database
- اختبار السيناريوهات الحقيقية

**Example Implementation:**

```dart
// adjustment_integration_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  late SupabaseClient testSupabaseClient;
  late AdjustmentRepository repository;
  late AdjustmentCubit cubit;
  
  setUpAll(() async {
    // Setup test database connection
    testSupabaseClient = SupabaseClient(
      'https://test-supabase-url.supabase.co',
      'test-anon-key'
    );
    
    // Clean test data
    await testSupabaseClient.from('adjustments').delete().neq('id', '');
  });
  
  setUp(() {
    repository = AdjustmentRepository(testSupabaseClient);
    cubit = AdjustmentCubit(repository);
  });
  
  tearDown(() async {
    // Clean up after each test
    await testSupabaseClient.from('adjustments').delete().neq('id', '');
  });
  
  testWidgets('Complete CRUD flow for Adjustment', (WidgetTester tester) async {
    // Create
    final adjustment = AdjustmentModel(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Integration Test Adjustment',
      description: 'Test description',
      amount: 150.0,
      date: DateTime.now(),
    );
    
    await cubit.create(adjustment);
    await tester.pumpAndSettle();
    
    // Verify creation
    expect(cubit.state, isA<AdjustmentCreated>());
    
    // Read
    await cubit.getAll();
    await tester.pumpAndSettle();
    
    expect(cubit.state, isA<AdjustmentLoaded>());
    final loadedState = cubit.state as AdjustmentLoaded;
    expect(loadedState.adjustments, hasLength(1));
    
    // Update
    final updatedAdjustment = adjustment.copyWith(
      name: 'Updated Integration Test Adjustment',
      amount: 200.0,
    );
    
    await cubit.update(updatedAdjustment.id, updatedAdjustment);
    await tester.pumpAndSettle();
    
    expect(cubit.state, isA<AdjustmentUpdated>());
    
    // Delete
    await cubit.delete(updatedAdjustment.id);
    await tester.pumpAndSettle();
    
    expect(cubit.state, isA<AdjustmentDeleted>());
    
    // Verify deletion
    await cubit.getAll();
    await tester.pumpAndSettle();
    
    final finalState = cubit.state as AdjustmentLoaded;
    expect(finalState.adjustments, isEmpty);
  });
}
```

## Test Tools and Libraries

### Core Testing Libraries
1. **flutter_test**: للاختبارات الأساسية
2. **bloc_test**: لاختبار Cubit/Bloc
3. **mocktail**: للـ mocking (بديل أفضل من mockito)
4. **integration_test**: لاختبارات التكامل
5. **test_coverage**: لتوليد تقارير التغطية

### Mocking Strategy
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0
  mocktail: ^0.3.0
  integration_test:
    sdk: flutter
  test_coverage: ^0.5.3
```

### Test Configuration
```yaml
# test_config.yaml
test_config:
  unit_test_timeout: 120 # seconds
  integration_test_timeout: 300 # seconds
  parallel_tests: 4
  coverage_threshold: 80
  excluded_files:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - '**/*.gr.dart'
```

## Performance Optimization

### 1. Parallel Test Execution
```dart
// test_runner.dart
class ParallelTestRunner {
  static Future<void> runAllTests() async {
    final testGroups = _groupTestsByEntity();
    final tasks = testGroups.map((group) => _runTestGroup(group));
    
    await Future.wait(tasks);
  }
  
  static List<List<String>> _groupTestsByEntity() {
    // Group tests by entity to run in parallel
    return [
      ['test/features/admin/adjustments/**/*_test.dart'],
      ['test/features/admin/brands/**/*_test.dart'],
      ['test/features/admin/categories/**/*_test.dart'],
      // ... all entity groups
    ];
  }
}
```

### 2. Cached Mock Data
```dart
// test_fixtures.dart
class TestFixtures {
  static final Map<String, dynamic> _fixtureCache = {};
  
  static Map<String, dynamic> getAdjustmentFixture() {
    const key = 'adjustment_fixture';
    if (!_fixtureCache.containsKey(key)) {
      _fixtureCache[key] = MockDataGenerator.generateAdjustment();
    }
    return _fixtureCache[key]!;
  }
  
  // ... fixtures for all entities
}
```

## CI/CD Integration

### 1. GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: CRUD Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run unit tests
      run: flutter test --coverage
      
    - name: Generate coverage report
      run: |
        flutter pub global activate test_coverage
        flutter pub global run test_coverage
        lcov --list coverage/lcov.info
        
    - name: Run integration tests
      run: |
        flutter test integration_test/
        timeout: 10m
        
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

### 2. Test Reports
```dart
// report_generator.dart
class TestReportGenerator {
  static Future<void> generateHtmlReport() async {
    final report = '''
    <html>
      <head>
        <title>CRUD Test Suite Report</title>
        <style>
          .passed { color: green; }
          .failed { color: red; }
          .skipped { color: orange; }
        </style>
      </head>
      <body>
        <h1>CRUD Test Suite Report</h1>
        <p>Generated: ${DateTime.now()}</p>
        
        <h2>Summary</h2>
        <table border="1">
          <tr>
            <th>Entity</th>
            <th>Total Tests</th>
            <th>Passed</th>
            <th>Failed</th>
            <th>Skipped</th>
            <th>Coverage</th>
          </tr>
          <!-- Dynamic rows for each entity -->
        </table>
      </body>
    </html>
    ''';
    
    await File('test_reports/report.html').writeAsString(report);
  }
}
```

## Error Handling Design

### 1. Test-Specific Error Types
```dart
// test_errors.dart
abstract class TestError {
  final String message;
  final StackTrace stackTrace;
  
  TestError(this.message, this.stackTrace);
}

class RepositoryTestError extends TestError {
  RepositoryTestError(String message, StackTrace stackTrace) 
    : super(message, stackTrace);
}

class CubitTestError extends TestError {
  CubitTestError(String message, StackTrace stackTrace) 
    : super(message, stackTrace);
}

class IntegrationTestError extends TestError {
  IntegrationTestError(String message, StackTrace stackTrace) 
    : super(message, stackTrace);
}
```

### 2. Error Recovery in Tests
```dart
// test_recovery.dart
class TestRecovery {
  static Future<void> withRetry(
    Future<void> Function() testFunction,
    int maxRetries = 3,
  ) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        await testFunction();
        return;
      } catch (e, s) {
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }
  
  static Future<void> cleanupOnFailure(
    Future<void> Function() testFunction,
    Future<void> Function() cleanupFunction,
  ) async {
    try {
      await testFunction();
    } catch (e) {
      await cleanupFunction();
      rethrow;
    }
  }
}
```

## Maintenance and Extensibility

### 1. Test Template Generator
```dart
// test_template_generator.dart
class TestTemplateGenerator {
  static Future<void> generateEntityTests(String entityName) async {
    final repositoryTest = '''
// ${entityName}_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_app/features/admin/$entityName/data/repositories/${entityName}_repository.dart';
import 'package:your_app/features/admin/$entityName/model/${entityName}_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late ${entityName.capitalize()}Repository repository;
  late MockSupabaseClient mockSupabaseClient;
  
  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    repository = ${entityName.capitalize()}Repository(mockSupabaseClient);
  });
  
  group('${entityName.capitalize()}Repository Tests', () {
    test('should create ${entityName} successfully', () async {
      // TODO: Implement test
    });
    
    test('should get all ${entityName}s successfully', () async {
      // TODO: Implement test
    });
    
    // ... more tests
  });
}
''';
    
    await File('test/features/admin/$entityName/repository/${entityName}_repository_test.dart')
      .writeAsString(repositoryTest);
  }
}
```

### 2. Configuration Management
```dart
// test_config_manager.dart
class TestConfigManager {
  static final Map<String, dynamic> _config = {
    'test_timeout': Duration(minutes: 2),
    'integration_timeout': Duration(minutes: 5),
    'coverage_threshold': 80,
    'entities_to_test': [
      'adjustments',
      'admins',
      'brands',
      // ... all 36 entities
    ],
    'skip_integration': false,
    'generate_reports': true,
  };
  
  static Duration get testTimeout => _config['test_timeout'];
  static Duration get integrationTimeout => _config['integration_timeout'];
  static int get coverageThreshold => _config['coverage_threshold'];
  static List<String> get entitiesToTest => _config['entities_to_test'];
  
  static void updateConfig(String key, dynamic value) {
    _config[key] = value;
  }
}
```

## Success Criteria Validation

### 1. Coverage Validation
```dart
// coverage_validator.dart
class CoverageValidator {
  static bool validateCoverage(double coverage, int threshold) {
    return coverage >= threshold;
  }
  
  static Map<String, double> calculateEntityCoverage() {
    final coverageByEntity = <String, double>{};
    
    for (final entity in TestConfigManager.entitiesToTest) {
      // Calculate coverage for each entity
      final entityCoverage = _calculateEntityCoverage(entity);
      coverageByEntity[entity] = entityCoverage;
    }
    
    return coverageByEntity;
  }
  
  static double _calculateEntityCoverage(String entity) {
    // Implementation to calculate coverage for specific entity
    return 85.0; // Example value
  }
}
```

### 2. Performance Validation
```dart
// performance_validator.dart
class PerformanceValidator {
  static bool validateUnitTestPerformance(Duration duration) {
    return duration.inSeconds <= 120; // 2 minutes
  }
  
  static bool validateIntegrationTestPerformance(Duration duration) {
    return duration.inSeconds <= 300; // 5 minutes
  }
  
  static Future<Duration> measureTestExecution(
    Future<void> Function() testSuite,
  ) async {
    final stopwatch = Stopwatch()..start();
    await testSuite();
    stopwatch.stop();
    return stopwatch.elapsed;
  }
}
```

## Conclusion

هذا التصميم يوفر إطار عمل شامل لاختبارات CRUD لجميع الكيانات في لوحة التحكم. التصميم قابل للتوسع والصيانة، ويضمن تغطية اختبارية لا تقل عن 80% مع أداء عالي. يمكن تكييف التصميم حسب احتياجات المشروع المحددة.