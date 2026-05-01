import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';

import 'package:systego/features/admin/pandel/model/pandel_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:systego/features/admin/pandel/data/repositories/bundle_repository.dart';

part 'pandel_state.dart';

class PandelCubit extends Cubit<PandelState> {
  final BundleRepository _repository;
  PandelCubit(this._repository) : super(PandelInitial());

  List<PandelModel> allPandels = [];

  Future<void> getAllPandels() async {
    emit(GetPandelsLoading());
    try {
      final pandels = await _repository.getAllBundles();
      allPandels = pandels;
      emit(GetPandelsSuccess(pandels));
    } catch (e) {
      emit(GetPandelsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getPandelById(String pandelId) async {
    emit(GetPandelByIdLoading());
    try {
      // Find in local list for now
      final pandel = allPandels.firstWhere((p) => p.id == pandelId);
      emit(GetPandelByIdSuccess(pandel));
    } catch (e) {
      emit(GetPandelByIdError(LocaleKeys.pandel_not_found.tr()));
    }
  }

  Future<void> addPandel({
    required String name,
    required List<PandelProduct> products,
    List<File>? images,
    required DateTime startDate,
    required DateTime endDate,
    required double price,
    bool allWarehouses = true,
    List<String>? warehouseIds,
  }) async {
    emit(CreatePandelLoading());

    try {
      final List<String> base64Images = [];
      if (images != null) {
        for (final image in images) {
          final base64Image = await _convertFileToBase64(image);
          if (base64Image != null) base64Images.add(base64Image);
        }
      }

      final pandel = PandelModel(
        id: '',
        name: name,
        products: products,
        images: base64Images,
        startDate: startDate,
        endDate: endDate,
        price: price,
        status: true,
        allWarehouses: allWarehouses,
        warehouseIds: warehouseIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 0,
      );

      await _repository.createBundle(pandel);
      emit(CreatePandelSuccess(LocaleKeys.pandel_created_success.tr()));
    } catch (e) {
      emit(GetPandelsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePandel({
    required String pandelId,
    required String name,
    required List<PandelProduct> products,
    List<File>? images,
    List<File>? newImages,
    List<String>? existingImages,
    required DateTime startDate,
    required DateTime endDate,
    required double price,
    bool? status,
    bool allWarehouses = true,
    List<String>? warehouseIds,
  }) async {
    emit(UpdatePandelLoading());

    try {
      final List<String> base64Images = [];
      final effectiveImages = newImages ?? images;
      if (effectiveImages != null) {
        for (final image in effectiveImages) {
          final base64Image = await _convertFileToBase64(image);
          if (base64Image != null) base64Images.add(base64Image);
        }
      }

      final pandel = PandelModel(
        id: pandelId,
        name: name,
        products: products,
        images: base64Images,
        startDate: startDate,
        endDate: endDate,
        price: price,
        status: status ?? true,
        allWarehouses: allWarehouses,
        warehouseIds: warehouseIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 0,
      );

      await _repository.updateBundle(pandel);
      emit(UpdatePandelSuccess(LocaleKeys.pandel_updated_success.tr()));
    } catch (e) {
      emit(UpdatePandelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deletePandel(String pandelId) async {
    emit(DeletePandelLoading());
    try {
      final success = await _repository.deleteBundle(pandelId);
      if (success) {
        allPandels.removeWhere((p) => p.id == pandelId);
        emit(DeletePandelSuccess(LocaleKeys.pandel_deleted_success.tr()));
      } else {
        emit(DeletePandelError('Failed to delete bundle'));
      }
    } catch (e) {
      emit(DeletePandelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<String?> _convertFileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      log("Error converting file to base64: $e");
      return null;
    }
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
