import 'package:flutter_test/flutter_test.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';

void main() {
  group('SelectedAttribute Model Tests', () {
    test('should parse from JSON correctly', () {
      final json = {
        'attribute_type_id': 'type-1',
        'attribute_type_name': 'Color',
        'attribute_type_ar_name': 'لون',
        'attribute_value_id': 'val-1',
        'attribute_value_name': 'Red',
        'attribute_value_ar_name': 'أحمر',
      };

      final model = SelectedAttribute.fromJson(json);

      expect(model.attributeTypeId, 'type-1');
      expect(model.attributeTypeName, 'Color');
      expect(model.attributeTypeArName, 'لون');
      expect(model.attributeValueId, 'val-1');
      expect(model.attributeValueName, 'Red');
      expect(model.attributeValueArName, 'أحمر');
    });

    test('should serialize to JSON correctly', () {
      final model = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeTypeArName: 'لون',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
        attributeValueArName: 'أحمر',
      );

      final json = model.toJson();

      expect(json['attribute_type_id'], 'type-1');
      expect(json['attribute_type_name'], 'Color');
      expect(json['attribute_type_ar_name'], 'لون');
      expect(json['attribute_value_id'], 'val-1');
      expect(json['attribute_value_name'], 'Red');
      expect(json['attribute_value_ar_name'], 'أحمر');
    });

    test('should generate correct DB JSON', () {
      final model = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeTypeArName: 'لون',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
        attributeValueArName: 'أحمر',
      );

      final dbJson = model.toDbJson('sale-item-123');

      expect(dbJson['sale_item_id'], 'sale-item-123');
      expect(dbJson['attribute_type_id'], 'type-1');
      expect(dbJson['attribute_value_name'], 'Red');
    });

    test('should return localized strings correctly', () {
      final model = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeTypeArName: 'لون',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
        attributeValueArName: 'أحمر',
      );

      expect(model.getLocalizedTypeName(isArabic: false), 'Color');
      expect(model.getLocalizedTypeName(isArabic: true), 'لون');
      expect(model.getLocalizedValueName(isArabic: false), 'Red');
      expect(model.getLocalizedValueName(isArabic: true), 'أحمر');
      
      expect(model.getDisplayString(isArabic: false), 'Color: Red');
      expect(model.getDisplayString(isArabic: true), 'لون: أحمر');
    });

    test('equality operator compares by typeId and valueId', () {
      final model1 = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeTypeArName: 'لون',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
        attributeValueArName: 'أحمر',
      );

      final model2 = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Colour', // different name
        attributeTypeArName: 'لون',
        attributeValueId: 'val-1',
        attributeValueName: 'Red',
        attributeValueArName: 'أحمر',
      );

      final model3 = SelectedAttribute(
        attributeTypeId: 'type-1',
        attributeTypeName: 'Color',
        attributeTypeArName: 'لون',
        attributeValueId: 'val-2', // different value
        attributeValueName: 'Blue',
        attributeValueArName: 'أزرق',
      );

      expect(model1 == model2, isTrue); // Same IDs
      expect(model1 == model3, isFalse); // Different value ID
    });
  });

  group('CartItemAttributes Tests', () {
    test('isSameAs should return true for same attributes regardless of order', () {
      final attr1 = SelectedAttribute(
        attributeTypeId: 't1', attributeTypeName: '', attributeTypeArName: '',
        attributeValueId: 'v1', attributeValueName: '', attributeValueArName: '',
      );
      final attr2 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: '', attributeTypeArName: '',
        attributeValueId: 'v2', attributeValueName: '', attributeValueArName: '',
      );

      final cartAttr1 = CartItemAttributes(attributes: [attr1, attr2]);
      final cartAttr2 = CartItemAttributes(attributes: [attr2, attr1]); // reversed order

      expect(cartAttr1.isSameAs(cartAttr2), isTrue);
    });

    test('isSameAs should return false if attributes differ', () {
      final attr1 = SelectedAttribute(
        attributeTypeId: 't1', attributeTypeName: '', attributeTypeArName: '',
        attributeValueId: 'v1', attributeValueName: '', attributeValueArName: '',
      );
      final attr2 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: '', attributeTypeArName: '',
        attributeValueId: 'v2', attributeValueName: '', attributeValueArName: '',
      );
      final attr3 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: '', attributeTypeArName: '',
        attributeValueId: 'v3', attributeValueName: '', attributeValueArName: '',
      );

      final cartAttr1 = CartItemAttributes(attributes: [attr1, attr2]);
      final cartAttr2 = CartItemAttributes(attributes: [attr1, attr3]);
      final cartAttr3 = CartItemAttributes(attributes: [attr1]); // different length

      expect(cartAttr1.isSameAs(cartAttr2), isFalse);
      expect(cartAttr1.isSameAs(cartAttr3), isFalse);
    });

    test('getDisplayString joins multiple attributes', () {
      final attr1 = SelectedAttribute(
        attributeTypeId: 't1', attributeTypeName: 'Color', attributeTypeArName: 'لون',
        attributeValueId: 'v1', attributeValueName: 'Red', attributeValueArName: 'أحمر',
      );
      final attr2 = SelectedAttribute(
        attributeTypeId: 't2', attributeTypeName: 'Size', attributeTypeArName: 'مقاس',
        attributeValueId: 'v2', attributeValueName: 'Large', attributeValueArName: 'كبير',
      );

      final cartAttr = CartItemAttributes(attributes: [attr1, attr2]);

      expect(cartAttr.getDisplayString(isArabic: false), 'Color: Red, Size: Large');
      expect(cartAttr.getDisplayString(isArabic: true), 'لون: أحمر, مقاس: كبير');
    });
  });
}
