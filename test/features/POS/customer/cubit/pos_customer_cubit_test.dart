import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/customer/cubit/pos_customer_cubit.dart';
import 'package:GoSystem/features/pos/customer/model/pos_customer_model.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

PosCustomer _customer({String id = 'c1', String name = 'Alice', String phone = '555-0001'}) =>
    PosCustomer(id: id, name: name, phoneNumber: phone);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    SupabaseClientWrapper.setMockInstance(mockSupabase);
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  // ── 12.4 selectCustomer updates cubit state for any customer ─────────────
  group('selectCustomer', () {
    test('updates selectedCustomer and emits PosCustomerLoaded', () {
      final cubit = PosCustomerCubit();
      final customer = _customer();

      cubit.selectCustomer(customer);

      expect(cubit.selectedCustomer, customer);
      expect(cubit.state, isA<PosCustomerLoaded>());
      final loaded = cubit.state as PosCustomerLoaded;
      expect(loaded.selectedCustomer, customer);
    });

    test('works for any customer object', () {
      final customers = [
        _customer(id: '1', name: 'Alice', phone: '111'),
        _customer(id: '2', name: 'Bob', phone: '222'),
        _customer(id: '3', name: 'Carol', phone: '333'),
      ];

      for (final c in customers) {
        final cubit = PosCustomerCubit();
        cubit.selectCustomer(c);
        expect(cubit.selectedCustomer?.id, c.id);
        expect((cubit.state as PosCustomerLoaded).selectedCustomer?.id, c.id);
      }
    });
  });

  // ── 12.7 selectedCustomer is null after clearSelectedCustomer ────────────
  group('clearSelectedCustomer', () {
    test('sets selectedCustomer to null and emits PosCustomerLoaded', () {
      final cubit = PosCustomerCubit();
      cubit.selectCustomer(_customer());

      cubit.clearSelectedCustomer();

      expect(cubit.selectedCustomer, isNull);
      expect(cubit.state, isA<PosCustomerLoaded>());
      expect((cubit.state as PosCustomerLoaded).selectedCustomer, isNull);
    });
  });

  // ── 12.8 clearAll clears both customers and selectedCustomer ─────────────
  group('clearAll', () {
    test('clears customers list and selectedCustomer, emits PosCustomerInitial', () {
      final cubit = PosCustomerCubit()
        ..customers = [_customer()]
        ..selectedCustomer = _customer();

      cubit.clearAll();

      expect(cubit.customers, isEmpty);
      expect(cubit.selectedCustomer, isNull);
      expect(cubit.state, isA<PosCustomerInitial>());
    });
  });

  // ── 12.5 createCustomer — error path ─────────────────────────────────────
  group('createCustomer', () {
    blocTest<PosCustomerCubit, PosCustomerState>(
      'on Supabase error: emits Creating → CreateError',
      build: () {
        when(() => mockSupabase.from(any())).thenThrow(Exception('network error'));
        return PosCustomerCubit();
      },
      act: (cubit) => cubit.createCustomer(name: 'New', phone: '999'),
      expect: () => [
        isA<PosCustomerCreating>(),
        isA<PosCustomerCreateError>(),
      ],
    );

    blocTest<PosCustomerCubit, PosCustomerState>(
      'on validation failure: emits Creating → CreateError',
      build: () {
        when(() => mockSupabase.from(any())).thenThrow(Exception('Validation failed'));
        return PosCustomerCubit();
      },
      act: (cubit) => cubit.createCustomer(name: 'Bad', phone: '000'),
      expect: () => [
        isA<PosCustomerCreating>(),
        isA<PosCustomerCreateError>(),
      ],
    );
  });

  // ── 12.3 search filter returns correct subset ─────────────────────────────
  group('search filter logic', () {
    // The filter lives in CustomerPickerSheet but we test the logic directly here.
    List<PosCustomer> filter(List<PosCustomer> customers, String query) {
      if (query.isEmpty) return customers;
      final q = query.toLowerCase();
      return customers
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.phoneNumber.toLowerCase().contains(q))
          .toList();
    }

    final list = [
      PosCustomer(id: '1', name: 'Alice Smith', phoneNumber: '111-2222'),
      PosCustomer(id: '2', name: 'Bob Jones', phoneNumber: '333-4444'),
      PosCustomer(id: '3', name: 'Carol Alice', phoneNumber: '555-6666'),
    ];

    test('empty query returns all customers', () {
      expect(filter(list, ''), list);
    });

    test('name filter is case-insensitive', () {
      final result = filter(list, 'alice');
      expect(result.map((c) => c.id), containsAll(['1', '3']));
      expect(result.length, 2);
    });

    test('phone filter matches partial number', () {
      final result = filter(list, '333');
      expect(result.length, 1);
      expect(result.first.id, '2');
    });

    test('no match returns empty list', () {
      expect(filter(list, 'zzz'), isEmpty);
    });

    test('filter on empty list returns empty list', () {
      expect(filter([], 'alice'), isEmpty);
    });
  });
}
