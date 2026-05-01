import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/reason_model.dart';
import 'reason_state.dart';

import 'package:GoSystem/features/admin/reason/data/repositories/reason_repository.dart';

class ReasonCubit extends Cubit<ReasonState> {
  final ReasonRepository _repository;
  ReasonCubit(this._repository) : super(ReasonInitial());

  static List<ReasonModel> reasons = [];

  Future<void> getReasons() async {
    emit(GetReasonsLoading());
    try {
      final reasonsList = await _repository.getAllReasons();
      reasons = reasonsList;
      // We wrap the list in a ReasonData object to maintain compatibility with GetReasonsSuccess state
      emit(GetReasonsSuccess(ReasonData(reasons: reasonsList, message: '')));
    } catch (e) {
      emit(GetReasonsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createReason({
    required String reason,
  }) async {
    emit(CreateReasonLoading());
    try {
      await _repository.createReason(reason);
      emit(CreateReasonSuccess(LocaleKeys.reason_created_success.tr()));
      await getReasons();
    } catch (e) {
      emit(CreateReasonError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateReason({
    required String reasonId,
    required String reason,
  }) async {
    emit(UpdateReasonLoading());
    try {
      await _repository.updateReason(reasonId, reason);
      emit(UpdateReasonSuccess(LocaleKeys.reason_updated_success.tr()));
      await getReasons();
    } catch (e) {
      emit(UpdateReasonError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteReason(String reasonId) async {
    emit(DeleteReasonLoading());
    try {
      await _repository.deleteReason(reasonId);
      reasons.removeWhere((reason) => reason.id == reasonId);
      emit(DeleteReasonSuccess(LocaleKeys.reason_deleted_success.tr()));
    } catch (e) {
      emit(DeleteReasonError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

