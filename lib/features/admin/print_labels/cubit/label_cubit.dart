import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/admin/print_labels/model/label_model.dart';

import 'package:GoSystem/features/admin/print_labels/data/repositories/label_repository.dart';

part 'label_state.dart';

class LabelCubit extends Cubit<LabelState> {
  final LabelRepository _repository;
  LabelCubit(this._repository) : super(LabelInitial());

  // Data Holders (Public for UI access)
  List<LabelProductItem> selectedProducts = [];
  LabelConfig labelConfig = LabelConfig();
  String paperSize = "1_per_sheet_2x1";

  // ---------------------- Initialize Data ----------------------
  void initProducts(List<LabelProductItem> products) {
    selectedProducts = products;
    emit(LabelDataUpdated());
  }

  // ---------------------- Update Quantity ----------------------
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity < 1) return;

    // Find the item and update its quantity directly
    final index = selectedProducts.indexWhere(
      (item) => item.productId == productId,
    );
    if (index != -1) {
      selectedProducts[index].quantity = newQuantity;
      emit(LabelDataUpdated()); // Rebuild UI to show new number
    }
  }

  // ---------------------- Update Config (Toggles) ----------------------
  void updateConfig({
    bool? showProductName,
    bool? showPrice,
    bool? showPromotionalPrice,
    bool? showBusinessName,
    bool? showBrand,
  }) {
    if (showProductName != null) labelConfig.showProductName = showProductName;
    if (showPrice != null) labelConfig.showPrice = showPrice;
    if (showPromotionalPrice != null)
      labelConfig.showPromotionalPrice = showPromotionalPrice;
    if (showBusinessName != null)
      labelConfig.showBusinessName = showBusinessName;
    if (showBrand != null) labelConfig.showBrand = showBrand;

    emit(LabelDataUpdated()); // Rebuild UI to reflect toggles
  }

  // ---------------------- Generate Labels (API) ----------------------
  Future<void> generateLabels() async {
    emit(GenerateLabelsLoading());

    try {
      final message = await _repository.generateLabels(
        products: selectedProducts,
        config: labelConfig,
        paperSize: paperSize,
      );
      emit(GenerateLabelsSuccess(message));
    } catch (e) {
      emit(GenerateLabelsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
