# Test Errors Report - GoSystem

**Date:** May 4, 2026  
**Test Command:** `flutter test`  
**Results:** +192 passed, ~22 skipped, -172 failed

---

## Executive Summary

The test suite ran with **192 passing tests** and **172 failing tests**. The majority of failures are due to common mocktail patterns and cubit behavior mismatches. This document categorizes all errors and provides solutions.

---

## Error Categories

### 1. Base Test Files - Missing `main()` Function (3 errors)

**Affected Files:**
- `test/core/base/base_cubit_test.dart`
- `test/core/base/base_integration_test.dart`
- `test/core/base/base_repository_test.dart`

**Error:**
```
Error: Undefined name 'main'.
  await Future(test.main);
```

**Solution:**
These are base classes meant to be extended, not run directly. Add placeholder `main()`:
```dart
void main() {
  // Base test class - not meant to be run directly
  test('placeholder', () => expect(true, true));
}
```

---

### 2. Missing `registerFallbackValue` for mocktail (15+ errors)

**Error Pattern:**
```
Bad state: A test tried to use `any` or `captureAny` on a parameter of type `TYPE`,
but registerFallbackValue was not previously called to register a fallback value.
```

**Affected Types:**
- `PostgresChangeEvent` (realtime_service_test.dart)
- `File` (storage_service_test.dart)
- `CouponModel` (coupon_cubit_test.dart)
- `VariationModel` (variation tests)

**Solution:**
Add to each affected test file:
```dart
setUpAll(() {
  registerFallbackValue(FakeClass());
});

// Or for enums:
class FakePostgresChangeEvent extends Fake implements PostgresChangeEvent {}

setUpAll(() {
  registerFallbackValue(FakePostgresChangeEvent());
});
```

---

### 3. `thenReturn` Used Instead of `thenAnswer` for Futures (40+ errors)

**Error:**
```
Invalid argument(s): `thenReturn` should not be used to return a Future.
Instead, use `thenAnswer((_) => future)`.
```

**Affected Files:**
- `adjustment_repository_test.dart`
- `bank_account_repository_test.dart`
- `brand_repository_test.dart`
- `cashier_repository_test.dart`
- `category_repository_test.dart`
- `city_repository_test.dart`
- `country_repository_test.dart`
- `coupon_repository_test.dart`
- `currency_repository_test.dart`
- `customer_repository_test.dart`
- `department_repository_test.dart`
- `notification_repository_test.dart`

**Solution:**
Change:
```dart
// WRONG:
when(() => mockRepo.getAll()).thenReturn(Future.value([]));

// CORRECT:
when(() => mockRepo.getAll()).thenAnswer((_) async => []);
```

---

### 4. "Cannot call `when` within a stub response" (30+ errors)

**Error:**
```
Bad state: Cannot call `when` within a stub response
```

**Affected Files:**
- `adjustment_repository_test.dart`
- `brand_repository_test.dart`
- `category_repository_test.dart`
- `city_repository_test.dart`
- `country_repository_test.dart`
- `coupon_repository_test.dart`
- `notification_repository_test.dart`
- `purchase_returns_repository_test.dart`
- `storage_service_test.dart`

**Root Cause:**
Calling `when()` inside a `thenAnswer` callback or trying to mock chained calls incorrectly.

**Solution:**
Setup all mocks in `build()` or `setUp()`, not inside callbacks:
```dart
// WRONG:
when(() => mockClient.from('table')).thenAnswer((_) {
  when(() => mockQuery.select()).thenReturn(...);  // ERROR!
  return mockQuery;
});

// CORRECT:
when(() => mockClient.from('table')).thenReturn(mockQuery);
when(() => mockQuery.select()).thenReturn(mockFilter);
```

---

### 5. Cubit State Mismatch - Expected vs Actual (30+ errors)

**Error Pattern:**
```
Expected: [Loading, Success]
Actual: [Loading, Error]
Which: at location [1] is Error which is not an instance of Success
```

**Affected Cubits:**
- `admins_cubit_test.dart` - `getAdmins`, `createAdmin`
- `cashier_cubit_test.dart` - `getCashiers`, `createCashier`
- `city_cubit_test.dart` - `getCities`, `createCity`
- `country_cubit_test.dart` - `getCountries`, `createCountry`
- `currency_cubit_test.dart` - `getCurrencies`
- `department_cubit_test.dart` - `getDepartments`
- `discount_cubit_test.dart` - `getDiscounts`

