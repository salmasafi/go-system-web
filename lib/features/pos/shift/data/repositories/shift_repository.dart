import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/shift_model.dart';

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
  final double openingAmount;
  final double expectedAmount;
  final double? actualAmount;
  final double? difference;
  final double totalSales;
  final double totalReturns;
  final double totalDiscounts;
  final double totalExpenses;
  final String status; // open, closed, approved
  final String? openingNote;
  final String? closingNote;
  final DateTime createdAt;

  SupabaseShiftModel({
    required this.id,
    this.reference,
    required this.cashierId,
    this.cashierManId,
    required this.startTime,
    this.endTime,
    required this.openingAmount,
    required this.expectedAmount,
    this.actualAmount,
    this.difference,
    required this.totalSales,
    required this.totalReturns,
    required this.totalDiscounts,
    required this.totalExpenses,
    required this.status,
    this.openingNote,
    this.closingNote,
    required this.createdAt,
  });

  factory SupabaseShiftModel.fromJson(Map<String, dynamic> json) {
    return SupabaseShiftModel(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String?,
      cashierId: json['cashier_id'] as String? ?? '',
      cashierManId: json['cashier_man_id'] as String?,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      openingAmount: (json['opening_amount'] as num?)?.toDouble() ?? 0.0,
      expectedAmount: (json['expected_amount'] as num?)?.toDouble() ?? 0.0,
      actualAmount: (json['actual_amount'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      totalReturns: (json['total_returns'] as num?)?.toDouble() ?? 0.0,
      totalDiscounts: (json['total_discounts'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'open',
      openingNote: json['opening_note'] as String?,
      closingNote: json['closing_note'] as String?,
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
      totalSaleAmount: totalSales,
      netCashInDrawer: actualAmount ?? expectedAmount,
      totalExpenses: totalExpenses,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class ShiftRepositoryInterface {
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
  Future<SupabaseShiftModel?> getShiftById(String shiftId);
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class ShiftRepository implements ShiftRepositoryInterface {
  late final ShiftRepositoryInterface _dataSource;

  ShiftRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('shift')) {
      log('ShiftRepository: Using Supabase');
      _dataSource = _ShiftSupabaseDataSource();
    } else {
      log('ShiftRepository: Using Dio (legacy)');
      _dataSource = _ShiftDioDataSource();
    }
  }

  @override
  Future<SupabaseShiftModel> startShift({
    required String cashierId,
    required double openingAmount,
    String? note,
  }) =>
      _dataSource.startShift(
        cashierId: cashierId,
        openingAmount: openingAmount,
        note: note,
      );

  @override
  Future<SupabaseShiftModel> endShift({
    required String shiftId,
    required double actualAmount,
    String? note,
  }) =>
      _dataSource.endShift(
        shiftId: shiftId,
        actualAmount: actualAmount,
        note: note,
      );

  @override
  Future<SupabaseShiftModel?> getActiveShiftByCashier(String cashierId) =>
      _dataSource.getActiveShiftByCashier(cashierId);

  @override
  Future<SupabaseShiftModel?> getShiftById(String shiftId) =>
      _dataSource.getShiftById(shiftId);

  void enableSupabase() {
    MigrationService.enableSupabase('shift');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('shift');
    _initializeDataSource();
  }
}

// ─────────────────────────────────────────────
// Supabase Implementation
// ─────────────────────────────────────────────

class _ShiftSupabaseDataSource implements ShiftRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'shifts';

  @override
  Future<SupabaseShiftModel> startShift({
    required String cashierId,
    required double openingAmount,
    String? note,
  }) async {
    try {
      log('ShiftSupabase: Starting shift for cashier $cashierId');

      // Check for active shift
      final active = await getActiveShiftByCashier(cashierId);
      if (active != null) {
        throw Exception('Cashier already has an active shift');
      }

      final reference =
          'SHF-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

      final response = await _client.from(_table).insert({
        'reference': reference,
        'cashier_id': cashierId,
        'start_time': DateTime.now().toIso8601String(),
        'opening_amount': openingAmount,
        'expected_amount': openingAmount,
        'status': 'open',
        'opening_note': note,
      }).select().single();

      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftSupabase: Error starting shift - $e');
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
      log('ShiftSupabase: Ending shift $shiftId');

      final shift = await getShiftById(shiftId);
      if (shift == null) throw Exception('Shift not found');

      final expected = shift.openingAmount + shift.totalSales - shift.totalExpenses;
      final diff = actualAmount - expected;

      final response = await _client.from(_table).update({
        'end_time': DateTime.now().toIso8601String(),
        'expected_amount': expected,
        'actual_amount': actualAmount,
        'difference': diff,
        'status': 'closed',
        'closing_note': note,
      }).eq('id', shiftId).select().single();

      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftSupabase: Error ending shift - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseShiftModel?> getActiveShiftByCashier(String cashierId) async {
    try {
      log('ShiftSupabase: Fetching active shift for $cashierId');
      final response = await _client
          .from(_table)
          .select()
          .eq('cashier_id', cashierId)
          .eq('status', 'open')
          .maybeSingle();

      if (response == null) return null;
      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftSupabase: Error fetching active shift - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseShiftModel?> getShiftById(String shiftId) async {
    try {
      log('ShiftSupabase: Fetching shift $shiftId');
      final response = await _client
          .from(_table)
          .select()
          .eq('id', shiftId)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseShiftModel.fromJson(response);
    } catch (e) {
      log('ShiftSupabase: Error fetching shift - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

// ─────────────────────────────────────────────
// Dio (Legacy) Implementation
// ─────────────────────────────────────────────

class _ShiftDioDataSource implements ShiftRepositoryInterface {
  @override
  Future<SupabaseShiftModel> startShift({
    required String cashierId,
    required double openingAmount,
    String? note,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.startShift,
        data: {
          'cashierId': cashierId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data']?['shift'];
        return SupabaseShiftModel(
          id: data?['_id'] ?? '',
          cashierId: cashierId,
          startTime: DateTime.now(),
          openingAmount: openingAmount,
          expectedAmount: openingAmount,
          totalSales: 0,
          totalReturns: 0,
          totalDiscounts: 0,
          totalExpenses: 0,
          status: 'open',
          createdAt: DateTime.now(),
        );
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseShiftModel> endShift({
    required String shiftId,
    required double actualAmount,
    String? note,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.endShift,
        data: {
          'actual_amount': actualAmount,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data']?['shift'];
        return SupabaseShiftModel(
          id: shiftId,
          cashierId: data?['cashier_id'] ?? '',
          startTime: data?['start_time'] != null
              ? DateTime.parse(data['start_time'])
              : DateTime.now(),
          endTime: DateTime.now(),
          openingAmount: 0,
          expectedAmount: 0,
          actualAmount: actualAmount,
          totalSales: 0,
          totalReturns: 0,
          totalDiscounts: 0,
          totalExpenses: 0,
          status: 'closed',
          createdAt: DateTime.now(),
        );
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseShiftModel?> getActiveShiftByCashier(String cashierId) async {
    // Note: Legacy API check for current shift is usually handled via local cache
    // or a specialized endpoint not present in EndPoint. Returning null for now.
    return null;
  }

  @override
  Future<SupabaseShiftModel?> getShiftById(String shiftId) async {
    return null; 
  }
}
