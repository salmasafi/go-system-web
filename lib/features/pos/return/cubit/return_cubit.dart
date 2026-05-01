import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/return_repository.dart';
import '../models/return_item_model.dart';
import '../models/return_sale_model.dart';
import 'return_state.dart';
export 'return_state.dart';

class ReturnCubit extends Cubit<ReturnState> {
  final ReturnRepository _repository = ReturnRepository();

  ReturnCubit() : super(ReturnInitial());

  Future<void> searchSale(String reference) async {
    if (reference.trim().isEmpty) return;

    emit(ReturnSearchLoading());
    try {
      final sale = await _repository.searchSaleForReturn(reference.trim());
      
      if (sale == null || sale.id.isEmpty) {
        emit(ReturnSearchError('Sale not found'));
        return;
      }

      emit(ReturnSaleLoaded(sale: sale, items: sale.items));
    } catch (e) {
      log('ReturnCubit.searchSale error: $e');
      emit(ReturnSearchError(e.toString()));
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

      await _repository.createSaleReturn(
        saleId: sale.id,
        items: itemsPayload,
        totalAmount: itemsPayload.fold(0.0, (sum, item) => sum + (item['quantity'] as int) * 0.0),
        refundMethod: refundAccountId,
        note: note.trim(),
        attachmentFile: attachedFile,
      );

      emit(ReturnSubmitSuccess());
    } catch (e) {
      log('ReturnCubit.submitReturn error: $e');
      emit(ReturnSubmitError(
        sale: sale,
        items: items,
        message: e.toString(),
      ));
    }
  }

  void reset() => emit(ReturnInitial());
}