**Root Cause:**
Tests expect `Success` state but `Error` is emitted. This happens because:
1. Mock returns wrong data type
2. Cubit implementation changed
3. Test expectations don't match actual cubit flow

**Solution:**
1. **Check mock returns correct type:**
```dart
// Ensure mock returns the model the cubit expects
when(() => mockRepo.getAll()).thenAnswer((_) async => [sampleModel]);
```

2. **Check cubit behavior after create:**
```dart
// Some cubits call getAll() after create, verify mocks are set up:
when(() => mockRepo.create(any())).thenAnswer((_) async => model);
when(() => mockRepo.getAll()).thenAnswer((_) async => [model]);  // Add this!
```

3. **Update test to match actual cubit behavior:**
```dart
// If cubit doesn't auto-refresh list after create:
expect: () => [
  isA<CreateLoading>(),
  isA<CreateSuccess>(),
  // Remove GetAll states if cubit doesn't call getAll()
],
```

---

### 6. Type Cast Errors - `_Map<String, String>` vs `String?` (2 errors)

**Error:**
```
type '_Map<String, String>' is not a subtype of type 'String?' in type cast
```

**Affected Files:**
- `admins_cubit_test.dart` - `sampleAdmin` helper function

**Root Cause:**
Mock data has wrong structure for model's `fromJson`.

**Solution:**
Check model's `fromJson` and ensure mock data matches:
```dart
// If model expects:
AdminModel.fromJson({
  'name': 'John',  // String
  'role': {'id': '1', 'name': 'Admin'},  // Map
});

// Don't pass:
'name': {'first': 'John'},  // Wrong! Map instead of String
```

---

### 7. LateInitializationError - Repository Already Initialized (1 error)

**Error:**
```
LateInitializationError: Field '_dataSource' has already been initialized.
```

**Affected Files:**
- `admins_repository_test.dart`

**Root Cause:**
Repository singleton pattern conflicts with multiple test runs.

**Solution:**
Reset repository state in `tearDown` or use fresh instances.

---

### 8. Easy Localization Warnings (Warnings, not failures)

**Warning:**
```
[Easy Localization] [WARNING] Localization key [xxx] not found
```

**Affected Keys:**
- `cashier_created_success`
- `cashier_updated_success`
- `cashier_deleted_success`
- `customer_not_found`
- `customer_created_success`
- `variation_created_success`
- `currency_created_success`
- `success`

**Solution:**
These are warnings, not errors. To fix:
1. Add translations to `assets/translations/`
2. Or stub `EasyLocalization` in tests:
```dart
setUpAll(() async {
  await EasyLocalization.ensureInitialized();
});
```

---

### 9. Integration Test Plugin Warnings (Warnings)

**Warning:**
```
Warning: integration_test plugin was not detected.
```

**Solution:**
Integration tests need to run with device. These are expected warnings when running unit tests.

---

## Quick Fix Guide

### Priority 1: Fix Repository Tests

Most repository tests have the `thenReturn` vs `thenAnswer` issue. Batch fix:

```bash
# Find all thenReturn with Future
grep -r "thenReturn(Future" test/

# Replace with thenAnswer
```

### Priority 2: Add registerFallbackValue

To all cubit tests that use `any()` with models:
```dart
setUpAll(() {
  registerFallbackValue(SampleModel());
});
```

### Priority 3: Fix Cubit Flow Expectations

Check each cubit's actual implementation and match test expectations:
- Does it call `getAll()` after `create()`?
- What states does it actually emit?

---

## Test Files Status Summary

| Category | Passing | Failing | Notes |
|----------|---------|---------|-------|
| Cubit Tests | ~60 | ~30 | Mostly flow mismatches |
| Repository Tests | ~80 | ~100 | mocktail pattern issues |
| Integration Tests | ~2 | ~10 | Setup issues |
| Core/Utils | ~50 | ~5 | Mostly working |

---

## Recommended Actions

1. **Fix all repository tests** - Replace `thenReturn` with `thenAnswer` for Futures
2. **Fix cubit flow expectations** - Align tests with actual cubit behavior
3. **Add missing `registerFallbackValue`** - For all model types used with `any()`
4. **Add `main()` to base classes** - Or exclude from test run
5. **Run focused tests** - Use `flutter test test/features/admin/specific_feature` during development

---

## File Locations

- Full test results: `test_results_full.txt`
- This report: `TEST_ERRORS_REPORT.md`
- Original test guide: `TESTING.md`
