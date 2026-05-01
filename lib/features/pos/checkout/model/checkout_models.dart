import '../../home/model/pos_models.dart';
import '../../../admin/product/models/selected_attribute_model.dart';

class CartItem {
  final Product product;
  PriceVariation? selectedVariation; // الـ variation المختار إذا كان differentPrice true
  int quantity;
  final BundleModel? bundle; // non-null when this item is a bundle
  
  // NEW: Selected attributes for products with attributes
  final List<SelectedAttribute> selectedAttributes;
  
  // NEW: For bundles - map of productId to selected attributes
  final Map<String, List<SelectedAttribute>>? bundleProductAttributes;

  bool get isBundle => bundle != null;
  
  // NEW: Check if this cart item has selected attributes
  bool get hasSelectedAttributes => selectedAttributes.isNotEmpty;
  
  // NEW: Check if this is a bundle with product attributes
  bool get hasBundleAttributes => bundle != null && bundleProductAttributes != null && bundleProductAttributes!.isNotEmpty;

  CartItem({
    required this.product,
    this.selectedVariation,
    this.quantity = 1,
    this.bundle,
    this.selectedAttributes = const [], // NEW
    this.bundleProductAttributes, // NEW
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
  
  // NEW: Compare if two cart items are the same (for quantity increment logic)
  bool isSameAs(CartItem other) {
    // Different products
    if (product.id != other.product.id) return false;
    
    // Different variations
    if (selectedVariation?.id != other.selectedVariation?.id) return false;
    
    // Different bundles
    if (bundle?.id != other.bundle?.id) return false;
    
    // Compare attributes using CartItemAttributes helper
    final thisAttrs = CartItemAttributes(attributes: selectedAttributes);
    final otherAttrs = CartItemAttributes(attributes: other.selectedAttributes);
    if (!thisAttrs.isSameAs(otherAttrs)) return false;
    
    // Compare bundle product attributes if applicable
    if (hasBundleAttributes || other.hasBundleAttributes) {
      // Both must have bundle attributes to be same
      if (!hasBundleAttributes || !other.hasBundleAttributes) return false;
      
      // Compare each product's attributes in bundle
      if (bundleProductAttributes!.length != other.bundleProductAttributes!.length) {
        return false;
      }
      
      for (final entry in bundleProductAttributes!.entries) {
        final otherAttrs = other.bundleProductAttributes![entry.key];
        if (otherAttrs == null) return false;
        
        final thisProductAttrs = CartItemAttributes(attributes: entry.value);
        final otherProductAttrs = CartItemAttributes(attributes: otherAttrs);
        if (!thisProductAttrs.isSameAs(otherProductAttrs)) return false;
      }
    }
    
    return true;
  }
  
  // NEW: Get display string for selected attributes
  String getAttributesDisplay({bool isArabic = false}) {
    if (selectedAttributes.isEmpty) return '';
    return selectedAttributes
        .map((a) => a.getDisplayString(isArabic: isArabic))
        .join(', ');
  }
  
  // NEW: Convert selected attributes to JSON for storage
  List<Map<String, dynamic>> selectedAttributesToJson() {
    return selectedAttributes.map((a) => a.toJson()).toList();
  }
  
  // NEW: Create with parsed attributes (factory helper for restoring from storage)
  factory CartItem.withAttributes({
    required Product product,
    PriceVariation? selectedVariation,
    int quantity = 1,
    BundleModel? bundle,
    required List<dynamic> attributesJson,
    Map<String, List<dynamic>>? bundleAttributesJson,
  }) {
    return CartItem(
      product: product,
      selectedVariation: selectedVariation,
      quantity: quantity,
      bundle: bundle,
      selectedAttributes: attributesJson
          .map((e) => SelectedAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
      bundleProductAttributes: bundleAttributesJson?.map(
        (key, value) => MapEntry(
          key,
          value.map((e) => SelectedAttribute.fromJson(e as Map<String, dynamic>)).toList(),
        ),
      ),
    );
  }
}
