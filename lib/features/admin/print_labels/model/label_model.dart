// class LabelProductItem {
//   final String productId;
//   final String productPriceId;
//   final String productName; 
//   int quantity; // Mutable for easy updates in the list

//   LabelProductItem({
//     required this.productId,
//     required this.productPriceId,
//     required this.productName,
//     this.quantity = 1,
//   });

//   // Maps to the specific object inside "products" array
//   Map<String, dynamic> toApiJson() {
//     return {
//       "productId": productId,
//       "productPriceId": productPriceId,
//       "quantity": quantity,
//     };
//   }
// }

// class LabelConfig {
//   bool showProductName;
//   bool showPrice;
//   bool showPromotionalPrice;
//   bool showBusinessName;
//   bool showBrand;
//   double productNameSize;
//   double priceSize;
//   double businessNameSize;
//   double brandSize;

//   LabelConfig({
//     this.showProductName = false,
//     this.showPrice = false,
//     this.showPromotionalPrice = false,
//     this.showBusinessName = false,
//     this.showBrand = false,
//     this.productNameSize = 12,
//     this.priceSize = 14,
//     this.businessNameSize = 10,
//     this.brandSize = 10,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "showProductName": showProductName,
//       "showPrice": showPrice,
//       "showPromotionalPrice": showPromotionalPrice,
//       "showBusinessName": showBusinessName,
//       "showBrand": showBrand,
//       "productNameSize": productNameSize,
//       "priceSize": priceSize,
//       "businessNameSize": businessNameSize,
//       "brandSize": brandSize,
//     };
//   }
// }

// lib/features/admin/print_labels/model/label_model.dart

class LabelConfig {
  bool showProductName;
  bool showPrice;
  bool showPromotionalPrice;
  bool showBusinessName;
  bool showBrand;

  LabelConfig({
    this.showProductName = true,
    this.showPrice = true,
    this.showPromotionalPrice = false,
    this.showBusinessName = true,
    this.showBrand = false,
  });

  Map<String, dynamic> toJson() => {
    "showProductName": showProductName,
    "showPrice": showPrice,
    "showPromotionalPrice": showPromotionalPrice,
    "showBusinessName": showBusinessName,
    "showBrand": showBrand,
  };
}

class LabelProductItem {
  final String productId; // Could be product ID or variation ID
  final String name;
  final String? variationName;
  final double price;
  final String? image;
  int quantity;

  LabelProductItem({
    required this.productId,
    required this.name,
    this.variationName,
    required this.price,
    this.image,
    required this.quantity,
  });

  Map<String, dynamic> toApiJson() => {
    "product_id": productId,
    "quantity": quantity,
  };
}