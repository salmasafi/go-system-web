import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/variations/model/variation_model.dart';

part 'variation_state.dart';

class VariationCubit extends Cubit<VariationState> {
  VariationCubit() : super(VariationInitial());

  List<VariationModel> allVariations = [];

  // Fetch all variations
  Future<void> getAllVariations() async {
    emit(GetVariationsLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllVariations);

      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = VariationResponse.fromJson(response.data);

        if (model.success) {
          allVariations = model.data.variations;
          emit(GetVariationsSuccess(model.data.variations));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetVariationsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetVariationsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetVariationsError(errorMessage));
    }
  }

  // Fetch variation by ID
  Future<void> getVariationById(String variationId) async {
    emit(GetVariationByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getVariation(variationId),
      );

      if (response.statusCode == 200) {
        final model = VariationModel.fromJson(response.data['data']);
        emit(GetVariationByIdSuccess(model));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetVariationByIdError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetVariationByIdError(errorMessage));
    }
  }

  // Add variation
  Future<void> addVariation({
    required String name,
    required String arName,
    required List<Map<String, dynamic>> options, // e.g., [{"name": "sm", "status": true}, ...]
  }) async {
    emit(CreateVariationLoading());
    try {
      final data = {
        "name": name,
        "ar_name": arName,
        "options": options,
      };

      final response = await DioHelper.postData(
        url: EndPoint.addVariation,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateVariationSuccess("Variation created successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateVariationError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateVariationError(errorMessage));
    }
  }

 

  Future<void> updateVariation({
  required String variationId,
  required String name,
  required String arName,
  required List<Map<String, dynamic>> options,
}) async {
  emit(UpdateVariationLoading());
  try {
    final data = {
      "name": name,
      "ar_name": arName,
      "options": options,
    };

    final response = await DioHelper.putData(
      url: EndPoint.updateVariation(variationId),
      data: data,
    );

    if (response.statusCode == 200) {
      emit(UpdateVariationSuccess("Variation updated successfully"));
    } else {
      final errorMessage = ErrorHandler.handleError(response);
      emit(UpdateVariationError(errorMessage));
    }
  } catch (e) {
    final errorMessage = ErrorHandler.handleError(e);
    emit(UpdateVariationError(errorMessage));
  }
}

Future<void> deleteOption(String optionId) async {

    emit(DeleteOptionLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteOption(optionId),
      );

      

      if (response.statusCode == 200) {
        allVariations.removeWhere((v) => v.id == optionId);
        emit(DeleteOptionSuccess("Option deleted successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteOptionError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteOptionError(errorMessage));
    }
  }

  Future<void> deleteVariation(String variationId) async {
    emit(DeleteVariationLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteVariation(variationId),
      );

      if (response.statusCode == 200) {
        allVariations.removeWhere((v) => v.id == variationId);
        emit(DeleteVariationSuccess("Variation deleted successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteVariationError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteVariationError(errorMessage));
    }
  }
}
