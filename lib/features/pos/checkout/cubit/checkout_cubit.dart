import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';

import '../../home/cubit/pos_home_cubit.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  Future<bool> createSale({
    required PosCubit posCubit,
    required List<CartItem> cartItems,
    required double totalAmount,
    // required double paidAmount,
    // required Customer customer,
    // required Warehouse warehouse,
    //required PaymentMethod paymentMethod,
    // required BankAccount account,
    //required Currency currency,
    //Tax? tax,
    String? paymentNote,
  }) async {
    emit(CheckoutLoading());

    final products = cartItems
        .map(
          (item) => {
            "product_id": item.product.id,
            "quantity": item.quantity,
            "price": item.product.price,
            "subtotal": item.product.price * item.quantity,
          },
        )
        .toList();

    final body = {
      "customer_id": posCubit.selectedCustomer?.id,
      "warehouse_id": posCubit.selectedWarhouse?.id,
      "currency_id": posCubit.selectedCurrency?.id,
      "account_id": posCubit.selectedAccount?.id,
      "order_tax": posCubit.selectedTax?.id,
      "shipping_cost": 0,
      "grand_total": totalAmount,
      "payment_method": posCubit.selectedPaymentMethod?.id,
      "payment_note": paymentNote ?? "",
      "products": products,
    };

    try {
      final response = await DioHelper.postData(
        url: EndPoint.posCreateSale,
        data: body,
      );
      log('${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final sale = response.data['data']['sale'];
        final points = response.data['data']['pointsEarned'] ?? 0;

        emit(
          CheckoutSuccess(
            reference:
                sale['reference'] ??
                'SALE-${DateTime.now().millisecondsSinceEpoch}',
            pointsEarned: points,
            sale: sale,
          ),
        );
        return true;
      } else {
        emit(
          CheckoutError(response.data['message'] ?? 'Failed to complete sale'),
        );
        log(response.data['message'] ?? 'Failed to complete sale');

        return false;
      }
    } catch (e) {
      emit(CheckoutError('Connection error. Please try again.'));
      log(e.toString());
      return false;
    }
  }
}
