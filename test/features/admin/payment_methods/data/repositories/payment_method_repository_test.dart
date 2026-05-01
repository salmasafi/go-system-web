import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/payment_methods/data/repositories/payment_method_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}
class MockStorageFileApi extends Mock implements StorageFileApi {}

void main() {
  late PaymentMethodRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = PaymentMethodRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('PaymentMethodRepository Unit Tests', () {
    test('getPaymentMethods should return list of PaymentMethodModel', () async {
      final mockData = [
        {
          'id': 'pm-1',
          'name': 'Cash',
          'ar_name': 'نقدي',
          'type': 'cash',
          'description': 'Pay with cash',
          'icon_url': null,
          'is_active': true,
          'version': 1,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        },
        {
          'id': 'pm-2',
          'name': 'Credit Card',
          'ar_name': 'بطاقة ائتمان',
          'type': 'card',
          'description': 'Pay with credit card',
          'icon_url': 'card_icon.png',
          'is_active': true,
          'version': 1,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        },
      ];

      when(() => mockClient.from('payment_methods')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getPaymentMethods();

      expect(result.length, 2);
      expect(result[0].id, 'pm-1');
      expect(result[0].name, 'Cash');
      expect(result[0].arName, 'نقدي');
      expect(result[0].type, 'cash');
      expect(result[0].isActive, true);
      expect(result[1].name, 'Credit Card');
    });

    test('createPaymentMethod without icon should complete successfully', () async {
      when(() => mockClient.from('payment_methods')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.createPaymentMethod(
          name: 'Bank Transfer',
          arName: 'تحويل بنكي',
          description: 'Pay via bank transfer',
          type: 'bank',
          isActive: true,
        ),
        completes,
      );
    });

    test('updatePaymentMethod should complete successfully', () async {
      when(() => mockClient.from('payment_methods')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.updatePaymentMethod(
          paymentMethodId: 'pm-1',
          name: 'Cash Payment',
          arName: 'دفع نقدي',
          description: 'Updated description',
          type: 'cash',
          isActive: true,
        ),
        completes,
      );
    });

    test('deletePaymentMethod should complete successfully', () async {
      when(() => mockClient.from('payment_methods')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.deletePaymentMethod('pm-1'),
        completes,
      );
    });
  });
}
