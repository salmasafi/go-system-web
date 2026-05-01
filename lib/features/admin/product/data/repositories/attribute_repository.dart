import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../models/attribute_type_model.dart';
import '../../models/attribute_value_model.dart';
import '../../models/product_attribute_model.dart';
import '../../models/sale_item_attribute_model.dart';
import '../../models/selected_attribute_model.dart';

/// Interface for attribute type data operations
abstract class AttributeTypeRepositoryInterface {
  Future<List<AttributeType>> getAllAttributeTypes();
  Future<AttributeType?> getAttributeTypeById(String id);
  Future<AttributeType> createAttributeType(AttributeType attributeType);
  Future<AttributeType> updateAttributeType(String id, AttributeType attributeType);
  Future<void> deleteAttributeType(String id);
}

/// Interface for attribute value data operations
abstract class AttributeValueRepositoryInterface {
  Future<List<AttributeValue>> getValuesByType(String attributeTypeId);
  Future<AttributeValue?> getAttributeValueById(String id);
  Future<AttributeValue> createAttributeValue(AttributeValue attributeValue);
  Future<AttributeValue> updateAttributeValue(String id, AttributeValue attributeValue);
  Future<void> deleteAttributeValue(String id);
}

/// Interface for product attribute data operations
abstract class ProductAttributeRepositoryInterface {
  Future<List<ProductAttribute>> getAttributesByProduct(String productId);
  Future<ProductAttribute?> getProductAttribute(String productId, String attributeTypeId);
  Future<ProductAttribute> assignAttributeToProduct(ProductAttribute productAttribute);
  Future<ProductAttribute> updateProductAttribute(String id, ProductAttribute productAttribute);
  Future<void> removeProductAttribute(String id);
  Future<void> removeAttributesByProduct(String productId);
}

/// Interface for sale item attribute data operations
abstract class SaleItemAttributeRepositoryInterface {
  Future<void> saveSaleItemAttributes(String saleItemId, List<SelectedAttribute> attributes);
  Future<List<SaleItemAttribute>> getAttributesBySaleItem(String saleItemId);
  Future<void> deleteSaleItemAttributes(String saleItemId);
}

/// Repository implementation using Supabase for attribute types
class AttributeTypeRepository implements AttributeTypeRepositoryInterface {
  final _AttributeTypeSupabaseDataSource _dataSource = _AttributeTypeSupabaseDataSource();

  @override
  Future<List<AttributeType>> getAllAttributeTypes() => _dataSource.getAllAttributeTypes();

  @override
  Future<AttributeType?> getAttributeTypeById(String id) => _dataSource.getAttributeTypeById(id);

  @override
  Future<AttributeType> createAttributeType(AttributeType attributeType) => 
      _dataSource.createAttributeType(attributeType);

  @override
  Future<AttributeType> updateAttributeType(String id, AttributeType attributeType) => 
      _dataSource.updateAttributeType(id, attributeType);

  @override
  Future<void> deleteAttributeType(String id) => _dataSource.deleteAttributeType(id);
}

/// Repository implementation using Supabase for attribute values
class AttributeValueRepository implements AttributeValueRepositoryInterface {
  final _AttributeValueSupabaseDataSource _dataSource = _AttributeValueSupabaseDataSource();

  @override
  Future<List<AttributeValue>> getValuesByType(String attributeTypeId) => 
      _dataSource.getValuesByType(attributeTypeId);

  @override
  Future<AttributeValue?> getAttributeValueById(String id) => _dataSource.getAttributeValueById(id);

  @override
  Future<AttributeValue> createAttributeValue(AttributeValue attributeValue) => 
      _dataSource.createAttributeValue(attributeValue);

  @override
  Future<AttributeValue> updateAttributeValue(String id, AttributeValue attributeValue) => 
      _dataSource.updateAttributeValue(id, attributeValue);

  @override
  Future<void> deleteAttributeValue(String id) => _dataSource.deleteAttributeValue(id);
}

/// Repository implementation using Supabase for product attributes
class ProductAttributeRepository implements ProductAttributeRepositoryInterface {
  final _ProductAttributeSupabaseDataSource _dataSource = _ProductAttributeSupabaseDataSource();

  @override
  Future<List<ProductAttribute>> getAttributesByProduct(String productId) => 
      _dataSource.getAttributesByProduct(productId);

  @override
  Future<ProductAttribute?> getProductAttribute(String productId, String attributeTypeId) => 
      _dataSource.getProductAttribute(productId, attributeTypeId);

  @override
  Future<ProductAttribute> assignAttributeToProduct(ProductAttribute productAttribute) => 
      _dataSource.assignAttributeToProduct(productAttribute);

  @override
  Future<ProductAttribute> updateProductAttribute(String id, ProductAttribute productAttribute) => 
      _dataSource.updateProductAttribute(id, productAttribute);

  @override
  Future<void> removeProductAttribute(String id) => _dataSource.removeProductAttribute(id);

