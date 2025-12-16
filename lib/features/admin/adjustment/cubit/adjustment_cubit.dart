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
import 'adjustment_state.dart';

class AdjustmentCubit extends Cubit<AdjustmentState> {
  AdjustmentCubit() : super(AdjustmentInitial());

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
      final adjustmentResponse = await DioHelper.getData(url: EndPoint.getAlladjustments); // Assume EndPoint.getAllAdjustments = '/api/admin/adjustment'
      log(adjustmentResponse.data.toString());
      if (adjustmentResponse.statusCode == 200) {
        final adjustmentModel = AdjustmentResponse.fromJson(
          adjustmentResponse.data as Map<String, dynamic>,
        );
        if (adjustmentModel.success == true) {
          // Fetch reasons separately
          final reasonResponse = await DioHelper.getData(url: EndPoint.getAllreasons);
          log(reasonResponse.data.toString());
          if (reasonResponse.statusCode == 200) {
            final reasonModel = ReasonResponse.fromJson(
              reasonResponse.data as Map<String, dynamic>,
            );
            if (reasonModel.success == true) {
              adjustments = adjustmentModel.data.adjustments;
              reasons = reasonModel.data.reasons;
              emit(GetAdjustmentsSuccess(adjustmentModel.data)); // Note: Using adjustment data, but reasons are stored statically
            } else {
              final errorMessage = reasonModel.data.message;
              emit(GetAdjustmentsError(errorMessage));
            }
          } else {
            final errorMessage = _extractErrorMessage(reasonResponse);
            emit(GetAdjustmentsError(errorMessage));
          }
        } else {
          final errorMessage = adjustmentModel.data.message;
          emit(GetAdjustmentsError(errorMessage));
        }
      } else {
        final errorMessage = _extractErrorMessage(adjustmentResponse);
        emit(GetAdjustmentsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(GetAdjustmentsError(errorMessage));
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
       String? base64Image;
      if (image != null) {
        base64Image = await _convertFileToBase64(image);
      }



      final data = {
        "warehouse_id": warehouseId,
        "productId": productId,
        "quantity": int.tryParse(quantity) ?? 0,
        "select_reasonId": reasonId,
        "note": note,
        if (base64Image != null) 'image': base64Image,
      };
      final response = await DioHelper.postData(
        url: EndPoint.addadjustment, // Assume '/api/admin/adjustment'
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateAdjustmentSuccess('Adjustment is created successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(CreateAdjustmentError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(CreateAdjustmentError(errorMessage));
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

        String? base64Image;
      if (image != null) {
        base64Image = await _convertFileToBase64(image);
      }

      final data = <String, dynamic>{
        'warehouse_id': warehouseId,
        "productId": productId,
        "quantity": int.tryParse(quantity) ?? 0,
        "select_reasonId": reasonId,
        "note": note,
        if (base64Image != null) 'image': base64Image,
      };
      final response = await DioHelper.putData(
        url: EndPoint.updateadjustment(adjustmentId), 
        data: data,
      );
      if (response.statusCode == 200) {
        emit(UpdateAdjustmentSuccess('Adjustment updated successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(UpdateAdjustmentError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(UpdateAdjustmentError(errorMessage));
    }
  }

  Future<void> deleteAdjustment(String adjustmentId) async {
    emit(DeleteAdjustmentLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteadjustment(adjustmentId), 
      );
      if (response.statusCode == 200) {
        adjustments.removeWhere((adjustment) => adjustment.id == adjustmentId);
        emit(DeleteAdjustmentSuccess('Adjustment deleted successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(DeleteAdjustmentError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(DeleteAdjustmentError(errorMessage));
    }
  }

  
   Future<String?> _convertFileToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      String? mimeType;
      final ext = imageFile.path.toLowerCase().split('.').last;
      if (ext == 'png') {
        mimeType = "image/png";
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = "image/jpeg";
      } else {
        mimeType = "application/octet-stream";
      }

      return "data:$mimeType;base64,${base64Encode(bytes)}";
    } catch (e) {
      log("Error converting image: $e");
      return null;
    }
  }

}