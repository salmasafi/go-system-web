import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  String? reference;
  int? pointsEarned;
  Map<String, dynamic>? sale;
  List<CartItem> cartItems = [];

  // ... (Add/Remove/Update methods remain the same) ...
  // Methods for cart manipulation (addToCart, etc.) are good as they are in your previous code.
  // I'll focus on createSale below.

  void addBundleToCart(
    BundleModel bundle, {
    Map<String, List<SelectedAttribute>>? bundleProductAttributes,
  }) {
    // Create new cart item
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

    // Check for existing identical bundle
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
    // Create a new cart item with the provided attributes
    final newItem = CartItem(
      product: product,
      quantity: 1,
      selectedAttributes: selectedAttributes ?? [],
    );

    // Check if an identical item already exists in cart
    final existingIndex = cartItems.indexWhere((item) => item.isSameAs(newItem));

    if (existingIndex >= 0) {
      // Item with same product and attributes exists → increment quantity
      cartItems[existingIndex].quantity++;
    } else {
      // New unique item → add to cart
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

  // ────────────────────────────────────────────────────────────────
  //  Create Sale Function (Updated for new Payload)
  // ────────────────────────────────────────────────────────────────
  Future<bool> createSale({
    required double totalAmount,
    double paidAmount = 0.0,
    String? note,
    bool isPending = false,
    required String customerId,
    String? warehouseId,
    String? accountId,
    String? cashierId,
    double taxAmount = 0.0,
    double discountAmount = 0.0,
    String? taxId,
    String? discountId,
  }) async {
    emit(CheckoutLoading());

    // 1. Prepare Products List (exclude bundle items)
    final productsList = cartItems.where((item) => !item.isBundle).map((item) {
      return {
        "product_id": item.product.id,
        "quantity": item.quantity.toString(),
        "price": item.effectivePrice.toStringAsFixed(2),
        "subtotal": item.subtotal.toStringAsFixed(2),
        if (item.isWholePriceActive)
          "whole_price": item.wholePrice!.toStringAsFixed(2),
        if (item.hasSelectedAttributes)
          "attributes": item.selectedAttributesToJson(),
      };
    }).toList();

    // 1b. Prepare Bundles List
    final bundlesList = cartItems.where((item) => item.isBundle).map((item) {
      return {
        "bundle_id": item.bundle!.id,
        "quantity": item.quantity.toString(),
        "price": item.bundle!.price.toStringAsFixed(2),
        "subtotal": (item.bundle!.price * item.quantity).toStringAsFixed(2),
        if (item.hasBundleAttributes)
          "attributes_per_product": item.bundleProductAttributes!.map(
            (key, value) => MapEntry(key, value.map((a) => a.toJson()).toList()),
          ),
      };
    }).toList();

    final body = {
      "order_pending": isPending ? 1 : 0,
      "grand_total": totalAmount.toStringAsFixed(2),
      "Due": isPending ? 1 : (paidAmount < totalAmount ? 1 : 0),
      "products": productsList,
      "bundles": bundlesList,
      if (customerId.isNotEmpty) "customer_id": customerId,
      if (warehouseId != null) "warehouse_id": warehouseId,
      if (cashierId != null) "cashier_id": cashierId,
      if (note != null && note.isNotEmpty) "notes": note,
      if (discountAmount > 0) "discount": discountAmount.toStringAsFixed(2),
      if (discountId != null && discountId.isNotEmpty && discountId != 'null')
        "discount_id": discountId,
      if (taxAmount > 0) "tax_amount": taxAmount.toStringAsFixed(2),
      if (taxId != null && taxId.isNotEmpty && taxId != 'null') "tax_id": taxId,
      // financials مطلوبة فقط للـ complete sale
      if (!isPending && accountId != null)
        "financials": [
          {"account_id": accountId, "amount": paidAmount.toStringAsFixed(2)},
        ]
      else
        "financials": <Map<String, dynamic>>[],
    };

    try {
      log("Creating Sale with Body: $body"); // Debugging

      final response = await DioHelper.postData(
        url: EndPoint.posCreateSale,
        data: body,
      );

      log("Sale Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];

        // قد يختلف الهيكل قليلاً حسب الرد، نتحقق
        if (data != null && data['sale'] != null) {
          sale = data['sale'];
          reference = sale?['reference'];
          pointsEarned = data['pointsEarned'] ?? 0;
        }

        emit(CheckoutSuccess());

        // تنظيف السلة بعد النجاح
        updateCartWithEmptyList();
        return true;
      } else {
        final msg = response.data['message'] ?? LocaleKeys.failed_to_create_sale.tr();
        emit(CheckoutError(msg));
        return false;
      }
    } catch (e) {
      log("Create Sale Error: $e");
      final errorMsg = ErrorHandler.handleError(e); // استخدام الهندلر الخاص بك
      emit(CheckoutError(errorMsg));
      return false;
    }
  }
}
