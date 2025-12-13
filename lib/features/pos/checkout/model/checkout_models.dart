import '../../home/model/pos_models.dart';

class CartItem {
  final Product product;
  PriceVariation? selectedVariation; // جديد: الـ variation المختار إذا كان differentPrice true
  int quantity;

  CartItem({
    required this.product,
    this.selectedVariation,
    this.quantity = 1,
  });

  // حساب السعر الفعلي: إذا variation، استخدم سعره؛ وإلا product.price
  double get effectivePrice => selectedVariation?.price ?? product.price;

  // Subtotal بناءً على السعر الفعلي
  double get subtotal => effectivePrice * quantity;
}