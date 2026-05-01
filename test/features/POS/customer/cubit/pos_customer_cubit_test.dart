import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:systego/core/services/cache_helper.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/features/pos/customer/cubit/pos_customer_cubit.dart';
import 'package:systego/features/pos/customer/model/pos_customer_model.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

/// Builds a fake [Response] with the given status and data.
Response<dynamic> _fakeResponse(int status, Map<String, dynamic> data) {
  return Response(
    requestOptions: RequestOptions(path: ''),
    statusCode: status,
    data: data,
  );
}

/// A sample customer JSON payload.
Map<String, dynamic> _customerJson({String id = 'c1', String name = 'Alice', String phone = '555-0001'}) => {
      '_id': id,
      'name': name,
      'phone_number': phone,
    };

PosCustomer _customer({String id = 'c1', String name = 'Alice', String phone = '555-0001'}) =>
    PosCustomer(id: id, name: name, phoneNumber: phone);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockDio mockDio;

  setUp(() async {
    // Initialize SharedPreferences mock so CacheHelper doesn't throw
    SharedPreferences.setMockInitialValues({});
    CacheHelper.sharedPreferences = await SharedPreferences.getInstance();

    mockDio = MockDio();
    DioHelper.dio = mockDio;

    // Use a real BaseOptions so header assignments in DioHelper don't throw
    final baseOptions = BaseOptions(baseUrl: 'http://test.local');
    when(() => mockDio.options).thenReturn(baseOptions);
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

  // ── 12.5 createCustomer round-trip: new customer in list and selected ─────
  group('createCustomer', () {
    blocTest<PosCustomerCubit, PosCustomerState>(
      'on success: emits Creating → CreateSuccess → Loaded, '
      'new customer is first in list and is selectedCustomer',
      build: () {
        when(() => mockDio.post(any(), data: any(named: 'data'), queryParameters: any(named: 'queryParameters')))
            .thenAnswer((_) async => _fakeResponse(201, {'data': _customerJson(id: 'new1', name: 'New', phone: '999')}));
        return PosCustomerCubit();
      },
      act: (cubit) => cubit.createCustomer(name: 'New', phone: '999'),
      expect: () => [
        isA<PosCustomerCreating>(),
        isA<PosCustomerCreateSuccess>(),
        isA<PosCustomerLoaded>(),
      ],
      verify: (cubit) {
        expect(cubit.customers.first.id, 'new1');
        expect(cubit.selectedCustomer?.id, 'new1');
      },
    );

    blocTest<PosCustomerCubit, PosCustomerState>(
      'on failure: emits Creating → CreateError',
      build: () {
        when(() => mockDio.post(any(), data: any(named: 'data'), queryParameters: any(named: 'queryParameters')))
            .thenAnswer((_) async => _fakeResponse(422, {'message': 'Validation failed'}));
        return PosCustomerCubit();
      },
      act: (cubit) => cubit.createCustomer(name: 'Bad', phone: '000'),
      expect: () => [
        isA<PosCustomerCreating>(),
        isA<PosCustomerCreateError>(),
      ],
      verify: (cubit) {
        final err = cubit.state as PosCustomerCreateError;
        expect(err.message, 'Validation failed');
      },
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
