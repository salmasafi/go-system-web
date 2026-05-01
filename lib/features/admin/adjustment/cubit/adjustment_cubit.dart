import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/adjustment/model/adjustment_model.dart';
import 'package:systego/features/admin/reason/model/reason_model.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import 'package:systego/features/admin/adjustment/data/repositories/adjustment_repository.dart';
import 'adjustment_state.dart';

class AdjustmentCubit extends Cubit<AdjustmentState> {
  final AdjustmentRepository _repository;
  AdjustmentCubit(this._repository) : super(AdjustmentInitial());

  static List<AdjustmentModel> adjustments = [];
  static List<ReasonModel> reasons = [];

  String _extractErrorMessage(dynamic errorOrResponse) {
    // Helper to safely extract message, bypassing ErrorHandler issues
    if (errorOrResponse is Map<String, dynamic>) {
      return errorOrResponse['message']?.toString() ?? 'Unknown error occurred';
    } else if (errorOrResponse is Response) {
      final data = errorOrResponse.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            'Server error: ${errorOrResponse.statusCode}';
      }
      return 'Server error: ${errorOrResponse.statusCode}';
    }
    // Fallback to ErrorHandler for non-Dio errors (e.g., network issues)
    return ErrorHandler.handleError(errorOrResponse);
  }

  Future<void> getAdjustments() async {
    emit(GetAdjustmentsLoading());
    try {
      final adjustmentsList = await _repository.getAllAdjustments();
      // For legacy compatibility, we might still need reasons.
      // However, the repository should ideally handle all data.
      // Assuming legacy model compatibility for now.
      adjustments = adjustmentsList.map((e) => e.toLegacyModel()).toList();
      emit(GetAdjustmentsSuccess(AdjustmentData(adjustments: adjustments, message: 'Success')));
    } catch (e) {
      emit(GetAdjustmentsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createAdjustment({
    required String warehouseId,
    required String productId,
    required String quantity,
    required String reasonId,
    required String note,
    required File? image,
  }) async {
    emit(CreateAdjustmentLoading());
    try {
      await _repository.createAdjustment(
        warehouseId: warehouseId,
        type: 'addition', // Default type or inferred from reason
        reason: reasonId,
        items: [
          {'product_id': productId, 'quantity': int.tryParse(quantity) ?? 0}
        ],
        note: note,
        attachmentFile: image,
      );
      emit(CreateAdjustmentSuccess('Adjustment is created successfully'));
    } catch (e) {
      emit(CreateAdjustmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateAdjustment({
    required String adjustmentId,
    required String warehouseId,
    required String productId,
    required String quantity,
    required String reasonId,
    required String note,
    required File? image,
  }) async {
    emit(UpdateAdjustmentLoading());
    try {
      await _repository.updateAdjustment(
        id: adjustmentId,
        warehouseId: warehouseId,
        productId: productId,
        quantity: int.tryParse(quantity) ?? 0,
        reasonId: reasonId,
        note: note,
        imageFile: image,
      );
      emit(UpdateAdjustmentSuccess('Adjustment updated successfully'));
    } catch (e) {
      emit(UpdateAdjustmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteAdjustment(String adjustmentId) async {
    emit(DeleteAdjustmentLoading());
    try {
      final success = await _repository.reverseAdjustment(adjustmentId);
      if (success) {
        adjustments.removeWhere((adjustment) => adjustment.id == adjustmentId);
        emit(DeleteAdjustmentSuccess('Adjustment deleted successfully'));
      } else {
        emit(DeleteAdjustmentError('Failed to delete adjustment'));
      }
    } catch (e) {
      emit(DeleteAdjustmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

