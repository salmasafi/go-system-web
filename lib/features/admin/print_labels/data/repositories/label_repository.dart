import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/label_model.dart';

/// Interface for label data operations
abstract class LabelRepositoryInterface {
  Future<String> generateLabels({
    required List<LabelProductItem> products,
    required LabelConfig config,
    required String paperSize,
  });
}

/// Repository implementation using Supabase for labels
class LabelRepository implements LabelRepositoryInterface {
  final _LabelSupabaseDataSource _dataSource = _LabelSupabaseDataSource();

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

