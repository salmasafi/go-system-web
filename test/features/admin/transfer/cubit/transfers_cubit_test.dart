import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/transfer/cubit/transfers_cubit.dart';
import 'package:GoSystem/features/admin/transfer/data/repositories/transfer_repository.dart';

class MockTransferRepository extends Mock implements TransferRepository {}

void main() {
  late MockTransferRepository mockRepo;

  setUp(() {
    mockRepo = MockTransferRepository();
  });

  group('TransfersCubit', () {
    blocTest<TransfersCubit, TransfersState>(
      'getAllTransfers emits loading then success',
      build: () {
        when(() => mockRepo.getAllTransfers()).thenAnswer((_) async => []);
        return TransfersCubit(mockRepo);
      },
      act: (c) => c.getAllTransfers(),
      expect: () => [
        isA<GetTransfersLoading>(),
        isA<GetTransfersSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllTransfers()).called(1);
      },
    );

    blocTest<TransfersCubit, TransfersState>(
      'getAllTransfers emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllTransfers()).thenThrow(Exception('network'));
        return TransfersCubit(mockRepo);
      },
      act: (c) => c.getAllTransfers(),
      expect: () => [
        isA<GetTransfersLoading>(),
        isA<GetTransfersError>(),
      ],
    );

    blocTest<TransfersCubit, TransfersState>(
      'getIncomingTransfers emits loading then success',
      build: () {
        when(() => mockRepo.getIncomingTransfers('w1')).thenAnswer((_) async => []);
        return TransfersCubit(mockRepo);
      },
      act: (c) => c.getIncomingTransfers('w1'),
      expect: () => [
        isA<GetIncomingLoading>(),
        isA<GetIncomingSuccess>(),
      ],
    );

    blocTest<TransfersCubit, TransfersState>(
      'getOutgoingTransfers emits loading then success',
      build: () {
        when(() => mockRepo.getOutgoingTransfers('w1')).thenAnswer((_) async => []);
        return TransfersCubit(mockRepo);
      },
      act: (c) => c.getOutgoingTransfers('w1'),
      expect: () => [
        isA<GetOutgoingLoading>(),
        isA<GetOutgoingSuccess>(),
      ],
    );
  });
}
