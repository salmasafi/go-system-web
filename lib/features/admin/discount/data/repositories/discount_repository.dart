import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/discount_model.dart';

abstract class DiscountRepositoryInterface {
  Future<List<DiscountModel>> getAllDiscounts();
  Future<DiscountModel> createDiscount(DiscountModel discount);
  Future<DiscountModel> updateDiscount(DiscountModel discount);
  Future<bool> deleteDiscount(String id);
}

class DiscountRepository implements DiscountRepositoryInterface {
  late final DiscountRepositoryInterface _dataSource;

  DiscountRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('discounts')) {
      log('DiscountRepository: Using Supabase');
      _dataSource = _DiscountSupabaseDataSource();
    } else {
      log('DiscountRepository: Using Dio (legacy)');
      _dataSource = _DiscountDioDataSource();
    }
  }

  @override
  Future<List<DiscountModel>> getAllDiscounts() => _dataSource.getAllDiscounts();

  @override
  Future<DiscountModel> createDiscount(DiscountModel discount) => _dataSource.createDiscount(discount);

  @override
  Future<DiscountModel> updateDiscount(DiscountModel discount) => _dataSource.updateDiscount(discount);

  @override
  Future<bool> deleteDiscount(String id) => _dataSource.deleteDiscount(id);

  void enableSupabase() {
    MigrationService.enableSupabase('discounts');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('discounts');
    _initializeDataSource();
  }
}

class _DiscountSupabaseDataSource implements DiscountRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<DiscountModel>> getAllDiscounts() async {
    try {
      log('DiscountSupabase: Fetching all discounts');
      final response = await _client.from('discounts').select().order('name');
      return (response as List).map((json) => _mapSupabaseToDiscountModel(json)).toList();
    } catch (e) {
      log('DiscountSupabase: Error fetching discounts - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<DiscountModel> createDiscount(DiscountModel discount) async {
    try {
      log('DiscountSupabase: Creating discount');
      final data = {
        'name': discount.name,
        'amount': discount.amount,
        'type': discount.type,
        'status': discount.status,
      };
      final response = await _client.from('discounts').insert(data).select().single();
      return _mapSupabaseToDiscountModel(response);
    } catch (e) {
      log('DiscountSupabase: Error creating discount - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<DiscountModel> updateDiscount(DiscountModel discount) async {
    try {
      log('DiscountSupabase: Updating discount');
      final data = {
        'name': discount.name,
        'amount': discount.amount,
        'type': discount.type,
        'status': discount.status,
      };
      final response = await _client.from('discounts').update(data).eq('id', discount.id).select().single();
      return _mapSupabaseToDiscountModel(response);
    } catch (e) {
      log('DiscountSupabase: Error updating discount - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteDiscount(String id) async {
    try {
      log('DiscountSupabase: Deleting discount');
      await _client.from('discounts').delete().eq('id', id);
      return true;
    } catch (e) {
      log('DiscountSupabase: Error deleting discount - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  DiscountModel _mapSupabaseToDiscountModel(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      status: json['status'],
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      version: 0, // Placeholder
    );
  }
}

class _DiscountDioDataSource implements DiscountRepositoryInterface {
  @override
  Future<List<DiscountModel>> getAllDiscounts() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllDiscounts);
      if (response.statusCode == 200) {
        final model = DiscountResponse.fromJson(response.data);
        return model.data.discounts;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<DiscountModel> createDiscount(DiscountModel discount) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addDiscount,
        data: discount.toJson()..remove('_id'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return DiscountModel.fromJson(response.data['data']['discount']);
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<DiscountModel> updateDiscount(DiscountModel discount) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateDiscount(discount.id),
        data: discount.toJson(),
      );
      if (response.statusCode == 200) {
        return DiscountModel.fromJson(response.data['data']['discount']);
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteDiscount(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteDiscount(id));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}

