import 'package:flutter_test/flutter_test.dart';
import 'package:GoSystem/features/admin/product/models/attribute_type_model.dart';
import 'package:GoSystem/features/admin/product/models/attribute_value_model.dart';
import 'package:GoSystem/features/admin/product/models/product_attribute_model.dart';

void main() {
  group('ProductAttribute Model Tests', () {
    test('should parse from JSON correctly', () {
      final json = {
        'id': '123',
        'product_id': 'prod-1',
        'attribute_type_id': 'type-1',
        'attribute_value_ids': ['val-1', 'val-2'],
        'attribute_type': {
          'id': 'type-1',
          'name': 'Color',
          'ar_name': 'لون',
          'status': true,
          'created_at': '2026-01-01T00:00:00.000Z',
          'updated_at': '2026-01-01T00:00:00.000Z',
        },
        'available_values': [
          {
            'id': 'val-1',
            'attribute_type_id': 'type-1',
            'name': 'Red',
            'ar_name': 'أحمر',
            'status': true,
            'created_at': '2026-01-01T00:00:00.000Z',
            'updated_at': '2026-01-01T00:00:00.000Z',
          }
        ],
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };

      final model = ProductAttribute.fromJson(json);

      expect(model.id, '123');
      expect(model.productId, 'prod-1');
      expect(model.attributeTypeId, 'type-1');
      expect(model.attributeValueIds, containsAll(['val-1', 'val-2']));
      expect(model.attributeType, isNotNull);
      expect(model.attributeType!.name, 'Color');
      expect(model.availableValues, isNotEmpty);
      expect(model.availableValues!.first.name, 'Red');
    });

    test('should serialize to JSON correctly', () {
      final date = DateTime(2026, 1, 1).toUtc();
      final model = ProductAttribute(
        id: '123',
        productId: 'prod-1',
        attributeTypeId: 'type-1',
        attributeValueIds: ['val-1'],
        createdAt: date,
        updatedAt: date,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['product_id'], 'prod-1');
      expect(json['attribute_type_id'], 'type-1');
      expect(json['attribute_value_ids'], ['val-1']);
      expect(json['created_at'], date.toIso8601String());
    });

    test('hasValue should return true if value is in attributeValueIds', () {
      final model = ProductAttribute(
        id: '123',
        productId: 'prod-1',
        attributeTypeId: 'type-1',
        attributeValueIds: ['val-1', 'val-2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(model.hasValue('val-1'), isTrue);
      expect(model.hasValue('val-3'), isFalse);
    });

    test('getLocalizedTypeName should return correct localization', () {
      final type = AttributeType(
        id: 'type-1',
        name: 'Color',
        arName: 'لون',
        status: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = ProductAttribute(
        id: '123',
        productId: 'prod-1',
        attributeTypeId: 'type-1',
        attributeType: type,
        attributeValueIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(model.getLocalizedTypeName(isArabic: false), 'Color');
      expect(model.getLocalizedTypeName(isArabic: true), 'لون');
    });

    test('getLocalizedValueNames should filter based on available and selected IDs', () {
      final available = [
        AttributeValue(id: 'val-1', attributeTypeId: 't-1', name: 'Red', arName: 'أحمر', status: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        AttributeValue(id: 'val-2', attributeTypeId: 't-1', name: 'Blue', arName: 'أزرق', status: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        AttributeValue(id: 'val-3', attributeTypeId: 't-1', name: 'Green', arName: 'أخضر', status: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];

      final model = ProductAttribute(
        id: '123',
        productId: 'prod-1',
        attributeTypeId: 'type-1',
        attributeValueIds: ['val-1', 'val-3'], // Only Red and Green selected
        availableValues: available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final enNames = model.getLocalizedValueNames(isArabic: false);
      final arNames = model.getLocalizedValueNames(isArabic: true);

      expect(enNames, ['Red', 'Green']);
      expect(arNames, ['أحمر', 'أخضر']);
    });
  });
}
