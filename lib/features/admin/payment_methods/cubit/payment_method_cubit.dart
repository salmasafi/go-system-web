import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/payment_method_model.dart';
import 'payment_method_state.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  PaymentMethodCubit() : super(PaymentMethodInitial());

  List<PaymentMethodModel> allPaymentMethods = [];

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

  Future<void> getPaymentMethods() async {
    emit(GetPaymentMethodsLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getPaymentMethods);
      log(response.data.toString());
      if (response.statusCode == 200) {
        final model = PaymentMethodResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (model.success == true) {
          allPaymentMethods = model.data.paymentMethods;
          emit(GetPaymentMethodsSuccess(allPaymentMethods));
        } else {
          final errorMessage = model.data.message;
          emit(GetPaymentMethodsError(errorMessage));
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(GetPaymentMethodsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(GetPaymentMethodsError(errorMessage));
    }
  }

  Future<void> createPaymentMethod({
    required String name,
    required String arName,
    required File? icon,
    required String description,
    required String type,
    required bool isActive,
  }) async {
    emit(CreatePaymentMethodLoading());
    try {
      String? base64Image;
      if (icon != null) {
        base64Image = await _convertFileToBase64(icon);
      }

      final data = {
        "name": name,
        "ar_name": arName,
        'discription': description,
        if (base64Image != null) 'icon': base64Image,
        'isActive': isActive,
        'type': type,
      };

       log("dataaaaaaaaaaaaaaaaa: $data");

      final response = await DioHelper.postData(
        url: EndPoint.createPaymentMethod,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(
          CreatePaymentMethodSuccess('Payment method is created successfully'),
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(CreatePaymentMethodError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(CreatePaymentMethodError(errorMessage));
    }
  }

  Future<void> updatePaymentMethod({
    required String paymentMethodId,
    required String name,
    required String arName,
    required File? icon,
    required String description,
    required String type,
    required bool isActive,
  }) async {
    emit(UpdatePaymentMethodLoading());
    try {
      String? base64Image;
      if (icon != null) {
        base64Image = await _convertFileToBase64(icon);
      }



      final data = <String, dynamic>{
        "name": name,
        "ar_name": arName,
        'discription': description,
        if (base64Image != null) 'icon': base64Image,
        'isActive': isActive,
        'type': type,
      };

      log("dataaaaaaaaaaaaaaaaa: $data");

      final response = await DioHelper.putData(
        url: EndPoint.updatePaymentMethod(paymentMethodId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(
          UpdatePaymentMethodSuccess('Payment method is updated successfully'),
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(UpdatePaymentMethodError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(UpdatePaymentMethodError(errorMessage));
    }
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    emit(DeletePaymentMethodLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deletePaymentMethod(paymentMethodId),
      );

      if (response.statusCode == 200) {
        allPaymentMethods.removeWhere(
          (paymentMethod) => paymentMethod.id == paymentMethodId,
        );
        emit(
          DeletePaymentMethodSuccess('Payment method is deleted successfully'),
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(DeletePaymentMethodError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(DeletePaymentMethodError(errorMessage));
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
