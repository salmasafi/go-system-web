// Feature: pos-return-sale
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:systego/core/services/cache_helper.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/features/pos/return/cubit/return_cubit.dart';
import 'package:systego/features/pos/return/models/return_item_model.dart';
import 'package:systego/features/pos/return/models/return_sale_model.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

Response<dynamic> _fakeResponse(int status, Map<String, dynamic> data) =>
    Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: status,
      data: data,
    );

// ── Fixtures ──────────────────────────────────────────────────────────────────

ReturnItemModel _item({
  String id = 'i1',
  int quantity = 5,
  int alreadyReturned = 0,
  int availableToReturn = 5,
  int returnQuantity = 0,
}) =>
    ReturnItemModel(
      id: id,
      saleId: 'sale1',
      productName: 'Product',
      productCode: 'P001',
      productPriceId: 'pp1',
      quantity: quantity,
      alreadyReturned: alreadyReturned,
      availableToReturn: availableToReturn,
      returnQuantity: returnQuantity,
    );

ReturnSaleModel _sale({List<ReturnItemModel>? items}) => ReturnSaleModel(
      id: 'sale1',
      reference: 'REF-001',
      date: '2024-01-01',
      warehouseName: 'WH1',
      cashierEmail: 'c@test.com',
      cashierName: 'John',
      cashierManName: 'Manager',
      items: items ?? [_item()],
    );

