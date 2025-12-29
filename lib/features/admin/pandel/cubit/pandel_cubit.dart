import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/pandel/model/pandel_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'pandel_state.dart';

class PandelCubit extends Cubit<PandelState> {
  PandelCubit() : super(PandelInitial());

  List<PandelModel> allPandels = [];

  Future<void> getAllPandels() async {
    emit(GetPandelsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllPandels, // You'll need to update this endpoint
      );

      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = PandelResponse.fromJson(response.data);

        if (model.success) {
          allPandels = model.data.pandels;
          emit(GetPandelsSuccess(model.data.pandels));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetPandelsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetPandelsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetPandelsError(errorMessage));
    }
  }

  Future<void> getPandelById(String pandelId) async {
    emit(GetPandelByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPandelById(
          pandelId,
        ), // You'll need to update this endpoint
      );

      if (response.statusCode == 200) {
        final model = PandelResponse.fromJson(response.data);

        if (model.success && model.data.pandels.isNotEmpty) {
          emit(GetPandelByIdSuccess(model.data.pandels.first));
        } else {
          emit(GetPandelByIdError(LocaleKeys.pandel_not_found.tr()));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetPandelByIdError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetPandelByIdError(errorMessage));
    }
  }

  Future<void> addPandel({
    required String name,
    required List<String> productsId,
    required List<File> images,
    required DateTime startDate,
    required DateTime endDate,
    required double price,
  }) async {
    emit(CreatePandelLoading());

    try {
      final List<String> base64Images = [];

      // Convert all images to base64
      for (final image in images) {
        final base64Image = await _convertFileToBase64(image);
        if (base64Image != null) {
          base64Images.add(base64Image);
        }
      }

      final data = {
        "name": name,
        "productsId": productsId,
        "images": base64Images,
        "startdate": startDate.toIso8601String().split('T').first,
        "enddate": endDate.toIso8601String().split('T').first,
        "price": price,
      };

      log(" add pandel ${data}");

      final response = await DioHelper.postData(
        url: EndPoint.addPandel,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreatePandelSuccess(LocaleKeys.pandel_created_success.tr()));
        // Refresh the list after creation
        await getAllPandels();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreatePandelError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreatePandelError(errorMessage));
    }
  }

  Future<void> updatePandel({
    required String pandelId,
    required String name,
    required List<String> productsId,
    required List<File> newImages,
    required List<String> existingImages, // Keep existing images
    required DateTime startDate,
    required DateTime endDate,
    required double price,
  }) async {
    emit(UpdatePandelLoading());

    try {
      // final List<String> allImages = [...existingImages];
      final List<String> allImages = [];

      // Convert existing images (URLs → base64)
      for (final image in existingImages) {
        if (_isBase64(image)) {
          allImages.add(image); // already base64
        } else {
          final base64Image = await _convertImageUrlToBase64(image);
          if (base64Image != null) {
            allImages.add(base64Image);
          }
        }
      }

      // Convert new images to base64 and add to the list
      for (final image in newImages) {
        final base64Image = await _convertFileToBase64(image);
        if (base64Image != null) {
          allImages.add(base64Image);
        }
      }

      final data = {
        "name": name,
        "productsId": productsId,
        "images": allImages,
        "startdate": startDate.toIso8601String().split('T').first,
        "enddate": endDate.toIso8601String().split('T').first,
        "price": price,
      };

      log(" update pandel ${data}");

      final response = await DioHelper.putData(
        url: EndPoint.updatePandel(
          pandelId,
        ), // You'll need to update this endpoint
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdatePandelSuccess(LocaleKeys.pandel_updated_success.tr()));
        // Refresh the list after update
        await getAllPandels();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdatePandelError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdatePandelError(errorMessage));
    }
  }

  bool _isBase64(String value) {
    return !value.startsWith('http');
  }

  Future<void> deletePandel(String pandelId) async {
    emit(DeletePandelLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deletePandel(
          pandelId,
        ), // You'll need to update this endpoint
      );

      if (response.statusCode == 200) {
        allPandels.removeWhere((pandel) => pandel.id == pandelId);
        emit(DeletePandelSuccess(LocaleKeys.pandel_deleted_success.tr()));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeletePandelError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeletePandelError(errorMessage));
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

      return base64Encode(bytes);
    } catch (e) {
      log("Error converting image: $e");
      return null;
    }
  }

  Future<String?> _convertImageUrlToBase64(String imageUrl) async {
    try {
      final response = await DioHelper.dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        return base64Encode(response.data!);
      }
    } catch (e) {
      log("Error converting image URL to base64: $e");
    }
    return null;
  }

  // Helper method to format dates for display
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Check if a pandel is currently active
  bool isPandelActive(PandelModel pandel) {
    final now = DateTime.now();
    return now.isAfter(pandel.startDate) && now.isBefore(pandel.endDate);
  }

  // Get active pandels
  List<PandelModel> getActivePandels() {
    return allPandels.where(isPandelActive).toList();
  }

  // Get upcoming pandels
  List<PandelModel> getUpcomingPandels() {
    final now = DateTime.now();
    return allPandels.where((pandel) => pandel.startDate.isAfter(now)).toList();
  }
}
