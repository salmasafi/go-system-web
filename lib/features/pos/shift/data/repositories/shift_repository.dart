// lib/features/pos/shift/data/repositories/shift_repository.dart

import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/shift_model.dart';
import '../../model/cashier_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseShiftModel {
  final String id;
  final String? reference;
  final String cashierId;
  final String? cashierManId;
  final DateTime startTime;
  final DateTime? endTime;
  final double openingBalance;
  final double totalSaleAmount;
  final double netCashInDrawer;
  final double totalExpenses;
  final String status; // open, closed
  final String? currencyId;
  final DateTime createdAt;

  SupabaseShiftModel({
    required this.id,
    this.reference,
    required this.cashierId,
    this.cashierManId,
    required this.startTime,
    this.endTime,
    required this.openingBalance,
    required this.totalSaleAmount,
    required this.netCashInDrawer,
    required this.totalExpenses,
    required this.status,
    this.currencyId,
    required this.createdAt,
  });

  factory SupabaseShiftModel.fromJson(Map<String, dynamic> json) {
    return SupabaseShiftModel(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String?,
      cashierId: json['cashier_id'] as String? ?? '',
      cashierManId: json['cashierman_id'] as String?,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      openingBalance: (json['opening_balance'] as num?)?.toDouble() ?? 0.0,
      totalSaleAmount: (json['total_sale_amount'] as num?)?.toDouble() ?? 0.0,
      netCashInDrawer: (json['net_cash_in_drawer'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'open',
      currencyId: json['currency_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  ShiftModel toLegacyModel() {
    return ShiftModel(
      id: id,
      startTime: startTime,
      status: status,
      cashierId: cashierId,
      cashierManId: cashierManId ?? '',
      totalSaleAmount: totalSaleAmount,
      netCashInDrawer: netCashInDrawer,
      totalExpenses: totalExpenses,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class ShiftRepositoryInterface {
  Future<List<CashierModel>> getCashiers();
  Future<SupabaseShiftModel> startShift({
    required String cashierId,
    required double openingAmount,
    String? note,
  });
  Future<SupabaseShiftModel> endShift({
    required String shiftId,
    required double actualAmount,
    String? note,
  });
  Future<SupabaseShiftModel?> getActiveShiftByCashier(String cashierId);
  Future<SupabaseShiftModel?> getActiveShift();
  Future<SupabaseShiftModel?> getShiftById(String shiftId);
}

// ─────────────────────────────────────────────
// Repository Implementation
// ─────────────────────────────────────────────

class ShiftRepository implements ShiftRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'shifts';

  @override
  Future<List<CashierModel>> getCashiers() async {
    try {
      log('ShiftRepository: Fetching all active cashiers directly');

      final cashiersResponse = await _client
          .from('cashiers')
          .select('*, warehouse:warehouse_id (*)')
          .eq('status', true)
          .order('name');

      // Source of truth: cashier is busy only if it has an open shift in shifts table
      final openShiftsResponse = await _client
          .from('shifts')
          .select('cashier_id')
          .eq('status', 'open');

      final busyIds = (openShiftsResponse as List)
          .map((s) => s['cashier_id'] as String)
          .toSet();

      return (cashiersResponse as List).map((json) {
        final isBusy = busyIds.contains(json['id'] as String);
        return CashierModel.fromJson({...json, 'cashier_active': isBusy});
      }).toList();
    } catch (e) {
      log('ShiftRepository: Error fetching cashiers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseShiftModel> startShift({
    required String cashierId,
    required double openingAmount,
    String? note,
  }) async {
    try {
      log('ShiftRepository: Starting shift for cashier $cashierId');

      // Check for active shift
      final active = await getActiveShiftByCashier(cashierId);
      if (active != null) {
        throw Exception('Cashier already has an active shift');
      }

      final userId = _client.auth.currentUser?.id;

      final response = await _client.from(_table).insert({
        'cashier_id': cashierId,
        'cashierman_id': userId,
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'opening_balance': openingAmount,
        'status': 'open',
      }).select().single();

      // Update cashier status
      await _client.from('cashiers').update({'cashier_active': true}).eq('id', cashierId);

      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftRepository: Error starting shift - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseShiftModel> endShift({
    required String shiftId,
    required double actualAmount,
    String? note,
  }) async {
    try {
      log('ShiftRepository: Ending shift $shiftId');

      final shift = await getShiftById(shiftId);
      if (shift == null) throw Exception('Shift not found');

      final response = await _client.from(_table).update({
        'end_time': DateTime.now().toUtc().toIso8601String(),
        'net_cash_in_drawer': actualAmount,
        'status': 'closed',
      }).eq('id', shiftId).select().single();

      // Update cashier status
      await _client.from('cashiers').update({'cashier_active': false}).eq('id', shift.cashierId);

      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftRepository: Error ending shift - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseShiftModel?> getActiveShiftByCashier(String cashierId) async {
    try {
      log('ShiftRepository: Fetching active shift for $cashierId');
      final response = await _client
          .from(_table)
          .select()
          .eq('cashier_id', cashierId)
          .eq('status', 'open')
          .maybeSingle();

      if (response == null) return null;
      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftRepository: Error fetching active shift - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  Future<SupabaseShiftModel?> getMyActiveShift() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      log('ShiftRepository: Fetching active shift for current user $userId');
      final response = await _client
          .from(_table)
          .select()
          .eq('cashierman_id', userId)
          .eq('status', 'open')
          .maybeSingle();

      if (response == null) return null;
      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftRepository: Error fetching my active shift - $e');
      return null;
    }
  }

  Future<CashierModel?> getCashierById(String cashierId) async {
    try {
      log('ShiftRepository: Fetching cashier $cashierId');
      final response = await _client
          .from('cashiers')
          .select('*, warehouse:warehouse_id (*)')
          .eq('id', cashierId)
          .maybeSingle();

      if (response == null) return null;
      return CashierModel.fromJson(response);
    } catch (e) {
      log('ShiftRepository: Error fetching cashier - $e');
      return null;
    }
  }

  @override
  Future<SupabaseShiftModel?> getActiveShift() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    // We need to find if this user is assigned to a cashier that has an active shift
    final cashierUser = await _client
        .from('cashier_users')
        .select('cashier_id')
        .eq('admin_id', userId)
        .maybeSingle();
    
    if (cashierUser == null) return null;
    return getActiveShiftByCashier(cashierUser['cashier_id']);
  }

  @override
  Future<SupabaseShiftModel?> getShiftById(String shiftId) async {
    try {
      log('ShiftRepository: Fetching shift $shiftId');
      final response = await _client
          .from(_table)
          .select()
          .eq('id', shiftId)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftRepository: Error fetching shift - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

