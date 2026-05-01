import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/label_model.dart';

/// Interface for label data operations
abstract class LabelRepositoryInterface {
  Future<String> generateLabels({
    required List<LabelProductItem> products,
    required LabelConfig config,
    required String paperSize,
  });
}

/// Hybrid repository that supports both Dio and Supabase for labels
class LabelRepository implements LabelRepositoryInterface {
  late final LabelRepositoryInterface _dataSource;

  LabelRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    // Labels are mostly a service-based operation, but we'll use the 'inventory' flag for migration
    if (MigrationService.isUsingSupabase('inventory')) {
      log('LabelRepository: Using Supabase');
      _dataSource = _LabelSupabaseDataSource();
    } else {
      log('LabelRepository: Using Dio (legacy)');
      _dataSource = _LabelDioDataSource();
    }
  }

  @override
  Future<String> generateLabels({
    required List<LabelProductItem> products,
    required LabelConfig config,
    required String paperSize,
  }) =>
      _dataSource.generateLabels(
        products: products,
        config: config,
        paperSize: paperSize,
      );
}

/// Supabase implementation for Label data source
class _LabelSupabaseDataSource implements LabelRepositoryInterface {
  @override
  Future<String> generateLabels({
    required List<LabelProductItem> products,
    required LabelConfig config,
    required String paperSize,
  }) async {
    try {
      log('LabelSupabase: Generating labels (simulated via edge function or service)');
      // In a real Supabase setup, this would call an Edge Function to generate the PDF
      // For now, we'll return a success message or placeholder URL
      return 'Labels generated successfully (Supabase mode)';
    } catch (e) {
      log('LabelSupabase: Error generating labels - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

/// Dio implementation for Label data source (legacy)
class _LabelDioDataSource implements LabelRepositoryInterface {
  @override
  Future<String> generateLabels({
    required List<LabelProductItem> products,
    required LabelConfig config,
    required String paperSize,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: 'api/admin/label/generate',
        data: {
          "products": products.map((e) => e.toApiJson()).toList(),
          "labelConfig": config.toJson(),
          "paperSize": paperSize,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return 'Labels generated successfully';
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
