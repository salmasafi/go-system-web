import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/points_model.dart';

abstract class PointsRepositoryInterface {
  Future<List<PointsModel>> getPointsRules();
  Future<PointsModel> createPointsRule(PointsModel rule);
  Future<PointsModel> updatePointsRule(PointsModel rule);
  Future<bool> deletePointsRule(String id);
  Future<int> calculateEarnedPoints(double amount);
}

class PointsRepository implements PointsRepositoryInterface {
  late final PointsRepositoryInterface _dataSource;

  PointsRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('points')) {
      log('PointsRepository: Using Supabase');
      _dataSource = _PointsSupabaseDataSource();
    } else {
      log('PointsRepository: Using Dio (legacy)');
      _dataSource = _PointsDioDataSource();
    }
  }

  @override
  Future<List<PointsModel>> getPointsRules() => _dataSource.getPointsRules();

  @override
  Future<PointsModel> createPointsRule(PointsModel rule) => _dataSource.createPointsRule(rule);

  @override
  Future<PointsModel> updatePointsRule(PointsModel rule) => _dataSource.updatePointsRule(rule);

  @override
  Future<bool> deletePointsRule(String id) => _dataSource.deletePointsRule(id);

  @override
  Future<int> calculateEarnedPoints(double amount) => _dataSource.calculateEarnedPoints(amount);

  void enableSupabase() {
    MigrationService.enableSupabase('points');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('points');
    _initializeDataSource();
  }
}

class _PointsSupabaseDataSource implements PointsRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<PointsModel>> getPointsRules() async {
    try {
      log('PointsSupabase: Fetching all points rules');
      final response = await _client.from('points').select().order('amount');
      return (response as List).map((json) => PointsModel.fromJson(json)).toList();
    } catch (e) {
      log('PointsSupabase: Error fetching points rules - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PointsModel> createPointsRule(PointsModel rule) async {
    try {
      log('PointsSupabase: Creating points rule');
      final data = {
        'amount': rule.amount,
        'points': rule.points,
      };
      final response = await _client.from('points').insert(data).select().single();
      return PointsModel.fromJson(response);
    } catch (e) {
      log('PointsSupabase: Error creating points rule - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PointsModel> updatePointsRule(PointsModel rule) async {
    try {
      log('PointsSupabase: Updating points rule');
      final data = {
        'amount': rule.amount,
        'points': rule.points,
      };
      final response = await _client.from('points').update(data).eq('id', rule.id).select().single();
      return PointsModel.fromJson(response);
    } catch (e) {
      log('PointsSupabase: Error updating points rule - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deletePointsRule(String id) async {
    try {
      log('PointsSupabase: Deleting points rule');
      await _client.from('points').delete().eq('id', id);
      return true;
    } catch (e) {
      log('PointsSupabase: Error deleting points rule - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<int> calculateEarnedPoints(double amount) async {
    try {
      log('PointsSupabase: Calculating earned points for amount $amount');
      // Simulated calculation or RPC
      final rules = await getPointsRules();
      if (rules.isEmpty) return 0;
      // Simple logic: find best rule
      for (var rule in rules.reversed) {
        if (amount >= rule.amount) {
          return rule.points;
        }
      }
      return 0;
    } catch (e) {
      log('PointsSupabase: Error calculating points - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

class _PointsDioDataSource implements PointsRepositoryInterface {
  @override
  Future<List<PointsModel>> getPointsRules() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getPoints);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = PointsResponse.fromJson(response.data);
        return data.data.points;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<PointsModel> createPointsRule(PointsModel rule) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addPoint,
        data: {
          'amount': rule.amount,
          'points': rule.points,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PointsModel.fromJson(response.data['data']);
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<PointsModel> updatePointsRule(PointsModel rule) async {
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.updatePoint}/${rule.id}',
        data: {
          'amount': rule.amount,
          'points': rule.points,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PointsModel.fromJson(response.data['data']);
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deletePointsRule(String id) async {
    try {
      final response = await DioHelper.deleteData(url: '${EndPoint.deletePoint}/$id');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<int> calculateEarnedPoints(double amount) async {
    // Legacy API might not have this as a separate call, or it might be client-side
    return 0;
  }
}
