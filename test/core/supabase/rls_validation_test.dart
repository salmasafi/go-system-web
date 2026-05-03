import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late ProductRepository repository;
  late MockSupabaseClient mockClient;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = ProductRepository();
  });

  group('RLS Validation Simulation Tests', () {
    test('Delete product throws exception when RLS denies permission', () async {
      // Simulate RLS error by throwing PostgrestException
      final rlsError = PostgrestException(
        message: 'new row violates row-level security policy for table "products"',
        code: '42501',
      );

      // Mock the from() method to throw error during delete
      when(() => mockClient.from('products')).thenThrow(rlsError);

      expect(
        () => repository.deleteProduct('1'),
        throwsA(isA<Exception>()),
      );
    });

    test('Update product throws exception when user role is insufficient', () async {
      final rlsError = PostgrestException(
        message: 'permission denied for table products',
        code: '42501',
      );

      // Create a test product
      final testProduct = Product(
        id: '1',
        name: 'New Name',
        arName: 'اسم جديد',
        image: '',
        categoryId: [],
        brandId: Brand.empty(),
        unit: 'piece',
        price: 100.0,
        quantity: 10,
        description: 'Test',
        arDescription: 'اختبار',
        expAbility: false,
        minimumQuantitySale: 1,
        lowStock: 5,
        wholePrice: 90.0,
        startQuantaty: 10,
        productHasImei: false,
        showQuantity: true,
        maximumToShow: 100,
        galleryProduct: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock the from() method to throw error during update
      when(() => mockClient.from('products')).thenThrow(rlsError);

      expect(
        () => repository.updateProduct('1', testProduct),
        throwsA(isA<Exception>()),
      );
    });
  });
}
