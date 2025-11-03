import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/dio_helper.dart';
import '../../../core/services/endpoints.dart';
import '../../../core/utils/error_handler.dart';
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
    required String icon,
    required String description,
    required String type,
    required bool isActive,
  }) async {
    emit(CreatePaymentMethodLoading());
    try {
      final data = {
        "name": name,
        "ar_name": arName,
        'discription': description,
        'icon': icon,
        'isActive': isActive,
        'type': type,
      };

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
    required String icon,
    required String description,
    required String type,
    required bool isActive,
  }) async {
    emit(UpdatePaymentMethodLoading());
    try {
      final data = <String, dynamic>{
        "name": name,
        "ar_name": arName,
        'discription': description,
        'icon': icon,
        'isActive': isActive,
        'type': type,
      };

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
}
