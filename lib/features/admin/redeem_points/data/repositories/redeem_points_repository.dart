import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/redeem_points_model.dart';

abstract class RedeemPointsRepositoryInterface {
  Future<List<RedeemPointsModel>> getRedeemRules();
  Future<RedeemPointsModel> createRedeemRule(RedeemPointsModel rule);
  Future<RedeemPointsModel> updateRedeemRule(RedeemPointsModel rule);
  Future<bool> deleteRedeemRule(String id);
}

class RedeemPointsRepository implements RedeemPointsRepositoryInterface {
  late final RedeemPointsRepositoryInterface _dataSource;

  RedeemPointsRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('redeem_points')) {
      log('RedeemPointsRepository: Using Supabase');
      _dataSource = _RedeemPointsSupabaseDataSource();
    } else {
      log('RedeemPointsRepository: Using Dio (legacy)');
      _dataSource = _RedeemPointsDioDataSource();
    }
  }

  @override
  Future<List<RedeemPointsModel>> getRedeemRules() => _dataSource.getRedeemRules();

  @override
  Future<RedeemPointsModel> createRedeemRule(RedeemPointsModel rule) => _dataSource.createRedeemRule(rule);

  @override
  Future<RedeemPointsModel> updateRedeemRule(RedeemPointsModel rule) => _dataSource.updateRedeemRule(rule);

  @override
  Future<bool> deleteRedeemRule(String id) => _dataSource.deleteRedeemRule(id);

  void enableSupabase() {
    MigrationService.enableSupabase('redeem_points');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('redeem_points');
    _initializeDataSource();
  }
}

class _RedeemPointsSupabaseDataSource implements RedeemPointsRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<RedeemPointsModel>> getRedeemRules() async {
    try {
      log('RedeemPointsSupabase: Fetching all redeem rules');
      final response = await _client.from('redeem_rules').select().order('points');
      return (response as List).map((json) => RedeemPointsModel.fromJson(json)).toList();
    } catch (e) {
      log('RedeemPointsSupabase: Error fetching redeem rules - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<RedeemPointsModel> createRedeemRule(RedeemPointsModel rule) async {
    try {
      log('RedeemPointsSupabase: Creating redeem rule');
      final data = {
        'amount': rule.amount,
        'points': rule.points,
      };
      final response = await _client.from('redeem_rules').insert(data).select().single();
      return RedeemPointsModel.fromJson(response);
    } catch (e) {
      log('RedeemPointsSupabase: Error creating redeem rule - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<RedeemPointsModel> updateRedeemRule(RedeemPointsModel rule) async {
    try {
      log('RedeemPointsSupabase: Updating redeem rule');
      final data = {
        'amount': rule.amount,
        'points': rule.points,
      };
      final response = await _client.from('redeem_rules').update(data).eq('id', rule.id).select().single();
      return RedeemPointsModel.fromJson(response);
    } catch (e) {
      log('RedeemPointsSupabase: Error updating redeem rule - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteRedeemRule(String id) async {
    try {
      log('RedeemPointsSupabase: Deleting redeem rule');
      await _client.from('redeem_rules').delete().eq('id', id);
      return true;
    } catch (e) {
      log('RedeemPointsSupabase: Error deleting redeem rule - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

class _RedeemPointsDioDataSource implements RedeemPointsRepositoryInterface {
  @override
  Future<List<RedeemPointsModel>> getRedeemRules() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.redeemPoints);
      if (response.statusCode == 200) {
        final list = response.data['data']['redeemPoints'] as List;
        return list.map((e) => RedeemPointsModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<RedeemPointsModel> createRedeemRule(RedeemPointsModel rule) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.redeemPoints,
        data: rule.toJson()..remove('_id'),
      );
      return RedeemPointsModel.fromJson(response.data['data']['redeemPoint']);
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<RedeemPointsModel> updateRedeemRule(RedeemPointsModel rule) async {
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.redeemPoints}/${rule.id}',
        data: rule.toJson(),
      );
      return RedeemPointsModel.fromJson(response.data['data']['redeemPoint']);
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteRedeemRule(String id) async {
    try {
      final response = await DioHelper.deleteData(url: '${EndPoint.redeemPoints}/$id');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
