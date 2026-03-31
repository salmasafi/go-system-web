import '../../home/model/pos_models.dart';

class CartItem {
  final Product product;
  PriceVariation? selectedVariation; // جديد: الـ variation المختار إذا كان differentPrice true
  int quantity;
  final BundleModel? bundle; // non-null when this item is a bundle

  bool get isBundle => bundle != null;

  CartItem({
    required this.product,
    this.selectedVariation,
    this.quantity = 1,
    this.bundle,
  });

  // السعر الأساسي من variation أو product
  double get basePrice => selectedVariation?.price ?? product.price;

  // سعر الجملة من variation أو product
  double? get wholePrice => selectedVariation?.wholePrice ?? product.wholePrice;

  // الحد الأدنى للكمية
  int? get startQuantity => selectedVariation?.startQuantity ?? product.startQuantity;

  // هل خصم الجملة مفعّل؟
  bool get isWholePriceActive =>
      wholePrice != null &&
      startQuantity != null &&
      quantity >= startQuantity!;

  // السعر الفعلي المُطبَّق
  double get effectivePrice => isWholePriceActive ? wholePrice! : basePrice;

  // Subtotal بناءً على السعر الفعلي
  double get subtotal => effectivePrice * quantity;
}