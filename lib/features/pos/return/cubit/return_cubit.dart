import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import '../models/return_item_model.dart';
import '../models/return_sale_model.dart';
import 'return_state.dart';
export 'return_state.dart';

class ReturnCubit extends Cubit<ReturnState> {
  ReturnCubit() : super(ReturnInitial());

  Future<void> searchSale(String reference) async {
    if (reference.trim().isEmpty) return;

    emit(ReturnSearchLoading());
    try {
      final response = await DioHelper.postData(
        url: EndPoint.saleForReturn,
        data: {'reference': reference.trim()},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = response.data['message']?.toString() ?? 'Sale not found';
        emit(ReturnSearchError(msg));
        return;
      }

      final sale = ReturnSaleModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (sale.id.isEmpty) {
        emit(ReturnSearchError('Sale not found'));
        return;
      }

      emit(ReturnSaleLoaded(sale: sale, items: sale.items));
    } catch (e) {
      log('ReturnCubit.searchSale error: $e');
      emit(ReturnSearchError(ErrorHandler.handleError(e)));
    }
  }

  void updateReturnQuantity(int index, int quantity) {
    final current = state;
    List<ReturnItemModel> items;
    ReturnSaleModel sale;

    if (current is ReturnSaleLoaded) {
      items = current.items;
      sale = current.sale;
    } else if (current is ReturnSubmitError) {
      items = current.items;
      sale = current.sale;
    } else {
      return;
    }

    final item = items[index];
    items[index].returnQuantity = quantity.clamp(0, item.availableToReturn);
    emit(ReturnSaleLoaded(sale: sale, items: List.from(items)));
  }

  void updateItemReason(int index, String reason) {
    final current = state;
    List<ReturnItemModel> items;
    ReturnSaleModel sale;

    if (current is ReturnSaleLoaded) {
      items = current.items;
      sale = current.sale;
    } else if (current is ReturnSubmitError) {
      items = current.items;
      sale = current.sale;
    } else {
      return;
    }

    items[index].reason = reason;
    emit(ReturnSaleLoaded(sale: sale, items: List.from(items)));
  }

  Future<void> submitReturn({
    required String refundAccountId,
    required String note,
    File? attachedFile,
  }) async {
    final current = state;
    if (current is! ReturnSaleLoaded) return;

    final sale = current.sale;
    final items = current.items;

    if (!items.any((i) => i.returnQuantity > 0)) return;

    emit(ReturnSubmitting(sale: sale, items: items));

    try {
      final itemsPayload = items
          .where((i) => i.returnQuantity > 0)
          .map((i) => {
                'product_price_id': i.productPriceId,
                'quantity': i.returnQuantity,
                'reason': i.reason,
              })
          .toList();

      late final Response response;

      if (attachedFile != null) {
        // Build items as indexed form fields (common API pattern)
        final fd = FormData();
        fd.fields.add(MapEntry('sale_id', sale.id));
        fd.fields.add(MapEntry('refund_account_id', refundAccountId));
        fd.fields.add(MapEntry('note', note.trim()));
        for (int i = 0; i < itemsPayload.length; i++) {
          fd.fields.add(MapEntry('items[$i][product_price_id]', itemsPayload[i]['product_price_id'].toString()));
          fd.fields.add(MapEntry('items[$i][quantity]', itemsPayload[i]['quantity'].toString()));
          fd.fields.add(MapEntry('items[$i][reason]', itemsPayload[i]['reason'].toString()));
        }
        fd.files.add(MapEntry(
          'document',
          await MultipartFile.fromFile(
            attachedFile.path,
            filename: attachedFile.path.split('/').last,
          ),
        ));

        response = await DioHelper.postData(
          url: EndPoint.createReturn,
          data: fd,
        );
      } else {
        response = await DioHelper.postData(
          url: EndPoint.createReturn,
          data: {
            'sale_id': sale.id,
            'items': itemsPayload,
            'refund_account_id': refundAccountId,
            'note': note.trim(),
          },
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ReturnSubmitSuccess());
      } else {
        final msg = response.data['message']?.toString() ?? 'Failed to submit return';
        emit(ReturnSubmitError(sale: sale, items: items, message: msg));
      }
    } catch (e) {
      log('ReturnCubit.submitReturn error: $e');
      emit(ReturnSubmitError(
        sale: sale,
        items: items,
        message: ErrorHandler.handleError(e),
      ));
    }
  }

  void reset() => emit(ReturnInitial());
}
