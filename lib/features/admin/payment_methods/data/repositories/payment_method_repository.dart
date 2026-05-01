import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/payment_method_model.dart';

/// Interface for payment method data operations
abstract class PaymentMethodRepositoryInterface {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<void> createPaymentMethod({
    required String name,
    required String arName,
    required String description,
    required String type,
    required bool isActive,
    String? iconPath,
  });
  Future<void> updatePaymentMethod({
    required String paymentMethodId,
    required String name,
    required String arName,
    required String description,
    required String type,
    required bool isActive,
    String? iconPath,
  });
  Future<void> deletePaymentMethod(String paymentMethodId);
}

/// Repository implementation using Supabase for payment methods
class PaymentMethodRepository implements PaymentMethodRepositoryInterface {
  final _PaymentMethodSupabaseDataSource _dataSource = _PaymentMethodSupabaseDataSource();

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() => _dataSource.getPaymentMethods();

  @override
  Future<void> createPaymentMethod({
    required String name,
    required String arName,
    required String description,
    required String type,
    required bool isActive,
    String? iconPath,
  }) => _dataSource.createPaymentMethod(
        name: name,
        arName: arName,
        description: description,
        type: type,
        isActive: isActive,
        iconPath: iconPath,
      );

  @override
  Future<void> updatePaymentMethod({
    required String paymentMethodId,
    required String name,
    required String arName,
    required String description,
    required String type,
    required bool isActive,
    String? iconPath,
  }) => _dataSource.updatePaymentMethod(
        paymentMethodId: paymentMethodId,
        name: name,
        arName: arName,
        description: description,
        type: type,
        isActive: isActive,
        iconPath: iconPath,
      );

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) => _dataSource.deletePaymentMethod(paymentMethodId);
}

/// Supabase implementation for PaymentMethod data source
class _PaymentMethodSupabaseDataSource implements PaymentMethodRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'payment_methods';

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      log('PaymentMethodSupabase: Fetching all payment methods');
      final response = await _client.from(_table).select().order('name');
      return (response as List)
          .map((json) => _mapSupabaseToPaymentMethodModel(json))
          .toList();
    } catch (e) {
      log('PaymentMethodSupabase: Error fetching payment methods - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createPaymentMethod({
    required String name,
    required String arName,
    required String description,
    required String type,
    required bool isActive,
    String? iconPath,
  }) async {
    try {
      log('PaymentMethodSupabase: Creating payment method: $name');

      String? iconUrl;
      if (iconPath != null) {
        final file = File(iconPath);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _client.storage.from('payment_icons').upload(fileName, file);
        iconUrl = _client.storage.from('payment_icons').getPublicUrl(fileName);
      }

      await _client.from(_table).insert({
        'name': name,
        'ar_name': arName,
        'description': description,
        'type': type,
        'is_active': isActive,
        'icon_url': iconUrl,
      });
    } catch (e) {
      log('PaymentMethodSupabase: Error creating payment method - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updatePaymentMethod({
    required String paymentMethodId,
    required String name,
    required String arName,
    required String description,
    required String type,
    required bool isActive,
    String? iconPath,
  }) async {
    try {
      log('PaymentMethodSupabase: Updating payment method: $paymentMethodId');

      String? iconUrl;
      if (iconPath != null) {
        final file = File(iconPath);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _client.storage.from('payment_icons').upload(fileName, file);
        iconUrl = _client.storage.from('payment_icons').getPublicUrl(fileName);
      }

      final updates = {
        'name': name,
        'ar_name': arName,
        'description': description,
        'type': type,
        'is_active': isActive,
      };

      if (iconUrl != null) {
        updates['icon_url'] = iconUrl;
      }

      await _client.from(_table).update(updates).eq('id', paymentMethodId);
    } catch (e) {
      log('PaymentMethodSupabase: Error updating payment method - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      log('PaymentMethodSupabase: Deleting payment method: $paymentMethodId');
      await _client.from(_table).delete().eq('id', paymentMethodId);
    } catch (e) {
      log('PaymentMethodSupabase: Error deleting payment method - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  PaymentMethodModel _mapSupabaseToPaymentMethodModel(
    Map<String, dynamic> json,
  ) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      icon: json['icon_url'],
      type: json['type'] ?? '',
      isActive: json['is_active'] ?? true,
      version: json['version'] ?? 1,
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }
}
