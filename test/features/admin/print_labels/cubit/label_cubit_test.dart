import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/print_labels/cubit/label_cubit.dart';
import 'package:GoSystem/features/admin/print_labels/data/repositories/label_repository.dart';
import 'package:GoSystem/features/admin/print_labels/model/label_model.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

void main() {
  late MockLabelRepository mockRepo;

  setUp(() {
    mockRepo = MockLabelRepository();
  });

  group('LabelCubit', () {
    blocTest<LabelCubit, LabelState>(
      'initProducts emits data updated',
      build: () => LabelCubit(mockRepo),
      act: (c) => c.initProducts([
        LabelProductItem(productId: 'p1', name: 'Product 1', price: 100.0, quantity: 1),
      ]),
      expect: () => [
        isA<LabelDataUpdated>(),
      ],
    );

    blocTest<LabelCubit, LabelState>(
      'updateQuantity emits data updated',
      build: () {
        final cubit = LabelCubit(mockRepo);
        cubit.initProducts([LabelProductItem(productId: 'p1', name: 'Product 1', price: 100.0, quantity: 1)]);
        return cubit;
      },
      act: (c) => c.updateQuantity('p1', 5),
      expect: () => [
        isA<LabelDataUpdated>(),
      ],
    );

    blocTest<LabelCubit, LabelState>(
      'updateConfig emits data updated',
      build: () => LabelCubit(mockRepo),
      act: (c) => c.updateConfig(showProductName: true, showPrice: true),
      expect: () => [
        isA<LabelDataUpdated>(),
      ],
    );

    blocTest<LabelCubit, LabelState>(
      'generateLabels emits loading then success',
      build: () {
        when(() => mockRepo.generateLabels(
          products: any(named: 'products'),
          config: any(named: 'config'),
          paperSize: any(named: 'paperSize'),
        )).thenAnswer((_) async => 'Labels generated successfully');
        final cubit = LabelCubit(mockRepo);
        cubit.initProducts([LabelProductItem(productId: 'p1', name: 'Product 1', price: 100.0, quantity: 1)]);
        return cubit;
      },
      act: (c) => c.generateLabels(),
      expect: () => [
        isA<GenerateLabelsLoading>(),
        isA<GenerateLabelsSuccess>(),
      ],
    );
  });
}