  @override
  Future<void> removeAttributesByProduct(String productId) => 
      _dataSource.removeAttributesByProduct(productId);
}

/// Repository implementation using Supabase for sale item attributes
class SaleItemAttributeRepository implements SaleItemAttributeRepositoryInterface {
  final _SaleItemAttributeSupabaseDataSource _dataSource = _SaleItemAttributeSupabaseDataSource();

  @override
  Future<void> saveSaleItemAttributes(String saleItemId, List<SelectedAttribute> attributes) => 
      _dataSource.saveSaleItemAttributes(saleItemId, attributes);

  @override
  Future<List<SaleItemAttribute>> getAttributesBySaleItem(String saleItemId) => 
      _dataSource.getAttributesBySaleItem(saleItemId);

  @override
  Future<void> deleteSaleItemAttributes(String saleItemId) => 
      _dataSource.deleteSaleItemAttributes(saleItemId);
}

// ============================================
// Supabase Data Sources
// ============================================

class _AttributeTypeSupabaseDataSource implements AttributeTypeRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<AttributeType>> getAllAttributeTypes() async {
    try {
      log('AttributeTypeSupabase: Fetching all attribute types');

      final response = await _client
          .from('attribute_types')
          .select('*')
          .eq('status', true)
          .order('name');

      final attributeTypes = (response as List)
          .map((json) => AttributeType.fromJson(json as Map<String, dynamic>))
          .toList();

      log('AttributeTypeSupabase: Fetched ${attributeTypes.length} attribute types');
      return attributeTypes;
    } catch (e) {
      log('AttributeTypeSupabase: Error fetching attribute types - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AttributeType?> getAttributeTypeById(String id) async {
    try {
      log('AttributeTypeSupabase: Fetching attribute type by id: $id');

      final response = await _client
          .from('attribute_types')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return AttributeType.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('AttributeTypeSupabase: Error fetching attribute type - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AttributeType> createAttributeType(AttributeType attributeType) async {
    try {
      log('AttributeTypeSupabase: Creating attribute type: ${attributeType.name}');

      final response = await _client
          .from('attribute_types')
          .insert(attributeType.toCreateJson())
          .select()
          .single();

      log('AttributeTypeSupabase: Created attribute type successfully');
      return AttributeType.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('AttributeTypeSupabase: Error creating attribute type - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AttributeType> updateAttributeType(String id, AttributeType attributeType) async {
    try {
      log('AttributeTypeSupabase: Updating attribute type: $id');

      final response = await _client
          .from('attribute_types')
          .update(attributeType.toUpdateJson())
          .eq('id', id)
          .select()
          .single();

      log('AttributeTypeSupabase: Updated attribute type successfully');
      return AttributeType.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('AttributeTypeSupabase: Error updating attribute type - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteAttributeType(String id) async {
    try {
      log('AttributeTypeSupabase: Deleting attribute type: $id');

      await _client.from('attribute_types').delete().eq('id', id);

      log('AttributeTypeSupabase: Deleted attribute type successfully');
    } catch (e) {
      log('AttributeTypeSupabase: Error deleting attribute type - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

class _AttributeValueSupabaseDataSource implements AttributeValueRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<AttributeValue>> getValuesByType(String attributeTypeId) async {
    try {
      log('AttributeValueSupabase: Fetching values for type: $attributeTypeId');

      final response = await _client
          .from('attribute_values')
          .select('*')
          .eq('attribute_type_id', attributeTypeId)
          .eq('status', true)
          .order('name');

      final values = (response as List)
          .map((json) => AttributeValue.fromJson(json as Map<String, dynamic>))
          .toList();

      log('AttributeValueSupabase: Fetched ${values.length} values');
      return values;
    } catch (e) {
      log('AttributeValueSupabase: Error fetching values - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AttributeValue?> getAttributeValueById(String id) async {
    try {
      log('AttributeValueSupabase: Fetching value by id: $id');

      final response = await _client
          .from('attribute_values')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return AttributeValue.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('AttributeValueSupabase: Error fetching value - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AttributeValue> createAttributeValue(AttributeValue attributeValue) async {
    try {
      log('AttributeValueSupabase: Creating attribute value: ${attributeValue.name}');

      final response = await _client
          .from('attribute_values')
          .insert(attributeValue.toCreateJson())
          .select()
          .single();

      log('AttributeValueSupabase: Created attribute value successfully');
      return AttributeValue.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('AttributeValueSupabase: Error creating attribute value - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AttributeValue> updateAttributeValue(String id, AttributeValue attributeValue) async {
    try {
      log('AttributeValueSupabase: Updating attribute value: $id');

      final response = await _client
          .from('attribute_values')
          .update(attributeValue.toUpdateJson())
          .eq('id', id)
          .select()
          .single();

      log('AttributeValueSupabase: Updated attribute value successfully');
      return AttributeValue.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('AttributeValueSupabase: Error updating attribute value - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteAttributeValue(String id) async {
    try {
      log('AttributeValueSupabase: Deleting attribute value: $id');

      await _client.from('attribute_values').delete().eq('id', id);

      log('AttributeValueSupabase: Deleted attribute value successfully');
    } catch (e) {
      log('AttributeValueSupabase: Error deleting attribute value - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

class _ProductAttributeSupabaseDataSource implements ProductAttributeRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<ProductAttribute>> getAttributesByProduct(String productId) async {
    try {
      log('ProductAttributeSupabase: Fetching attributes for product: $productId');

      final response = await _client
          .from('product_attributes')
          .select('''
            *,
            attribute_type:attribute_type_id(*),
            available_values:attribute_value_ids(*)
          ''')
          .eq('product_id', productId);

      final attributes = (response as List)
          .map((json) => ProductAttribute.fromJson(json as Map<String, dynamic>))
          .toList();

      log('ProductAttributeSupabase: Fetched ${attributes.length} attributes');
      return attributes;
    } catch (e) {
      log('ProductAttributeSupabase: Error fetching attributes - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<ProductAttribute?> getProductAttribute(String productId, String attributeTypeId) async {
    try {
      log('ProductAttributeSupabase: Fetching product attribute');

      final response = await _client
          .from('product_attributes')
          .select('''
            *,
            attribute_type:attribute_type_id(*)
          ''')
          .eq('product_id', productId)
          .eq('attribute_type_id', attributeTypeId)
          .maybeSingle();

      if (response == null) return null;

      return ProductAttribute.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('ProductAttributeSupabase: Error fetching product attribute - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<ProductAttribute> assignAttributeToProduct(ProductAttribute productAttribute) async {
    try {
      log('ProductAttributeSupabase: Assigning attribute to product');

      final response = await _client
          .from('product_attributes')
          .insert(productAttribute.toCreateJson())
          .select()
          .single();

      log('ProductAttributeSupabase: Assigned attribute successfully');
      return ProductAttribute.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('ProductAttributeSupabase: Error assigning attribute - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<ProductAttribute> updateProductAttribute(String id, ProductAttribute productAttribute) async {
    try {
      log('ProductAttributeSupabase: Updating product attribute: $id');

      final response = await _client
          .from('product_attributes')
          .update(productAttribute.toUpdateJson())
          .eq('id', id)
          .select()
          .single();

      log('ProductAttributeSupabase: Updated product attribute successfully');
      return ProductAttribute.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('ProductAttributeSupabase: Error updating product attribute - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> removeProductAttribute(String id) async {
    try {
      log('ProductAttributeSupabase: Removing product attribute: $id');

      await _client.from('product_attributes').delete().eq('id', id);

      log('ProductAttributeSupabase: Removed product attribute successfully');
    } catch (e) {
      log('ProductAttributeSupabase: Error removing product attribute - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> removeAttributesByProduct(String productId) async {
    try {
      log('ProductAttributeSupabase: Removing all attributes for product: $productId');

      await _client.from('product_attributes').delete().eq('product_id', productId);

      log('ProductAttributeSupabase: Removed all attributes successfully');
    } catch (e) {
      log('ProductAttributeSupabase: Error removing attributes - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

class _SaleItemAttributeSupabaseDataSource implements SaleItemAttributeRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<void> saveSaleItemAttributes(String saleItemId, List<SelectedAttribute> attributes) async {
    try {
      log('SaleItemAttributeSupabase: Saving attributes for sale item: $saleItemId');

      // Batch insert all attributes
      final records = attributes.map((attr) => attr.toDbJson(saleItemId)).toList();
      
      await _client.from('sale_item_attributes').insert(records);

      log('SaleItemAttributeSupabase: Saved ${attributes.length} attributes successfully');
    } catch (e) {
      log('SaleItemAttributeSupabase: Error saving attributes - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SaleItemAttribute>> getAttributesBySaleItem(String saleItemId) async {
    try {
      log('SaleItemAttributeSupabase: Fetching attributes for sale item: $saleItemId');

      final response = await _client
          .from('sale_item_attributes')
          .select('*')
          .eq('sale_item_id', saleItemId)
          .order('created_at');

      final attributes = (response as List)
          .map((json) => SaleItemAttribute.fromJson(json as Map<String, dynamic>))
          .toList();

      log('SaleItemAttributeSupabase: Fetched ${attributes.length} attributes');
      return attributes;
    } catch (e) {
      log('SaleItemAttributeSupabase: Error fetching attributes - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteSaleItemAttributes(String saleItemId) async {
    try {
      log('SaleItemAttributeSupabase: Deleting attributes for sale item: $saleItemId');

      await _client.from('sale_item_attributes').delete().eq('sale_item_id', saleItemId);

      log('SaleItemAttributeSupabase: Deleted attributes successfully');
    } catch (e) {
      log('SaleItemAttributeSupabase: Error deleting attributes - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

