import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';
import 'package:GoSystem/features/admin/coupon/model/coupon_model.dart';
import 'package:GoSystem/features/pos/sales/data/repositories/sale_repository.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final SaleRepository _saleRepository = SaleRepository();

  CheckoutCubit() : super(CheckoutInitial());

  String? _nullIfEmpty(String? value) {
    if (value == null) return null;
    final v = value.trim();
    if (v.isEmpty || v == 'null') return null;
    return v;
  }

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

  CartSummary calculateSummary({
    Tax? selectedTax,
    DiscountModel? selectedDiscount,
    CouponModel? selectedCoupon,
  }) {
    final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

    // 1. Discount
    double discountVal = 0.0;
    if (selectedDiscount != null && selectedDiscount.id != 'null') {
      if (selectedDiscount.type == 'percentage') {
        discountVal = subtotal * selectedDiscount.amount;
      } else {
        discountVal = selectedDiscount.amount;
      }
    }

    // 2. Coupon
    double couponVal = 0.0;
    if (selectedCoupon != null && selectedCoupon.id != 'null') {
      if (selectedCoupon.type == 'percentage') {
        couponVal = subtotal * selectedCoupon.amount;
      } else {
        couponVal = selectedCoupon.amount;
      }
    }

    // 3. Tax (calculated on full subtotal as per user request)
    double taxVal = 0.0;
    if (selectedTax != null && selectedTax.id != 'null') {
      if (selectedTax.type == 'percentage') {
        taxVal = subtotal * selectedTax.amount;
      } else {
        taxVal = selectedTax.amount;
      }
    }

    final grandTotal = (subtotal + taxVal - discountVal - couponVal).clamp(0.0, double.infinity);

    return CartSummary(
      subtotal: subtotal,
      taxAmount: taxVal,
      discountAmount: discountVal,
      couponAmount: couponVal,
      grandTotal: grandTotal,
    );
  }

  Future<bool> createSale({
    required double totalAmount,
    double paidAmount = 0.0,
    String? note,
    bool isPending = false,
    String? customerId,
    String? accountId,
    String? paymentMethodId,
    String? warehouseId,
    String? shiftId,
    String? cashierId,
    double taxAmount = 0.0,
    double discountAmount = 0.0,
    String? taxId,
    String? discountId,
    String? couponCode,
  }) async {
    emit(CheckoutLoading());

    final normalizedWarehouseId = _nullIfEmpty(warehouseId);
    if (normalizedWarehouseId == null) {
      emit(CheckoutError(LocaleKeys.please_select_warehouse.tr()));
      return false;
    }

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
        customerId: _nullIfEmpty(customerId),
        warehouseId: normalizedWarehouseId,
        shiftId: _nullIfEmpty(shiftId),
        cashierId: _nullIfEmpty(cashierId),
        items: items,
        grandTotal: totalAmount,
        taxAmount: taxAmount,
        discount: discountAmount,
        note: note,
        couponCode: couponCode,
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
      // SaleRepository already formats the error via SupabaseErrorHandler.
      // Extract message directly — don't pass through the old DioException handler.
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(CheckoutError(msg));
      return false;
    }
  }
}

