import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
  });

  Product sampleProduct(String id) => Product.fromJson({
        'id': id,
        'name': 'Product $id',
        'description': 'Description',
        'image': 'product_$id.jpg',
        'code': 'P$id',
        'price': 100.0,
        'quantity': 50,
        'category_id': [{'id': 'c1', 'name': 'Category'}],
        'brand_id': {'id': 'b1', 'name': 'Brand'},
        'taxes_id': {'id': 't1', 'name': 'Tax'},
        'created_at': '2024-01-01',
      });

  group('ProductsCubit', () {
    blocTest<ProductsCubit, ProductsState>(
      'getProducts emits loading then success',
      build: () {
        when(() => mockRepo.getAllProducts()).thenAnswer((_) async => [sampleProduct('p1')]);
        return ProductsCubit(mockRepo);
      },
      act: (c) => c.getProducts(),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllProducts()).called(1);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'getProducts emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllProducts()).thenThrow(Exception('network'));
        return ProductsCubit(mockRepo);
      },
      act: (c) => c.getProducts(),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsError>(),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'generateCode returns code from repository',
      build: () {
        when(() => mockRepo.generateProductCode()).thenAnswer((_) async => 'P123');
        return ProductsCubit(mockRepo);
      },
      act: (c) async {
        final code = await c.generateCode();
        expect(code, 'P123');
      },
      expect: () => [],
    );
  });
}
