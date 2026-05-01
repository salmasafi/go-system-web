import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/coupon_model.dart';

abstract class CouponRepositoryInterface {
  Future<List<CouponModel>> getAllCoupons();
  Future<CouponModel> createCoupon(CouponModel coupon);
  Future<CouponModel> updateCoupon(CouponModel coupon);
  Future<bool> deleteCoupon(String id);
  Future<CouponModel?> validateCoupon(String code);
}

class CouponRepository implements CouponRepositoryInterface {
  late final CouponRepositoryInterface _dataSource;

  CouponRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('coupons')) {
      log('CouponRepository: Using Supabase');
      _dataSource = _CouponSupabaseDataSource();
    } else {
      log('CouponRepository: Using Dio (legacy)');
      _dataSource = _CouponDioDataSource();
    }
  }

  @override
  Future<List<CouponModel>> getAllCoupons() => _dataSource.getAllCoupons();

  @override
  Future<CouponModel> createCoupon(CouponModel coupon) => _dataSource.createCoupon(coupon);

  @override
  Future<CouponModel> updateCoupon(CouponModel coupon) => _dataSource.updateCoupon(coupon);

  @override
  Future<bool> deleteCoupon(String id) => _dataSource.deleteCoupon(id);

  @override
  Future<CouponModel?> validateCoupon(String code) => _dataSource.validateCoupon(code);

  void enableSupabase() {
    MigrationService.enableSupabase('coupons');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('coupons');
    _initializeDataSource();
  }
}

class _CouponSupabaseDataSource implements CouponRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<CouponModel>> getAllCoupons() async {
    try {
      log('CouponSupabase: Fetching all coupons');
      final response = await _client.from('coupons').select().order('created_at', ascending: false);
      return (response as List).map((json) => _mapSupabaseToCouponModel(json)).toList();
    } catch (e) {
      log('CouponSupabase: Error fetching coupons - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CouponModel> createCoupon(CouponModel coupon) async {
    try {
      log('CouponSupabase: Creating coupon');
      final data = {
        'code': coupon.couponCode,
        'name': coupon.couponCode, // Using code as name as it's not in the model but in schema
        'discount_type': coupon.type,
        'discount_value': coupon.amount,
        'min_purchase': coupon.minimumAmount,
        'end_date': coupon.expiredDate,
        'start_date': DateTime.now().toIso8601String(),
        'usage_limit': coupon.quantity,
        'usage_count': 0,
        'status': true,
      };
      final response = await _client.from('coupons').insert(data).select().single();
      return _mapSupabaseToCouponModel(response);
    } catch (e) {
      log('CouponSupabase: Error creating coupon - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CouponModel> updateCoupon(CouponModel coupon) async {
    try {
      log('CouponSupabase: Updating coupon');
      final data = {
        'code': coupon.couponCode,
        'discount_type': coupon.type,
        'discount_value': coupon.amount,
        'min_purchase': coupon.minimumAmount,
        'end_date': coupon.expiredDate,
        'usage_limit': coupon.quantity,
      };
      final response = await _client.from('coupons').update(data).eq('id', coupon.id).select().single();
      return _mapSupabaseToCouponModel(response);
    } catch (e) {
      log('CouponSupabase: Error updating coupon - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteCoupon(String id) async {
    try {
      log('CouponSupabase: Deleting coupon');
      await _client.from('coupons').delete().eq('id', id);
      return true;
    } catch (e) {
      log('CouponSupabase: Error deleting coupon - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CouponModel?> validateCoupon(String code) async {
    try {
      log('CouponSupabase: Validating coupon $code');
      final response = await _client
          .from('coupons')
          .select()
          .eq('code', code)
          .eq('status', true)
          .gte('end_date', DateTime.now().toIso8601String())
          .maybeSingle();

      if (response == null) return null;

      final model = _mapSupabaseToCouponModel(response);
      if (model.available > 0) {
        return model;
      }
      return null;
    } catch (e) {
      log('CouponSupabase: Error validating coupon - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  CouponModel _mapSupabaseToCouponModel(Map<String, dynamic> json) {
    final int limit = json['usage_limit'] ?? 0;
    final int count = json['usage_count'] ?? 0;

    return CouponModel(
      id: json['id'],
      couponCode: json['code'],
      type: json['discount_type'],
      amount: (json['discount_value'] as num).toDouble(),
      minimumAmount: (json['min_purchase'] as num).toDouble(),
      quantity: limit,
      available: limit - count,
      expiredDate: json['end_date'],
      status: json['is_active'] ?? true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      version: 0,
    );
  }
}

class _CouponDioDataSource implements CouponRepositoryInterface {
  @override
  Future<List<CouponModel>> getAllCoupons() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllCoupons);
      if (response.statusCode == 200) {
        final model = CouponResponse.fromJson(response.data);
        return model.data.coupons;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<CouponModel> createCoupon(CouponModel coupon) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addCoupon,
        data: coupon.toJson()..remove('_id'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CouponModel.fromJson(response.data['data']['coupon']);
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<CouponModel> updateCoupon(CouponModel coupon) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateCoupon(coupon.id),
        data: coupon.toJson(),
      );
      if (response.statusCode == 200) {
        return CouponModel.fromJson(response.data['data']['coupon']);
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteCoupon(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteCoupon(id));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<CouponModel?> validateCoupon(String code) async {
    try {
      final response = await DioHelper.postData(
        url: '/api/admin/coupon/apply',
        data: {'code': code},
      );
      if (response.statusCode == 200) {
        return CouponModel.fromJson(response.data['data']['coupon']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

