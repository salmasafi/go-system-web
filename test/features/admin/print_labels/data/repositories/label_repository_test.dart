import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/print_labels/data/repositories/label_repository.dart';
import 'package:GoSystem/features/admin/print_labels/model/label_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockFunctions extends Mock implements FunctionsClient {}

void main() {
  late LabelRepository repository;
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = LabelRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('LabelRepository', () {
    test('generateLabels should return success message', () async {
      // Arrange
      final products = [
        LabelProductItem(
          productId: 'prod-1',
          name: 'Test Product',
          price: 100.0,
          quantity: 2,
        ),
      ];
      final config = LabelConfig(
        showProductName: true,
        showPrice: true,
        showPromotionalPrice: false,
        showBusinessName: true,
        showBrand: false,
      );
      const paperSize = '1_per_sheet_2x1';

      // Act
      final result = await repository.generateLabels(
        products: products,
        config: config,
        paperSize: paperSize,
      );

      // Assert
      expect(result, 'Labels generated successfully (Supabase mode)');
    });

    test('generateLabels with multiple products should work', () async {
      // Arrange
      final products = [
        LabelProductItem(
          productId: 'prod-1',
          name: 'Product 1',
          price: 50.0,
          quantity: 1,
        ),
        LabelProductItem(
          productId: 'prod-2',
          name: 'Product 2',
          variationName: 'Red',
          price: 75.0,
          quantity: 3,
        ),
      ];
      final config = LabelConfig(
        showProductName: false,
        showPrice: false,
        showPromotionalPrice: true,
        showBusinessName: false,
        showBrand: true,
      );
      const paperSize = '2_per_sheet_4x2';

      // Act
      final result = await repository.generateLabels(
        products: products,
        config: config,
        paperSize: paperSize,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, contains('Supabase'));
    });
  });
}
