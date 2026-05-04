import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/revenue/cubit/revenue_cubit.dart';
import 'package:GoSystem/features/admin/revenue/data/repositories/revenue_repository.dart';

class MockRevenueRepository extends Mock implements RevenueRepository {}

void main() {
  late MockRevenueRepository mockRepo;

  setUp(() {
    mockRepo = MockRevenueRepository();
  });

  SupabaseRevenueModel sampleRevenue(String id) => SupabaseRevenueModel.fromJson({
        'id': id,
        'amount': 1000.0,
        'category_id': 'c1',
        'bank_account_id': 'a1',
        'date': '2024-01-01',
        'description': 'Test revenue',
        'status': 'approved',
        'created_at': '2024-01-01T00:00:00.000Z',
      });

  group('RevenueCubit', () {
    blocTest<RevenueCubit, RevenueState>(
      'getRevenues emits loading then success',
      build: () {
        when(() => mockRepo.getAllRevenues()).thenAnswer((_) async => [sampleRevenue('r1')]);
        return RevenueCubit(mockRepo);
      },
      act: (c) => c.getRevenues(),
      expect: () => [
        isA<GetRevenuesLoading>(),
        isA<GetRevenuesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllRevenues()).called(1);
      },
    );

    blocTest<RevenueCubit, RevenueState>(
      'getRevenues emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllRevenues()).thenThrow(Exception('network'));
        return RevenueCubit(mockRepo);
      },
      act: (c) => c.getRevenues(),
      expect: () => [
        isA<GetRevenuesLoading>(),
        isA<GetRevenuesError>(),
      ],
    );

    blocTest<RevenueCubit, RevenueState>(
      'getSelectionData emits loading then success',
      build: () {
        when(() => mockRepo.getSelectionData()).thenAnswer((_) async => {
          'success': true,
          'data': {
            'categories': [],
            'accounts': [],
          },
        });
        return RevenueCubit(mockRepo);
      },
      act: (c) => c.getSelectionData(),
      expect: () => [
        isA<GetSelectionDataLoading>(),
        isA<GetSelectionDataSuccess>(),
      ],
    );
  });
}
