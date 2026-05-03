import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/suppliers/data/repositories/supplier_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late SupplierRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUpAll(() {
    // Register fallback for the 'then' callback
    registerFallbackValue((List<Map<String, dynamic>> _) => []);
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = SupplierRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('SupplierRepository Supabase Implementation Tests', () {
    test('getAllSuppliers maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'sup-123',
          'username': 'Main Supplier',
          'phone_number': '12345',
          'email': 'sup@example.com',
          'address': 'Street 1',
          'is_active': true,
        },
      ];

      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenAnswer((_) => mockFilterBuilder);

      // Mock the Thenable behavior of the builder
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        return Future.value(callback(mockData));
      });

      final result = await repository.getAllSuppliers();

      expect(result.first.id, 'sup-123');
      expect(result.first.username, 'Main Supplier');
    });
  });
}
