import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/popup/model/popup_model.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'popup_state.dart';

class PopupCubit extends Cubit<PopupState> {
  PopupCubit() : super(PopupInitial());

  List<PopupModel> allPopups = [];

  Future<void> getAllPopups() async {
    emit(GetPopupsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllPopups,
      );

      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = PopupResponse.fromJson(response.data);

        if (model.success) {
          allPopups = model.data.popups;
          emit(GetPopupsSuccess(model.data.popups));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetPopupsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetPopupsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetPopupsError(errorMessage));
    }
  }

Future<void> addPopup({
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    required File? imageAr,
    required File? imageEn,
  }) async {
    emit(CreatePopupLoading());

    try {
      String? base64ImageAr;
      String? base64ImageEn;

      if (imageAr != null) {
        base64ImageAr = await _convertFileToBase64(imageAr);
      }

      if (imageEn != null) {
        base64ImageEn = await _convertFileToBase64(imageEn);
      }

      final data = {
        "title_ar": titleAr,
        "title_En": titleEn,
        "description_ar": descriptionAr,
        "description_En": descriptionEn,
        "link": link,
        if (base64ImageAr != null) "image_ar": base64ImageAr,
        if (base64ImageEn != null) "image_En": base64ImageEn,
      };

      final response = await DioHelper.postData(
        url: EndPoint.addPopup,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreatePopupSuccess("Popup created successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreatePopupError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreatePopupError(errorMessage));
    }
  }



  Future<void> updatePopup({
    required String popupId,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    required File? imageAr,
    required File? imageEn,
  }) async {
    emit(UpdatePopupLoading());
    try {

      String? base64ImageAr;
      String? base64ImageEn;

      if (imageAr != null) {
        base64ImageAr = await _convertFileToBase64(imageAr);
      }

      if (imageEn != null) {
        base64ImageEn = await _convertFileToBase64(imageEn);
      }


      final data = {
        "title_ar": titleAr,
        "title_En": titleEn,
        "description_ar": descriptionAr,
        "description_En": descriptionEn,
        "link": link,
        if (base64ImageAr != null) "image_ar": base64ImageAr,
        if (base64ImageEn != null) "image_En": base64ImageEn,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updatePopup(popupId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdatePopupSuccess("Popup updated successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdatePopupError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdatePopupError(errorMessage));
    }
  }

  Future<void> deletePopup(String popupId) async {
    emit(DeletePopupLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deletePopup(popupId),
      );

      if (response.statusCode == 200) {
        allPopups.removeWhere((popup) => popup.id == popupId);
        emit(DeletePopupSuccess("Popup deleted successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeletePopupError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeletePopupError(errorMessage));
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