Map<String, dynamic> _saleApiResponse({List<dynamic>? items}) => {
      'data': {
        'sale': {
          '_id': 'sale1',
          'reference': 'REF-001',
          'date': '2024-01-01',
          'warehouse': {'name': 'WH1'},
          'created_by': {'email': 'c@test.com'},
          'shift': {
            'cashier': {'name': 'John'},
            'cashierman': {'username': 'Manager'},
          },
        },
        'items': items ??
            [
              {
                '_id': 'i1',
                'sale_id': 'sale1',
                'product': {'_id': 'p1', 'name': 'Product', 'code': 'P001'},
                'product_price': {'_id': 'pp1'},
                'quantity': 5,
                'already_returned': 0,
                'available_to_return': 5,
              }
            ],
      }
    };

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockDio mockDio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CacheHelper.sharedPreferences = await SharedPreferences.getInstance();

    mockDio = MockDio();
    DioHelper.dio = mockDio;

    final baseOptions = BaseOptions(baseUrl: 'http://test.local');
    when(() => mockDio.options).thenReturn(baseOptions);
  });

  // ── Property 1: Empty/Whitespace Reference Rejected ───────────────────────
  // Feature: pos-return-sale, Property 1: Empty/Whitespace Reference Rejected
  group('[PBT] Property 1: empty or whitespace reference does not emit ReturnSearchLoading', () {
    final emptyInputs = ['', ' ', '   ', '\t', '\n', '  \t  '];

    for (final input in emptyInputs) {
      blocTest<ReturnCubit, ReturnState>(
        'input: "${input.replaceAll('\t', '\\t').replaceAll('\n', '\\n')}" → no state emitted',
        build: () => ReturnCubit(),
        act: (cubit) => cubit.searchSale(input),
        expect: () => <ReturnState>[],
      );
    }
  });

  // ── Property 2: Valid Reference Triggers Search ───────────────────────────
  // Feature: pos-return-sale, Property 2: Valid Reference Triggers Search
  group('[PBT] Property 2: any non-empty reference emits ReturnSearchLoading first', () {
    final validRefs = ['REF-001', 'abc', '123', 'A B C', 'ref with spaces'];

    for (final ref in validRefs) {
      blocTest<ReturnCubit, ReturnState>(
        'ref "$ref" → first emitted state is ReturnSearchLoading',
        build: () {
          when(() => mockDio.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => _fakeResponse(200, _saleApiResponse()));
          return ReturnCubit();
        },
        act: (cubit) => cubit.searchSale(ref),
        expect: () => [
          isA<ReturnSearchLoading>(),
          isA<ReturnSaleLoaded>(),
        ],
      );
    }
  });

  // ── Property 5: Return Quantity Invariant ─────────────────────────────────
  // Feature: pos-return-sale, Property 5: Return Quantity Invariant
  group('[PBT] Property 5: returnQuantity always stays in [0, availableToReturn]', () {
    test('clamps to 0 when quantity is negative', () {
      final cubit = ReturnCubit();
      final sale = _sale(items: [_item(availableToReturn: 5)]);
      cubit.emit(ReturnSaleLoaded(sale: sale, items: sale.items));

      cubit.updateReturnQuantity(0, -10);

      final state = cubit.state as ReturnSaleLoaded;
      expect(state.items[0].returnQuantity, 0);
    });

    test('clamps to availableToReturn when quantity exceeds max', () {
      final cubit = ReturnCubit();
      final sale = _sale(items: [_item(availableToReturn: 3)]);
      cubit.emit(ReturnSaleLoaded(sale: sale, items: sale.items));

      cubit.updateReturnQuantity(0, 100);

      final state = cubit.state as ReturnSaleLoaded;
      expect(state.items[0].returnQuantity, 3);
    });

    test('sequence of increments/decrements stays in bounds', () {
      final availableToReturn = 4;
      final cubit = ReturnCubit();
      final sale = _sale(items: [_item(availableToReturn: availableToReturn)]);
      cubit.emit(ReturnSaleLoaded(sale: sale, items: sale.items));

      final operations = [5, -3, 10, 0, -1, 2, 99, -99];
      for (final op in operations) {
        cubit.updateReturnQuantity(0, op);
        final state = cubit.state as ReturnSaleLoaded;
        final qty = state.items[0].returnQuantity;
        expect(qty, greaterThanOrEqualTo(0));
        expect(qty, lessThanOrEqualTo(availableToReturn));
      }
    });

    test('valid quantity within range is set exactly', () {
      final cubit = ReturnCubit();
      final sale = _sale(items: [_item(availableToReturn: 5)]);
      cubit.emit(ReturnSaleLoaded(sale: sale, items: sale.items));

      cubit.updateReturnQuantity(0, 3);

      final state = cubit.state as ReturnSaleLoaded;
      expect(state.items[0].returnQuantity, 3);
    });
  });

  // ── Property 6: All-Zero Quantities Rejected ──────────────────────────────
  // Feature: pos-return-sale, Property 6: All-Zero Quantities Rejected
  group('[PBT] Property 6: submitReturn does not emit ReturnSubmitting when all quantities are 0', () {
    final itemCounts = [1, 2, 5];

    for (final count in itemCounts) {
      test('$count items all with returnQuantity=0 → no state emitted', () async {
        final cubit = ReturnCubit();
        final items = List.generate(count, (i) => _item(id: 'i$i', returnQuantity: 0));
        final sale = _sale(items: items);
        cubit.emit(ReturnSaleLoaded(sale: sale, items: items));

        final emittedStates = <ReturnState>[];
        final sub = cubit.stream.listen(emittedStates.add);

        await cubit.submitReturn(refundAccountId: 'acc1', note: '');
        await sub.cancel();

        expect(emittedStates, isEmpty);
      });
    }
  });

  // ── Property 7: Request Body Contains Only Non-Zero Items ─────────────────
  // Feature: pos-return-sale, Property 7: Request Body Contains Only Non-Zero Items
  group('[PBT] Property 7: request body contains only items with returnQuantity > 0', () {
    test('only non-zero items are included in POST body', () async {
      Map<String, dynamic>? capturedBody;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[const Symbol('data')] as Map<String, dynamic>?;
        return _fakeResponse(201, {'message': 'success'});
      });

      final cubit = ReturnCubit();
      final items = [
        _item(id: 'i1', returnQuantity: 2),
        _item(id: 'i2', returnQuantity: 0),
        _item(id: 'i3', returnQuantity: 3),
      ];
      final sale = _sale(items: items);
      cubit.emit(ReturnSaleLoaded(sale: sale, items: items));

      await cubit.submitReturn(refundAccountId: 'acc1', note: 'test note');

      expect(capturedBody, isNotNull);
      final bodyItems = capturedBody!['items'] as List;
      expect(bodyItems, hasLength(2)); // only i1 and i3

      for (final bodyItem in bodyItems) {
        expect(bodyItem['quantity'], greaterThan(0));
        expect(bodyItem.containsKey('product_price_id'), isTrue);
        expect(bodyItem.containsKey('quantity'), isTrue);
      }
    });

    test('all non-zero items have correct product_price_id and quantity fields', () async {
      Map<String, dynamic>? capturedBody;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[const Symbol('data')] as Map<String, dynamic>?;
        return _fakeResponse(201, {'message': 'success'});
      });

      final cubit = ReturnCubit();
      final item = ReturnItemModel(
        id: 'i1',
        saleId: 'sale1',
        productName: 'P',
        productCode: 'C',
        productPriceId: 'pp_specific',
        quantity: 5,
        alreadyReturned: 0,
        availableToReturn: 5,
        returnQuantity: 4,
      );
      final sale = _sale(items: [item]);
      cubit.emit(ReturnSaleLoaded(sale: sale, items: [item]));

      await cubit.submitReturn(refundAccountId: 'acc1', note: '');

      final bodyItems = capturedBody!['items'] as List;
      expect(bodyItems.first['product_price_id'], 'pp_specific');
      expect(bodyItems.first['quantity'], 4);
    });
  });

  // ── Property 10: searchSale success emits ReturnSaleLoaded ───────────────
  group('searchSale', () {
    blocTest<ReturnCubit, ReturnState>(
      'on 200 response emits Loading then SaleLoaded',
      build: () {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => _fakeResponse(200, _saleApiResponse()));
        return ReturnCubit();
      },
      act: (cubit) => cubit.searchSale('REF-001'),
      expect: () => [isA<ReturnSearchLoading>(), isA<ReturnSaleLoaded>()],
    );

    blocTest<ReturnCubit, ReturnState>(
      'on non-200 response emits Loading then SearchError',
      build: () {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => _fakeResponse(404, {'message': 'Not found'}));
        return ReturnCubit();
      },
      act: (cubit) => cubit.searchSale('INVALID'),
      expect: () => [isA<ReturnSearchLoading>(), isA<ReturnSearchError>()],
    );
  });

  // ── Property 11: Reset Clears State ──────────────────────────────────────
  // Feature: pos-return-sale, Property 11: Reset Clears State
  group('[PBT] Property 11: reset() always results in ReturnInitial', () {
    final stateFactories = <String, ReturnState Function()>{
      'ReturnInitial': () => ReturnInitial(),
      'ReturnSearchLoading': () => ReturnSearchLoading(),
      'ReturnSaleLoaded': () => ReturnSaleLoaded(sale: _sale(), items: [_item()]),
      'ReturnSearchError': () => ReturnSearchError('error'),
      'ReturnSubmitting': () => ReturnSubmitting(sale: _sale(), items: [_item()]),
      'ReturnSubmitSuccess': () => ReturnSubmitSuccess(),
      'ReturnSubmitError': () => ReturnSubmitError(sale: _sale(), items: [_item()], message: 'err'),
    };

    stateFactories.forEach((name, stateFactory) {
      test('from $name → reset() → ReturnInitial', () {
        final cubit = ReturnCubit();
        cubit.emit(stateFactory());

        cubit.reset();

        expect(cubit.state, isA<ReturnInitial>());
      });
    });
  });
}
