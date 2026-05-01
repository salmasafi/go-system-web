import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/payment_method_model.dart';
import 'dart:io';

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

/// Hybrid repository that supports both Dio and Supabase for payment methods
class PaymentMethodRepository implements PaymentMethodRepositoryInterface {
  late final PaymentMethodRepositoryInterface _dataSource;

  PaymentMethodRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('financial')) {
      log('PaymentMethodRepository: Using Supabase');
      _dataSource = _PaymentMethodSupabaseDataSource();
    } else {
      log('PaymentMethodRepository: Using Dio (legacy)');
      _dataSource = _PaymentMethodDioDataSource();
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() =>
      _dataSource.getPaymentMethods();

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
  Future<void> deletePaymentMethod(String paymentMethodId) =>
      _dataSource.deletePaymentMethod(paymentMethodId);
}

/// Supabase implementation for PaymentMethod data source
class _PaymentMethodSupabaseDataSource
    implements PaymentMethodRepositoryInterface {
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
      createdAt: null,
      updatedAt: null,
    );
  }
}

/// Dio implementation for PaymentMethod data source (legacy)
class _PaymentMethodDioDataSource implements PaymentMethodRepositoryInterface {
  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getPaymentMethods);
      if (response.statusCode == 200) {
        final model = PaymentMethodResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return model.data.paymentMethods;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
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
      final response = await DioHelper.postData(
        url: EndPoint.createPaymentMethod,
        data: {
          "name": name,
          "ar_name": arName,
          'discription': description,
          'isActive': isActive,
          'type': type,
          // Note: Legacy base64 icon conversion would happen here if needed,
          // but for migration we prioritize Supabase path.
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
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
      final response = await DioHelper.putData(
        url: EndPoint.updatePaymentMethod(paymentMethodId),
        data: {
          "name": name,
          "ar_name": arName,
          'discription': description,
          'isActive': isActive,
          'type': type,
        },
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deletePaymentMethod(paymentMethodId),
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
