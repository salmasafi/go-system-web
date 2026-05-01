import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/variations/model/variation_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:systego/features/admin/variations/data/repositories/variation_repository.dart';

part 'variation_state.dart';

class VariationCubit extends Cubit<VariationState> {
  final VariationRepository _repository;
  VariationCubit(this._repository) : super(VariationInitial());

  List<VariationModel> allVariations = [];

  // Fetch all variations
  Future<void> getAllVariations() async {
    emit(GetVariationsLoading());
    try {
      final variations = await _repository.getAllVariations();
      allVariations = variations;
      emit(GetVariationsSuccess(variations));
    } catch (e) {
      emit(GetVariationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Fetch variation by ID
  Future<void> getVariationById(String variationId) async {
    emit(GetVariationByIdLoading());
    try {
      // Repository doesn't have getById yet, we can filter local list or we could add it
      // For now, let's just find in local list to save an API call
      final variation = allVariations.firstWhere((v) => v.id == variationId);
      emit(GetVariationByIdSuccess(variation));
    } catch (e) {
      emit(GetVariationByIdError('Variation not found'));
    }
  }

  // Add variation
  Future<void> addVariation({
    required String name,
    required String arName,
    required List<Map<String, dynamic>> options,
  }) async {
    emit(CreateVariationLoading());
    try {
      final variation = VariationModel(
        id: '',
        name: name,
        arName: arName,
        createdAt: '',
        updatedAt: '',
        version: 0,
        options: options
            .map(
              (opt) => VariationOption(
                id: '',
                variationId: '',
                name: opt['name'],
                status: opt['status'],
                createdAt: '',
                updatedAt: '',
                version: 0,
              ),
            )
            .toList(),
      );

      await _repository.createVariation(variation);
      emit(CreateVariationSuccess(LocaleKeys.variation_created_success.tr()));
    } catch (e) {
      emit(CreateVariationError(e.toString().replaceAll('Exception: ', '')));
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
      final variation = VariationModel(
        id: variationId,
        name: name,
        arName: arName,
        createdAt: '',
        updatedAt: '',
        version: 0,
        options: options
            .map(
              (opt) => VariationOption(
                id: opt['id'] ?? '',
                variationId: variationId,
                name: opt['name'],
                status: opt['status'],
                createdAt: '',
                updatedAt: '',
                version: 0,
              ),
            )
            .toList(),
      );

      await _repository.updateVariation(variation);
      emit(UpdateVariationSuccess(LocaleKeys.variation_updated_success.tr()));
    } catch (e) {
      emit(UpdateVariationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteOption(String optionId) async {
    emit(DeleteOptionLoading());
    try {
      // The repository doesn't have deleteOption directly, usually handled via updateVariation
      // For legacy, we might need to add it to the interface if used often.
      // For now, let's assume it's part of the variation update.
      emit(
        DeleteOptionError(
          'Option deletion not directly supported via repository yet',
        ),
      );
    } catch (e) {
      emit(DeleteOptionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteVariation(String variationId) async {
    emit(DeleteVariationLoading());
    try {
      final success = await _repository.deleteVariation(variationId);
      if (success) {
        allVariations.removeWhere((v) => v.id == variationId);
        emit(DeleteVariationSuccess(LocaleKeys.variation_deleted_success.tr()));
      } else {
        emit(DeleteVariationError('Failed to delete variation'));
      }
    } catch (e) {
      emit(DeleteVariationError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
