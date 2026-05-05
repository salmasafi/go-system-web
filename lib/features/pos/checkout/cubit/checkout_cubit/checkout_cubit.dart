import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';
import 'package:GoSystem/features/pos/sales/data/repositories/sale_repository.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final SaleRepository _saleRepository = SaleRepository();

  CheckoutCubit() : super(CheckoutInitial());

  String? reference;
  int? pointsEarned;
  Map<String, dynamic>? sale;
  List<CartItem> cartItems = [];

  void addBundleToCart(
    BundleModel bundle, {
    Map<String, List<SelectedAttribute>>? bundleProductAttributes,
  }) {
    final newItem = CartItem(
      product: Product(
        id: bundle.id,
        name: bundle.name,
        code: 'BUNDLE-${bundle.id}',
        description: 'Bundle: ${bundle.name}',
        price: bundle.price,
      ),
      quantity: 1,
      bundle: bundle,
      bundleProductAttributes: bundleProductAttributes,
    );

    final existingIndex = cartItems.indexWhere((i) => i.isSameAs(newItem));

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(newItem);
    }
    emit(PosCartUpdated(cartItems));
  }

  void addToCart(
    Product product, {
    List<SelectedAttribute>? selectedAttributes,
  }) {
    final newItem = CartItem(
      product: product,
      quantity: 1,
      selectedAttributes: selectedAttributes ?? [],
    );

    final existingIndex = cartItems.indexWhere((item) => item.isSameAs(newItem));

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(newItem);
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
    required double totalAmount,
    double paidAmount = 0.0,
    String? note,
    bool isPending = false,
    required String customerId,
    String? accountId,
    String? paymentMethodId,
    String? warehouseId,
    String? shiftId,
    String? cashierId,
    double taxAmount = 0.0,
    double discountAmount = 0.0,
    String? taxId,
    String? discountId,
  }) async {
    emit(CheckoutLoading());

    // 1. Prepare items for Supabase
    final items = cartItems.map((item) {
      return {
        "product_id": item.product.id,
        "quantity": item.quantity,
        "price": item.effectivePrice,
        "subtotal": item.subtotal,
        "is_bundle": item.isBundle,
        "bundle_id": item.isBundle ? item.bundle?.id : null,
        if (item.hasSelectedAttributes)
          "attributes": item.selectedAttributesToJson(),
      };
    }).toList();

    // 2. Prepare payments
    final List<Map<String, dynamic>> payments = [];
    if (!isPending && accountId != null && paymentMethodId != null && paidAmount > 0) {
      payments.add({
        "bank_account_id": accountId,
        "payment_method_id": paymentMethodId,
        "amount": paidAmount,
      });
    }

    try {
      final saleDetail = await _saleRepository.createSale(
        customerId: customerId,
        warehouseId: warehouseId ?? '',
        shiftId: shiftId,
        cashierId: cashierId,
        items: items,
        grandTotal: totalAmount,
        taxAmount: taxAmount,
        discount: discountAmount,
        note: note,
        payments: payments,
        isPending: isPending,
      );

      reference = saleDetail.reference;
      // pointsEarned = saleDetail.pointsEarned; // If available in model

      emit(CheckoutSuccess());
      updateCartWithEmptyList();
      return true;
    } catch (e) {
      log("Create Sale Error: $e");
      emit(CheckoutError(ErrorHandler.handleError(e)));
      return false;
    }
  }
}

