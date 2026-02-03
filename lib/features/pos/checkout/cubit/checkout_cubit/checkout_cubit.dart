import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart'; // تأكد من المسار
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

  // ... (Add/Remove/Update methods remain the same) ...
  // Methods for cart manipulation (addToCart, etc.) are good as they are in your previous code.
  // I'll focus on createSale below.

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

  // ────────────────────────────────────────────────────────────────
  //  Create Sale Function (Updated for new Payload)
  // ────────────────────────────────────────────────────────────────
  Future<bool> createSale({
    // required PosCubit posCubit,
    required double totalAmount, // grand_total
    double paidAmount = 0.0, // المبلغ المدفوع فعلياً
    String? note,
    bool isPending = false, // order_pending: 1 if true, 0 if false
  }) async {
    emit(CheckoutLoading());

    // 1. Prepare Products List
    final productsList = cartItems.map((item) {
      // تحديد السعر الفعلي (سواء من المنتج الأساسي أو المتغير)
      final price = item.selectedVariation?.price ?? item.product.price;
      
      return {
        "product_id": item.product.id,
        // إذا كان هناك variation، نرسل product_price_id
        if (item.selectedVariation != null) 
          "product_price_id": item.selectedVariation!.id,
        
        "quantity": item.quantity,
        "price": price,
        "subtotal": item.subtotal, // price * quantity
      };
    }).toList();

    // 2. Calculate Due Status (1 if there is remaining debt, 0 if fully paid)
    // منطق بسيط: لو دفع أقل من الإجمالي، يبقى عليه فلوس (Due = 1)
    // أو يمكن تمريرها كـ parameter لو عندك منطق معقد
    final isDue = (paidAmount < totalAmount) ? "1" : "0";

    // 3. Prepare Financials (Only if not pending and Amount > 0)
    List<Map<String, dynamic>> financials = [];
    if (!isPending && paidAmount > 0) {
      // // التأكد من اختيار حساب بنكي (Cash Register / Bank)
      // if (posCubit.selectedAccount != null) {
      //   financials.add({
      //     "account_id": posCubit.selectedAccount!.id,
      //     "amount": paidAmount,
      //   });
      // }
    }

    // 4. Construct the Body
    final body = {
      // // الأساسيات
      // "customer_id": posCubit.selectedCustomer?.id,
      // "warehouse_id": posCubit.selectedWarhouse?.id, // مهم جداً للمخزون
      // "cashier_id": posCubit.selectedCashier?.id, // الكاشير الحالي
      
      // التواريخ والحالة
      "date": DateTime.now().toIso8601String(),
      "order_pending": isPending ? 1 : 0,
      "Due": isDue, 

      // الأرقام المالية
      "grand_total": totalAmount,
      "tax_rate": 0, // أو posCubit.selectedTax?.rate إذا موجود
      "tax_amount": 0, // حساب القيمة بناء على النسبة
      "discount": 0,   // قيمة الخصم رقمياً
      "shipping": 0,

      // // العلاقات (Discounts, Taxes, Coupon)
      // if (posCubit.selectedTax != null && posCubit.selectedTax!.id != 'null')
      //   "order_tax": posCubit.selectedTax!.id,
      
      // if (posCubit.selectedDiscount != null && posCubit.selectedDiscount!.id != 'null')
      //   "order_discount": posCubit.selectedDiscount!.id,
      
      // "coupon_id": "", // أضفه إذا كان لديك CouponCubit

      // القوائم
      "products": productsList,
      "bundles": [], // حالياً فارغة كما طلبت
      
      // المدفوعات (فقط إذا لم يكن معلقاً)
      if (!isPending) "financials": financials,

      "note": note ?? "Completed via POS App",
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
        final msg = response.data['message'] ?? 'Failed to create sale';
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