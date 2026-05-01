import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/redeem_points_model.dart';

abstract class RedeemPointsRepositoryInterface {
  Future<List<RedeemPointsModel>> getRedeemRules();
  Future<RedeemPointsModel> createRedeemRule(RedeemPointsModel rule);
  Future<RedeemPointsModel> updateRedeemRule(RedeemPointsModel rule);
  Future<bool> deleteRedeemRule(String id);
}

class RedeemPointsRepository implements RedeemPointsRepositoryInterface {
  final _RedeemPointsSupabaseDataSource _dataSource = _RedeemPointsSupabaseDataSource();

  @override
  Future<List<RedeemPointsModel>> getRedeemRules() => _dataSource.getRedeemRules();

  @override
  Future<RedeemPointsModel> createRedeemRule(RedeemPointsModel rule) => _dataSource.createRedeemRule(rule);

  @override
  Future<RedeemPointsModel> updateRedeemRule(RedeemPointsModel rule) => _dataSource.updateRedeemRule(rule);

  @override
  Future<bool> deleteRedeemRule(String id) => _dataSource.deleteRedeemRule(id);
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
