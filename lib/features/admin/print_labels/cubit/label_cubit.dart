import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/print_labels/model/label_model.dart';

part 'label_state.dart';

class LabelCubit extends Cubit<LabelState> {
  LabelCubit() : super(LabelInitial());

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
    final index = selectedProducts.indexWhere((item) => item.productId == productId);
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
    if (showPromotionalPrice != null) labelConfig.showPromotionalPrice = showPromotionalPrice;
    if (showBusinessName != null) labelConfig.showBusinessName = showBusinessName;
    if (showBrand != null) labelConfig.showBrand = showBrand;

    emit(LabelDataUpdated()); // Rebuild UI to reflect toggles
  }

  // ---------------------- Generate Labels (API) ----------------------
  Future<void> generateLabels() async {
    emit(GenerateLabelsLoading());

    try {
      // 1. Prepare Data
      final data = {
        "products": selectedProducts.map((e) => e.toApiJson()).toList(),
        "labelConfig": labelConfig.toJson(),
        "paperSize": paperSize,
      };

      log("Generating Labels Payload: $data");

      // 2. Call API
      // Note: Make sure EndPoint.generateLabels is defined as 'api/admin/label/generate'
      final response = await DioHelper.postData(
        url: 'api/admin/label/generate', // Or use EndPoint.generateLabels
        data: data,
      );

      // 3. Handle Response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // You might want to handle the PDF download or URL here if the API returns one
        emit(GenerateLabelsSuccess("Labels generated successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GenerateLabelsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GenerateLabelsError(errorMessage));
    }
  }
}