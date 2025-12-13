import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../../../home/cubit/pos_home_cubit.dart';
import '../../../home/model/pos_models.dart';
import '../../model/checkout_models.dart';
part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());
  String? reference;
  int? pointsEarned;
  Map<String, dynamic>? sale;

  List<CartItem> cartItems = [];

  // تعديل: أضف إلى السلة مع optional variation
  void addToCart(Product product, {PriceVariation? variation}) {
    final existingIndex = cartItems.indexWhere(
      (i) => i.product.id == product.id && 
             (i.selectedVariation?.id == variation?.id || (i.selectedVariation == null && variation == null)),
    );
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(CartItem(product: product, selectedVariation: variation, quantity: 1));
    }
    emit(PosCartUpdated(cartItems));
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      emit(PosCartUpdated(cartItems));
    }
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= cartItems.length) return;
    final newQty = cartItems[index].quantity + delta;
    if (newQty > 0) {
      cartItems[index].quantity = newQty;
    } else {
      cartItems.removeAt(index);
    }
    emit(PosCartUpdated(cartItems));
  }

  void updateCartWithEmptyList() {
    cartItems.clear();
    emit(PosCartUpdated([]));
  }

  Future<bool> createSale({
    required PosCubit posCubit,
    required List<CartItem> cartItems,
    required double totalAmount,
    String? paymentNote,
  }) async {
    emit(CheckoutLoading());

    final products = cartItems
        .map(
          (item) => {
            "product_id": item.product.id,
            "quantity": item.quantity,
            "price": item.effectivePrice, // تعديل: استخدم السعر الفعلي
            "subtotal": item.subtotal,
            if (item.selectedVariation != null) "variation_id": item.selectedVariation!.id, // جديد: أضف ID الـ variation إذا موجود
          },
        )
        .toList();

    final body = {
      "customer_id": posCubit.selectedCustomer?.id ?? '68f4bd26a6017b1543773cf6',
      "warehouse_id": posCubit.selectedWarhouse?.id,
      "account_id": ['6938368ac804bcdd2b748f13'],
      "order_tax": posCubit.selectedTax?.id,
      "grand_total": totalAmount,
      "payment_note": paymentNote ?? "",
      "products": products,
      "order_pending": 0,
    };

    try {
      final response = await DioHelper.postData(
        url: EndPoint.posCreateSale,
        data: body,
      );
      log('${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final saleData = response.data['data']['sale'];
        final points = response.data['data']['pointsEarned'] ?? 0;

        emit(CheckoutSuccess());
        reference = saleData['reference'] ?? 'SALE-${DateTime.now().millisecondsSinceEpoch}';
        pointsEarned = points;
        sale = saleData;
        return true;
      } else {
        emit(CheckoutError(response.data['message'] ?? 'Failed to complete sale'));
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