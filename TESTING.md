# GoSystem Testing Guide

## Overview

This document provides comprehensive guidance for testing the GoSystem Flutter application. The test suite includes unit tests, widget tests, integration tests, and CRUD tests for all 36 dashboard entities.

## Test Structure

```
test/
├── core/
│   ├── base/                     # Base test classes
│   │   ├── base_repository_test.dart
│   │   ├── base_cubit_test.dart
│   │   └── base_integration_test.dart
│   ├── fixtures/                 # Mock data generators
│   │   └── mock_data_generator.dart
│   └── helpers/                # Test utilities
│       ├── test_helpers.dart
│       ├── mock_helpers.dart
│       └── assertion_helpers.dart
├── features/
│   └── admin/                  # Entity-specific tests
│       ├── adjustment/
│       ├── brands/
│       ├── cashier/
│       ├── categories/
│       ├── city/
│       ├── country/
│       ├── coupon/
│       ├── currency/
│       ├── customer/
│       ├── department/
│       ├── discount/
│       ├── expences_category/
│       ├── expense_admin/
│       ├── payment_methods/
│       ├── permission/
│       ├── points/
│       ├── popup/
│       ├── print_labels/
│       ├── product/
│       ├── purchase/
│       ├── purchase_returns/
│       ├── reason/
│       ├── redeem_points/
│       ├── revenue/
│       ├── roloes_and_permissions/
│       ├── suppliers/
│       ├── taxes/
│       ├── transfer/
│       ├── units/
│       ├── variations/
│       ├── warehouses/
│       └── zone/
└── integration/                # Integration tests
    ├── setup/
    │   ├── test_database_setup.dart
    │   ├── test_cleanup.dart
    │   └── test_environment.dart
    ├── adjustment_integration_test.dart
    ├── authentication_integration_test.dart
    ├── auth_flow_test.dart
    ├── customer_integration_test.dart
    ├── dashboard_integration_test.dart
    ├── dashboard_smoke_test.dart
    ├── product_integration_test.dart
    ├── purchase_integration_test.dart
    └── warehouse_integration_test.dart
```

## Running Tests

### Unit and Widget Tests

```bash
# Run all unit and widget tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/admin/product/cubit/product_cubit_test.dart

# Run tests matching a pattern
flutter test --name "create"
```

### Integration Tests

```bash
# Run integration tests (requires device)
flutter test integration_test/

# Run specific integration test
flutter test integration_test/product_integration_test.dart -d <device_id>

# Run with environment variables
flutter test integration_test/ \
  --dart-define=RUN_INTEGRATION_TESTS=true \
  --dart-define=SUPABASE_TEST_URL=https://your-test-url.supabase.co \
  --dart-define=SUPABASE_TEST_ANON_KEY=your-anon-key
```

### Running All Tests

```bash
# Analyze code
flutter analyze

# Run unit tests with coverage
flutter test --coverage

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## Adding New Tests

### 1. Repository Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockYourRepository extends Mock implements YourRepository {}

void main() {
  late MockYourRepository mockRepo;

  setUp(() {
    mockRepo = MockYourRepository();
  });

  group('YourRepository', () {
    test('getAll returns list of entities', () async {
      // Arrange
      final expectedData = [YourModel.fromJson({'id': '1', 'name': 'Test'})];
      when(() => mockRepo.getAll()).thenAnswer((_) async => expectedData);

      // Act
      final result = await mockRepo.getAll();

      // Assert
      expect(result, equals(expectedData));
      verify(() => mockRepo.getAll()).called(1);
    });

    test('create adds new entity', () async {
      // Test create operation
    });

    test('update modifies existing entity', () async {
      // Test update operation
    });

    test('delete removes entity', () async {
      // Test delete operation
    });
  });
}
```

### 2. Cubit Tests

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/your_feature/cubit/your_cubit.dart';
import 'package:GoSystem/features/admin/your_feature/data/repositories/your_repository.dart';

class MockYourRepository extends Mock implements YourRepository {}

