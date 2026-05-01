import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/popup/model/popup_model.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/generated/locale_keys.g.dart';

import 'package:systego/features/admin/popup/data/repositories/popup_repository.dart';

part 'popup_state.dart';

class PopupCubit extends Cubit<PopupState> {
  final PopupRepository _repository;
  PopupCubit(this._repository) : super(PopupInitial());

  List<PopupModel> allPopups = [];

  Future<void> getAllPopups() async {
    emit(GetPopupsLoading());
    try {
      final popups = await _repository.getAllPopups();
      allPopups = popups;
      emit(GetPopupsSuccess(popups));
    } catch (e) {
      emit(GetPopupsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addPopup({
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    required File? image,
  }) async {
    emit(CreatePopupLoading());
    try {
      await _repository.createPopup(
        titleAr: titleAr,
        titleEn: titleEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        link: link,
        imagePath: image?.path,
      );
      emit(CreatePopupSuccess(LocaleKeys.popup_created_success.tr()));
      getAllPopups();
    } catch (e) {
      emit(CreatePopupError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePopup({
    required String popupId,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    required File? image,
  }) async {
    emit(UpdatePopupLoading());
    try {
      await _repository.updatePopup(
        popupId: popupId,
        titleAr: titleAr,
        titleEn: titleEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        link: link,
        imagePath: image?.path,
      );
      emit(UpdatePopupSuccess(LocaleKeys.popup_updated_success.tr()));
      getAllPopups();
    } catch (e) {
      emit(UpdatePopupError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deletePopup(String popupId) async {
    emit(DeletePopupLoading());
    try {
      await _repository.deletePopup(popupId);
      allPopups.removeWhere((popup) => popup.id == popupId);
      emit(DeletePopupSuccess(LocaleKeys.popup_deleted_success.tr()));
    } catch (e) {
      emit(DeletePopupError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
