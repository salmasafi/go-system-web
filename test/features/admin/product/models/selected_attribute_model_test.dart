import 'package:flutter_test/flutter_test.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';

void main() {
  group('SelectedAttribute Model Tests', () {
    test('should parse from JSON correctly', () {
      final json = {
        'attribute_type_id': 'type-1',
        'attribute_type_name': 'Color',
        'attribute_value_id': 'val-1',
        'attribute_value_name': 'Red',
      };

      final model = SelectedAttribute.fromJson(json);

      expect(model.attributeTypeId, 'type-1');
      expect(model.attributeTypeName, 'Color');
      expect(model.attributeValueId, 'val-1');
      expect(model.attributeValueName, 'Red');
    });

    test('should serialize to JSON correctly', () {
      final model = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
      );

      final json = model.toJson();

      expect(json['attribute_type_id'], 'type-1');
      expect(json['attribute_type_name'], 'Color');
      expect(json['attribute_value_id'], 'val-1');
      expect(json['attribute_value_name'], 'Red');
    });

    test('should generate correct DB JSON', () {
      final model = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
      );

      final dbJson = model.toDbJson('sale-item-123');

      expect(dbJson['sale_item_id'], 'sale-item-123');
      expect(dbJson['attribute_type_id'], 'type-1');
      expect(dbJson['attribute_value_name'], 'Red');
    });

    test('should return display string correctly', () {
      final model = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
      );

      expect(model.getDisplayString(), 'Color: Red');
    });

    test('equality operator compares by typeId and valueId', () {
      final model1 = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
      );

      final model2 = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Colour', // different name
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
      );

      final model3 = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeValueId: 'val-2', // different value
        attributeValueName: 'Blue',
      );

      expect(model1 == model2, isTrue); // Same IDs
      expect(model1 == model3, isFalse); // Different value ID
    });
  });

  group('CartItemAttributes Tests', () {
    test('isSameAs should return true for same attributes regardless of order', () {
      final attr1 = SelectedAttribute(
        attributeTypeId: 't1', attributeTypeName: '',
        attributeValueId: 'v1', attributeValueName: '',
      );
      final attr2 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: '',
        attributeValueId: 'v2', attributeValueName: '',
      );

      final cartAttr1 = CartItemAttributes(attributes: [attr1, attr2]);
      final cartAttr2 = CartItemAttributes(attributes: [attr2, attr1]); // reversed order

      expect(cartAttr1.isSameAs(cartAttr2), isTrue);
    });

    test('isSameAs should return false if attributes differ', () {
      final attr1 = SelectedAttribute(
        attributeTypeId: 't1', attributeTypeName: '',
        attributeValueId: 'v1', attributeValueName: '',
      );
      final attr2 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: '',
        attributeValueId: 'v2', attributeValueName: '',
      );
      final attr3 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: '',
        attributeValueId: 'v3', attributeValueName: '',
      );

      final cartAttr1 = CartItemAttributes(attributes: [attr1, attr2]);
      final cartAttr2 = CartItemAttributes(attributes: [attr1, attr3]);
      final cartAttr3 = CartItemAttributes(attributes: [attr1]); // different length

      expect(cartAttr1.isSameAs(cartAttr2), isFalse);
      expect(cartAttr1.isSameAs(cartAttr3), isFalse);
    });

    test('getDisplayString joins multiple attributes', () {
      final attr1 = SelectedAttribute(
        attributeTypeId: 't1', attributeTypeName: 'Color',
        attributeValueId: 'v1', attributeValueName: 'Red',
      );
      final attr2 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: 'Size',
        attributeValueId: 'v2', attributeValueName: 'Large',
      );

      final cartAttr = CartItemAttributes(attributes: [attr1, attr2]);

      expect(cartAttr.getDisplayString(), 'Color: Red, Size: Large');
    });
  });
}
