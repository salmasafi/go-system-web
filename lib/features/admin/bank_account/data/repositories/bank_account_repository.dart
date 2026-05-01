import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/bank_account_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseBankAccountModel {
  final String id;
  final String name;
  final String? accountNumber;
  final String? bankName;
  final String? branch;
  final String accountType; // checking, savings, cash, credit
  final String currency;
  final double openingBalance;
  final double currentBalance;
  final bool isActive;
  final bool isDefault;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseBankAccountModel({
    required this.id,
    required this.name,
    this.accountNumber,
    this.bankName,
    this.branch,
    required this.accountType,
    required this.currency,
    required this.openingBalance,
    required this.currentBalance,
    required this.isActive,
    required this.isDefault,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupabaseBankAccountModel.fromJson(Map<String, dynamic> json) {
    return SupabaseBankAccountModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      accountNumber: json['account_number'] as String?,
      bankName: json['bank_name'] as String?,
      branch: json['branch'] as String?,
      accountType: json['account_type'] as String? ?? 'checking',
      currency: json['currency'] as String? ?? 'SAR',
      openingBalance: (json['opening_balance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      isDefault: json['is_default'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  BankAccountModel toLegacyModel() {
    return BankAccountModel(
      id: id,
      name: name,
      wareHouseId: '', // Bank accounts in new schema might not be tied to warehouse
      image: '',
      status: isActive,
      inPos: accountType == 'cash',
      description: notes ?? '',
      balance: currentBalance,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
      version: 0,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class BankAccountRepositoryInterface {
  Future<List<SupabaseBankAccountModel>> getAllBankAccounts();
  Future<SupabaseBankAccountModel?> getBankAccountById(String id);
  Future<SupabaseBankAccountModel> createBankAccount({
    required String name,
    required double balance,
    required bool status,
    required bool inPos,
    required String description,
    required String wareHouseId,
    String? imagePath,
  });
  Future<SupabaseBankAccountModel> updateBankAccount({
    required String id,
    required String name,
    required double balance,
    required bool status,
    required bool inPos,
    required String description,
    required String wareHouseId,
    String? imagePath,
  });
  Future<void> deleteBankAccount(String id);
  Future<void> selectBankAccount(String id);
  Future<bool> updateBankAccountBalance(String accountId, double amount);
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

/// Bank account repository using Supabase as the primary data source.
class BankAccountRepository implements BankAccountRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'bank_accounts';

  @override
  Future<List<SupabaseBankAccountModel>> getAllBankAccounts() async {
    try {
      log('BankAccountRepository: Fetching all bank accounts');
      final response = await _client
          .from(_table)
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) =>
              SupabaseBankAccountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('BankAccountRepository: Error fetching bank accounts - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseBankAccountModel?> getBankAccountById(String id) async {
    try {
      log('BankAccountRepository: Fetching bank account $id');
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseBankAccountModel.fromJson(response);
    } catch (e) {
      log('BankAccountRepository: Error fetching bank account - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseBankAccountModel> createBankAccount({
    required String name,
    required double balance,
    required bool status,
    required bool inPos,
    required String description,
    required String wareHouseId,
    String? imagePath,
  }) async {
    try {
      log('BankAccountRepository: Creating bank account $name');

      String? imageUrl;
      if (imagePath != null) {
        final file = File(imagePath);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _client.storage.from('bank_accounts').upload(fileName, file);
        imageUrl = _client.storage.from('bank_accounts').getPublicUrl(fileName);
      }

      final response = await _client.from(_table).insert({
        'name': name,
        'opening_balance': balance,
        'current_balance': balance,
        'is_active': status,
        'account_type': inPos ? 'cash' : 'checking',
        'notes': description,
        'warehouse_id': wareHouseId,
        'image_url': imageUrl,
      }).select().single();

      return SupabaseBankAccountModel.fromJson(response);
    } catch (e) {
      log('BankAccountRepository: Error creating bank account - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseBankAccountModel> updateBankAccount({
    required String id,
    required String name,
    required double balance,
    required bool status,
    required bool inPos,
    required String description,
    required String wareHouseId,
    String? imagePath,
  }) async {
    try {
      log('BankAccountRepository: Updating bank account $id');

      String? imageUrl;
      if (imagePath != null) {
        final file = File(imagePath);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _client.storage.from('bank_accounts').upload(fileName, file);
        imageUrl = _client.storage.from('bank_accounts').getPublicUrl(fileName);
      }

      final updateData = {
        'name': name,
        'opening_balance': balance,
        'is_active': status,
        'account_type': inPos ? 'cash' : 'checking',
        'notes': description,
        'warehouse_id': wareHouseId,
      };

      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }

      final response = await _client
          .from(_table)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return SupabaseBankAccountModel.fromJson(response);
    } catch (e) {
      log('BankAccountRepository: Error updating bank account - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    try {
      log('BankAccountRepository: Deleting bank account $id');
      await _client.from(_table).delete().eq('id', id);
    } catch (e) {
      log('BankAccountRepository: Error deleting bank account - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> selectBankAccount(String id) async {
    try {
      log('BankAccountRepository: Setting default bank account $id');
      
      // Remove default from all others
      await _client.from(_table).update({'is_default': false});
      
      // Set default for this one
      await _client.from(_table).update({'is_default': true}).eq('id', id);
    } catch (e) {
      log('BankAccountRepository: Error selecting default bank account - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> updateBankAccountBalance(String accountId, double amount) async {
    try {
      log('BankAccountRepository: Updating balance for $accountId by $amount');
      
      // Fetch current balance
      final account = await getBankAccountById(accountId);
      if (account == null) return false;

      final newBalance = account.currentBalance + amount;

      await _client
          .from(_table)
          .update({'current_balance': newBalance})
          .eq('id', accountId);

      return true;
    } catch (e) {
      log('BankAccountRepository: Error updating balance - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

