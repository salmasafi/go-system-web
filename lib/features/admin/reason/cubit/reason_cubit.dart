import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/reason_model.dart';
import 'reason_state.dart';

class ReasonCubit extends Cubit<ReasonState> {
  ReasonCubit() : super(ReasonInitial());

  static List<ReasonModel> reasons = [];

  String _extractErrorMessage(dynamic errorOrResponse) {
    if (errorOrResponse is Map<String, dynamic>) {
      return errorOrResponse['message']?.toString() ?? 'Unknown error occurred';
    } else if (errorOrResponse is Response) {
      final data = errorOrResponse.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            '${LocaleKeys.server_error.tr()} ${errorOrResponse.statusCode}';
      }
      return '${LocaleKeys.server_error.tr()} ${errorOrResponse.statusCode}';
    }
    return ErrorHandler.handleError(errorOrResponse);
  }
Future<void> getReasons() async {
  emit(GetReasonsLoading());
  try {
    final response = await DioHelper.getData(url: EndPoint.getAllreasons);
    log('Response status: ${response.statusCode}');
    log('Response data: ${response.data}');
    
    if (response.statusCode == 200) {
      final model = ReasonResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (model.success == true) {
        log('Number of reasons: ${model.data.reasons.length}');
        // Log each reason to check for nulls
        for (var reason in model.data.reasons) {
          log('Reason: ${reason.id} - ${reason.reason} - ${reason.createdAt}');
        }
        
        reasons = model.data.reasons;
        emit(GetReasonsSuccess(model.data));
      } else {
        final errorMessage = model.data.message;
        log('Error from API: $errorMessage');
        emit(GetReasonsError(errorMessage));
      }
    } else {
      final errorMessage = _extractErrorMessage(response);
      log('HTTP Error: $errorMessage');
      emit(GetReasonsError(errorMessage));
    }
  } catch (e) {
    final errorMessage = _extractErrorMessage(e);
    log('Exception: $errorMessage');
    emit(GetReasonsError(errorMessage));
  }
}

  Future<void> createReason({
    required String reason,
  }) async {
    emit(CreateReasonLoading());
    try {
      final data = {"reason": reason};

      final response = await DioHelper.postData(
        url: EndPoint.addreason,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateReasonSuccess(LocaleKeys.reason_created_success.tr()));
        await getReasons(); // Refresh list
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(CreateReasonError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(CreateReasonError(errorMessage));
    }
  }

  Future<void> updateReason({
    required String reasonId,
    required String reason,
  }) async {
    emit(UpdateReasonLoading());
    try {
      final data = <String, dynamic>{
        'reason': reason,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updatereason(reasonId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateReasonSuccess(LocaleKeys.reason_updated_success.tr()));
        await getReasons(); // Refresh list
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(UpdateReasonError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(UpdateReasonError(errorMessage));
    }
  }

  Future<void> deleteReason(String reasonId) async {
    emit(DeleteReasonLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deletereason(reasonId),
      );

      if (response.statusCode == 200) {
        reasons.removeWhere((reason) => reason.id == reasonId);
        emit(DeleteReasonSuccess(LocaleKeys.reason_deleted_success.tr()));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(DeleteReasonError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(DeleteReasonError(errorMessage));
    }
  }
}