void main() {
  late MockYourRepository mockRepo;

  setUp(() {
    mockRepo = MockYourRepository();
  });

  group('YourCubit', () {
    blocTest<YourCubit, YourState>(
      'getAll emits loading then success',
      build: () {
        when(() => mockRepo.getAll()).thenAnswer((_) async => []);
        return YourCubit(mockRepo);
      },
      act: (c) => c.getAll(),
      expect: () => [
        isA<GetAllLoading>(),
        isA<GetAllSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAll()).called(1);
      },
    );

    blocTest<YourCubit, YourState>(
      'getAll emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAll()).thenThrow(Exception('network'));
        return YourCubit(mockRepo);
      },
      act: (c) => c.getAll(),
      expect: () => [
        isA<GetAllLoading>(),
        isA<GetAllError>(),
      ],
    );
  });
}
```

### 3. Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:GoSystem/main.dart' as app;

import 'setup/test_environment.dart';
import 'setup/test_database_setup.dart';
import 'setup/test_cleanup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Your Feature Integration Tests', () {
    setUpAll(() async {
      await TestDatabaseSetup.initialize();
    });

    tearDownAll(() async {
      await TestDatabaseSetup.dispose();
    });

    setUp(() async {
      if (TestEnvironment.runIntegrationTests) {
        await cleanupTestData('your_table');
      }
    });

    testWidgets('Complete workflow', (tester) async {
      if (!TestEnvironment.runIntegrationTests) {
        return;
      }

      app.main();
      await tester.pumpAndSettle();

      // Navigate to feature
      // Perform actions
      // Verify results

      expect(true, true);
    }, skip: !TestEnvironment.runIntegrationTests);
  });
}
```

## Mock Data Generator

Use the `MockDataGenerator` class to generate test data:

```dart
import '../core/fixtures/mock_data_generator.dart';

// Generate valid data
final brand = MockDataGenerator.generateBrand(id: 'b1');
final product = MockDataGenerator.generateProduct(id: 'p1');

// Generate invalid data for error testing
final invalidProduct = MockDataGenerator.generateInvalidProduct();

// Generate edge case data
final emptyFields = MockDataGenerator.emptyStringFields(product);
final nullFields = MockDataGenerator.nullOptionalFields(product);
```

## Test Environment Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `RUN_INTEGRATION_TESTS` | Enable integration tests | `false` |
| `SUPABASE_TEST_URL` | Supabase test instance URL | `''` |
| `SUPABASE_TEST_ANON_KEY` | Supabase test anon key | `''` |

### Using dart-define

```bash
flutter test \
  --dart-define=RUN_INTEGRATION_TESTS=true \
  --dart-define=SUPABASE_TEST_URL=https://test.supabase.co \
  --dart-define=SUPABASE_TEST_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
```

## Coverage Reports

### Generate HTML Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# On macOS
open coverage/html/index.html

# On Linux
xdg-open coverage/html/index.html

# On Windows
start coverage/html/index.html
```

### Coverage Thresholds

- Repository tests: 100% of CRUD operations
- Cubit tests: 100% of state transitions
- Overall: Minimum 80% code coverage

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/test.yml`) runs:

1. Code analysis (`flutter analyze`)
2. Unit & widget tests with coverage (`flutter test --coverage`)
3. Integration smoke tests (`flutter test integration_test/... -d flutter-tester`)

### Pipeline Status

Check the latest test results in the GitHub Actions tab.

## Troubleshooting

### Common Issues

1. **Test timeouts**: Increase timeout in `test_helpers.dart`
2. **Mock errors**: Ensure all dependencies are mocked
3. **Integration test failures**: Check environment variables
4. **Coverage not generating**: Ensure `coverage` package is installed

### Debug Tips

```dart
// Add debug prints
print('Debug: $value');

// Use debugDumpApp for widget tree
debugDumpApp();

// Take screenshot during test
await binding.takeScreenshot('screenshot_name');
```

## Best Practices

1. **Test Independence**: Each test should be independent
2. **Descriptive Names**: Use clear, descriptive test names
3. **Arrange-Act-Assert**: Structure tests clearly
4. **Mock External Dependencies**: Don't call real APIs in tests
5. **Clean Up**: Always clean up test data
6. **Use bloc_test**: For cubit/bloc testing
7. **Group Related Tests**: Use `group()` for organization

## Entity Coverage

All 36 dashboard entities have tests:

- Adjustments ✅
- Admins ✅
- Bank Accounts ✅
- Brands ✅
- Cashiers ✅
- Categories ✅
- Cities ✅
- Countries ✅
- Coupons ✅
- Currencies ✅
- Customers ✅
- Departments ✅
- Discounts ✅
- Expense Categories ✅
- Expenses ✅
- Financial Transactions ✅
- Notifications ✅
- Pandel (Bundles) ✅
- Payment Methods ✅
- Permissions ✅
- Points ✅
- Popups ✅
- Print Labels ✅
- Products ✅
- Purchases ✅
- Purchase Returns ✅
- Reasons ✅
- Redeem Points ✅
- Revenue ✅
- Roles ✅
- Suppliers ✅
- Taxes ✅
- Transfers ✅
- Units ✅
- Variations ✅
- Warehouses ✅
- Zones ✅

## Contributing

When adding new features:

1. Add corresponding repository tests
2. Add corresponding cubit tests
3. Add corresponding integration tests (if applicable)
4. Update this documentation
5. Ensure all tests pass before submitting PR

## Support

For test-related questions or issues, refer to:
- This guide
- Code comments in test files
- Flutter testing documentation: https://docs.flutter.dev/testing
