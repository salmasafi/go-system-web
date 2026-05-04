import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/customer/cubit/customer_cubit.dart';
import 'package:GoSystem/features/admin/customer/data/repositories/customer_repository.dart';
import 'package:GoSystem/features/admin/customer/model/customer_model.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late MockCustomerRepository mockRepo;

  setUp(() {
    mockRepo = MockCustomerRepository();
  });

  CustomerModel sampleCustomer(String id) => CustomerModel.fromJson({
        'id': id,
        'name': 'Customer $id',
        'email': 'customer$id@test.com',
        'phone_number': '1234567890',
        'address': 'Test Address',
        'country_id': {'id': 'c1', 'name': 'Country'},
        'city_id': {'id': 'c2', 'name': 'City'},
        'customer_group_id': {'id': 'g1', 'name': 'Group'},
        'isDue': false,
        'amount_due': 0.0,
        'total_points_earned': 0,
        'created_at': '2024-01-01',
      });

  group('CustomerCubit', () {
    blocTest<CustomerCubit, CustomerState>(
      'getAllCustomers emits loading then success',
      build: () {
        when(() => mockRepo.getAllCustomers()).thenAnswer((_) async => [sampleCustomer('c1')]);
        return CustomerCubit(mockRepo);
      },
      act: (c) => c.getAllCustomers(),
      expect: () => [
        isA<GetCustomersLoading>(),
        isA<GetCustomersSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllCustomers()).called(1);
      },
    );

    blocTest<CustomerCubit, CustomerState>(
      'getAllCustomers emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllCustomers()).thenThrow(Exception('network'));
        return CustomerCubit(mockRepo);
      },
      act: (c) => c.getAllCustomers(),
      expect: () => [
        isA<GetCustomersLoading>(),
        isA<GetCustomersError>(),
      ],
    );

    blocTest<CustomerCubit, CustomerState>(
      'getCustomerById emits success when customer exists',
      build: () {
        final customer = sampleCustomer('c1');
        when(() => mockRepo.getCustomerById('c1')).thenAnswer((_) async => customer);
        return CustomerCubit(mockRepo);
      },
      act: (c) => c.getCustomerById('c1'),
      expect: () => [
        isA<GetCustomerByIdLoading>(),
        isA<GetCustomerByIdSuccess>(),
      ],
    );

    blocTest<CustomerCubit, CustomerState>(
      'getCustomerById emits error when customer not found',
      build: () {
        when(() => mockRepo.getCustomerById('x')).thenAnswer((_) async => null);
        return CustomerCubit(mockRepo);
      },
      act: (c) => c.getCustomerById('x'),
      expect: () => [
        isA<GetCustomerByIdLoading>(),
        isA<GetCustomerByIdError>(),
      ],
    );

    blocTest<CustomerCubit, CustomerState>(
      'addCustomer emits loading then success',
      build: () {
        when(() => mockRepo.createCustomer(
          name: any(named: 'name'),
          email: any(named: 'email'),
          phoneNumber: any(named: 'phoneNumber'),
          address: any(named: 'address'),
          countryId: any(named: 'countryId'),
          cityId: any(named: 'cityId'),
          customerGroupId: any(named: 'customerGroupId'),
        )).thenAnswer((_) async => sampleCustomer('new'));
        when(() => mockRepo.getAllCustomers()).thenAnswer((_) async => [sampleCustomer('c1')]);
        return CustomerCubit(mockRepo);
      },
      act: (c) => c.addCustomer(
        name: 'New Customer',
        email: 'new@test.com',
        phoneNumber: '1234567890',
        address: 'Test Address',
        country: 'c1',
        city: 'c2',
      ),
      expect: () => [
        isA<CreateCustomerLoading>(),
        isA<CreateCustomerSuccess>(),
        isA<GetCustomersLoading>(),
        isA<GetCustomersSuccess>(),
      ],
    );
  });
}
