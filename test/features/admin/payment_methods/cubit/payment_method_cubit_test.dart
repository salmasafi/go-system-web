import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/payment_methods/cubit/payment_method_cubit.dart';
import 'package:GoSystem/features/admin/payment_methods/cubit/payment_method_state.dart';
import 'package:GoSystem/features/admin/payment_methods/data/repositories/payment_method_repository.dart';
import 'package:GoSystem/features/admin/payment_methods/model/payment_method_model.dart';

class MockPaymentMethodRepository extends Mock implements PaymentMethodRepository {}

void main() {
  late MockPaymentMethodRepository mockRepo;

  setUp(() {
    mockRepo = MockPaymentMethodRepository();
  });

  PaymentMethodModel samplePaymentMethod(String id) => PaymentMethodModel.fromJson({
        'id': id,
        'name': 'Method $id',
        'ar_name': 'طريقة $id',
        'description': 'Description',
        'type': 'cash',
        'icon': 'icon.png',
        'is_active': true,
        'created_at': '2024-01-01',
      });

  group('PaymentMethodCubit', () {
    blocTest<PaymentMethodCubit, PaymentMethodState>(
      'getPaymentMethods emits loading then success',
      build: () {
        when(() => mockRepo.getPaymentMethods()).thenAnswer((_) async => [samplePaymentMethod('m1')]);
        return PaymentMethodCubit(mockRepo);
      },
      act: (c) => c.getPaymentMethods(),
      expect: () => [
        isA<GetPaymentMethodsLoading>(),
        isA<GetPaymentMethodsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getPaymentMethods()).called(1);
      },
    );

    blocTest<PaymentMethodCubit, PaymentMethodState>(
      'getPaymentMethods emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getPaymentMethods()).thenThrow(Exception('network'));
        return PaymentMethodCubit(mockRepo);
      },
      act: (c) => c.getPaymentMethods(),
      expect: () => [
        isA<GetPaymentMethodsLoading>(),
        isA<GetPaymentMethodsError>(),
      ],
    );

    blocTest<PaymentMethodCubit, PaymentMethodState>(
      'createPaymentMethod emits loading then success',
      build: () {
        when(() => mockRepo.createPaymentMethod(
          name: any(named: 'name'),
          arName: any(named: 'arName'),
          description: any(named: 'description'),
          type: any(named: 'type'),
          isActive: any(named: 'isActive'),
          iconPath: any(named: 'iconPath'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getPaymentMethods()).thenAnswer((_) async => [samplePaymentMethod('m1')]);
        return PaymentMethodCubit(mockRepo);
      },
      act: (c) => c.createPaymentMethod(
        name: 'New Method',
        arName: 'طريقة جديدة',
        icon: null,
        description: 'Description',
        type: 'cash',
        isActive: true,
      ),
      expect: () => [
        isA<CreatePaymentMethodLoading>(),
        isA<CreatePaymentMethodSuccess>(),
        isA<GetPaymentMethodsLoading>(),
        isA<GetPaymentMethodsSuccess>(),
      ],
    );
  });
}
