import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/purchase/model/purchase_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'purchase_state.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(PurchaseInitial());

  PurchaseData? purchaseData;

  // ---------------------- Get All Purchases ----------------------
  Future<void> getAllPurchases() async {
    emit(GetPurchasesLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPurchase, // Ensure this endpoint exists
      );

      // log(response.data.toString());

      if (response.statusCode == 200) {
        final model = PurchaseResponse.fromJson(response.data);

        if (model.success) {
          purchaseData = model.data;
          emit(GetPurchasesSuccess(model.data));
        } else {
          // Fallback if success is false but code is 200
          emit(GetPurchasesError("Failed to fetch purchases"));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetPurchasesError(errorMessage));
      }
    } catch (e) {
      log("error $e");
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetPurchasesError(errorMessage));
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