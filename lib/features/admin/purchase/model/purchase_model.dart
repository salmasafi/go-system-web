// class PurchaseModel {
//   PurchaseModel({
//       this.success,
//       this.data,});
//
//   PurchaseModel.fromJson(dynamic json) {
//     success = json['success'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//   }
//   bool? success;
//   Data? data;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['success'] = success;
//     if (data != null) {
//       map['data'] = data?.toJson();
//     }
//     return map;
//   }
//
// }
//
// class Data {
//   Data({
//       this.purchases,
//       this.warehouses,
//       this.currencies,
//       this.suppliers,
//       this.taxes,
//       this.financialAccount,
//       this.products,
//       this.variations,});
//
//   Data.fromJson(dynamic json) {
//     if (json['purchases'] != null) {
//       purchases = [];
//       json['purchases'].forEach((v) {
//         purchases?.add(Purchases.fromJson(v));
//       });
//     }
//     if (json['warehouses'] != null) {
//       warehouses = [];
//       json['warehouses'].forEach((v) {
//         warehouses?.add(Warehouses.fromJson(v));
//       });
//     }
//     if (json['currencies'] != null) {
//       currencies = [];
//       json['currencies'].forEach((v) {
//         currencies?.add(Currencies.fromJson(v));
//       });
//     }
//     if (json['suppliers'] != null) {
//       suppliers = [];
//       json['suppliers'].forEach((v) {
//         suppliers?.add(Suppliers.fromJson(v));
//       });
//     }
//     if (json['taxes'] != null) {
//       taxes = [];
//       json['taxes'].forEach((v) {
//         taxes?.add(Taxes.fromJson(v));
//       });
//     }
//     if (json['financial_account'] != null) {
//       financialAccount = [];
//       json['financial_account'].forEach((v) {
//         financialAccount?.add(FinancialAccount.fromJson(v));
//       });
//     }
//     if (json['products'] != null) {
//       products = [];
//       json['products'].forEach((v) {
//         products?.add(Products.fromJson(v));
//       });
//     }
//     if (json['variations'] != null) {
//       variations = [];
//       json['variations'].forEach((v) {
//         variations?.add(Dynamic.fromJson(v));
//       });
//     }
//   }
//   List<Purchases>? purchases;
//   List<Warehouses>? warehouses;
//   List<Currencies>? currencies;
//   List<Suppliers>? suppliers;
//   List<Taxes>? taxes;
//   List<FinancialAccount>? financialAccount;
//   List<Products>? products;
//   List<dynamic>? variations;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (purchases != null) {
//       map['purchases'] = purchases?.map((v) => v.toJson()).toList();
//     }
//     if (warehouses != null) {
//       map['warehouses'] = warehouses?.map((v) => v.toJson()).toList();
//     }
//     if (currencies != null) {
//       map['currencies'] = currencies?.map((v) => v.toJson()).toList();
//     }
//     if (suppliers != null) {
//       map['suppliers'] = suppliers?.map((v) => v.toJson()).toList();
//     }
//     if (taxes != null) {
//       map['taxes'] = taxes?.map((v) => v.toJson()).toList();
//     }
//     if (financialAccount != null) {
//       map['financial_account'] = financialAccount?.map((v) => v.toJson()).toList();
//     }
//     if (products != null) {
//       map['products'] = products?.map((v) => v.toJson()).toList();
//     }
//     if (variations != null) {
//       map['variations'] = variations?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
//
// }
//
// class Products {
//   Products({
//       this.id,
//       this.name,});
//
//   Products.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }
//
// class FinancialAccount {
//   FinancialAccount({
//       this.id,
//       this.name,});
//
//   FinancialAccount.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }
//
// class Taxes {
//   Taxes({
//       this.id,
//       this.name,});
//
//   Taxes.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }
//
// class Suppliers {
//   Suppliers({
//       this.id,
//       this.username,});
//
//   Suppliers.fromJson(dynamic json) {
//     id = json['_id'];
//     username = json['username'];
//   }
//   String? id;
//   String? username;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['username'] = username;
//     return map;
//   }
//
// }
//
// class Currencies {
//   Currencies({
//       this.id,
//       this.name,});
//
//   Currencies.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }
//
// class Warehouses {
//   Warehouses({
//       this.id,
//       this.name,});
//
//   Warehouses.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }
//
// class Purchases {
//   Purchases({
//       this.id,
//       this.date,
//       this.warehouseId,
//       this.supplierId,
//       this.currencyId,
//       this.taxId,
//       this.shipingCost,
//       this.discount,});
//
//   Purchases.fromJson(dynamic json) {
//     id = json['_id'];
//     date = json['date'];
//     if (json['warehouse_id'] != null) {
//       warehouseId = [];
//       json['warehouse_id'].forEach((v) {
//         warehouseId?.add(WarehouseId.fromJson(v));
//       });
//     }
//     if (json['supplier_id'] != null) {
//       supplierId = [];
//       json['supplier_id'].forEach((v) {
//         supplierId?.add(Dynamic.fromJson(v));
//       });
//     }
//     if (json['currency_id'] != null) {
//       currencyId = [];
//       json['currency_id'].forEach((v) {
//         currencyId?.add(CurrencyId.fromJson(v));
//       });
//     }
//     if (json['tax_id'] != null) {
//       taxId = [];
//       json['tax_id'].forEach((v) {
//         taxId?.add(TaxId.fromJson(v));
//       });
//     }
//     shipingCost = json['shiping_cost'];
//     discount = json['discount'];
//   }
//   String? id;
//   String? date;
//   List<WarehouseId>? warehouseId;
//   List<dynamic>? supplierId;
//   List<CurrencyId>? currencyId;
//   List<TaxId>? taxId;
//   num? shipingCost;
//   num? discount;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['date'] = date;
//     if (warehouseId != null) {
//       map['warehouse_id'] = warehouseId?.map((v) => v.toJson()).toList();
//     }
//     if (supplierId != null) {
//       map['supplier_id'] = supplierId?.map((v) => v.toJson()).toList();
//     }
//     if (currencyId != null) {
//       map['currency_id'] = currencyId?.map((v) => v.toJson()).toList();
//     }
//     if (taxId != null) {
//       map['tax_id'] = taxId?.map((v) => v.toJson()).toList();
//     }
//     map['shiping_cost'] = shipingCost;
//     map['discount'] = discount;
//     return map;
//   }
//
// }
//
// class TaxId {
//   TaxId({
//       this.id,
//       this.name,});
//
//   TaxId.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }
//
// class CurrencyId {
//   CurrencyId({
//       this.id,
//       this.name,});
//
//   CurrencyId.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }
//
// class WarehouseId {
//   WarehouseId({
//       this.id,
//       this.name,});
//
//   WarehouseId.fromJson(dynamic json) {
//     id = json['_id'];
//     name = json['name'];
//   }
//   String? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = id;
//     map['name'] = name;
//     return map;
//   }
//
// }

// import 'package:GoSystem/features/admin/admins_screen/model/admins_model.dart';
// import 'package:GoSystem/features/admin/product/models/product_model.dart';
// import 'package:GoSystem/features/admin/revenue/model/revenue_model.dart';
// import 'package:GoSystem/features/admin/taxes/model/taxes_model.dart';

// class PurchaseResponse {
//   final bool success;
//   final PurchaseData data;

//   PurchaseResponse({required this.success, required this.data});

//   factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
//     return PurchaseResponse(
//       success: json['success'] as bool,
//       data: PurchaseData.fromJson(json['data'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'success': success, 'data': data.toJson()};
//   }
// }

// class PurchaseData {
//   final PurchaseStats stats;
//   final PurchaseLists purchases;

//   PurchaseData({required this.stats, required this.purchases});

//   factory PurchaseData.fromJson(Map<String, dynamic> json) {
//     return PurchaseData(
//       stats: PurchaseStats.fromJson(json['stats'] as Map<String, dynamic>),
//       purchases: PurchaseLists.fromJson(json['purchases'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'stats': stats.toJson(),
//       'purchases': purchases.toJson(),
//     };
//   }
// }

// class PurchaseStats {
//   final num totalPurchases;
//   final num fullCount;
//   final num laterCount;
//   final num partialCount;
//   final num totalAmount;
//   final num fullAmount;
//   final num laterAmount;
//   final num partialAmount;

//   PurchaseStats({
//     required this.totalPurchases,
//     required this.fullCount,
//     required this.laterCount,
//     required this.partialCount,
//     required this.totalAmount,
//     required this.fullAmount,
//     required this.laterAmount,
//     required this.partialAmount,
//   });

//   factory PurchaseStats.fromJson(Map<String, dynamic> json) {
//     return PurchaseStats(
//       totalPurchases: json['total_purchases'] as num? ?? 0,
//       fullCount: json['full_count'] as num? ?? 0,
//       laterCount: json['later_count'] as num? ?? 0,
//       partialCount: json['partial_count'] as num? ?? 0,
//       totalAmount: json['total_amount'] as num? ?? 0,
//       fullAmount: json['full_amount'] as num? ?? 0,
//       laterAmount: json['later_amount'] as num? ?? 0,
//       partialAmount: json['partial_amount'] as num? ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'total_purchases': totalPurchases,
//       'full_count': fullCount,
//       'later_count': laterCount,
//       'partial_count': partialCount,
//       'total_amount': totalAmount,
//       'full_amount': fullAmount,
//       'later_amount': laterAmount,
//       'partial_amount': partialAmount,
//     };
//   }
// }

// class PurchaseLists {
//   final List<PurchaseModel> full;
//   final List<PurchaseModel> later;
//   final List<PurchaseModel> partial;

//   PurchaseLists({
//     required this.full,
//     required this.later,
//     required this.partial,
//   });

//   factory PurchaseLists.fromJson(Map<String, dynamic> json) {
//     return PurchaseLists(
//       full: (json['full'] as List? ?? [])
//           .map((e) => PurchaseModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       later: (json['later'] as List? ?? [])
//           .map((e) => PurchaseModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       partial: (json['partial'] as List? ?? [])
//           .map((e) => PurchaseModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'full': full.map((e) => e.toJson()).toList(),
//       'later': later.map((e) => e.toJson()).toList(),
//       'partial': partial.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// class PurchaseModel {
//   final String id;
//   final String date;
//   final WarehouseModel? warehouse;
//   final Supplier? supplier;
//   final TaxModel? tax;
//   final String receiptImg;
//   final String paymentStatus;
//   final num exchangeRate;
//   final num total;
//   final num discount;
//   final num shippingCost;
//   final num grandTotal;
//   final String? note;
//   final String reference;
//   final List<PurchaseItem> items;
//   final List<InvoiceModel> invoices;
//   final List<DuePaymentModel> duePayments;

//   PurchaseModel({
//     required this.id,
//     required this.date,
//     this.warehouse,
//     this.supplier,
//     this.tax,
//     required this.receiptImg,
//     required this.paymentStatus,
//     required this.exchangeRate,
//     required this.total,
//     required this.discount,
//     required this.shippingCost,
//     required this.grandTotal,
//     this.note,
//     required this.reference,
//     required this.items,
//     required this.invoices,
//     required this.duePayments,
//   });

//   factory PurchaseModel.fromJson(Map<String, dynamic> json) {
//     return PurchaseModel(
//       id: json['_id'] as String,
//       date: json['date'] as String,
//       warehouse: json['warehouse_id'] != null && json['warehouse_id'] is Map
//           ? WarehouseModel.fromJson(json['warehouse_id'])
//           : null,
//       supplier: json['supplier_id'] != null && json['supplier_id'] is Map
//           ? Supplier.fromJson(json['supplier_id'])
//           : null,
//       tax: json['tax_id'] != null && json['tax_id'] is Map
//           ? TaxModel.fromJson(json['tax_id'])
//           : null,
//       receiptImg: json['receipt_img'] as String? ?? '',
//       paymentStatus: json['payment_status'] as String? ?? '',
//       exchangeRate: json['exchange_rate'] as num? ?? 0,
//       total: json['total'] as num? ?? 0,
//       discount: json['discount'] as num? ?? 0,
//       shippingCost: json['shipping_cost'] as num? ?? 0,
//       grandTotal: json['grand_total'] as num? ?? 0,
//       note: json['note'] as String?,
//       reference: json['reference'] as String? ?? '',
//       items: (json['items'] as List? ?? [])
//           .map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       invoices: (json['invoices'] as List? ?? [])
//           .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       duePayments: (json['duePayments'] as List? ?? [])
//           .map((e) => DuePaymentModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'date': date,
//       'warehouse_id': warehouse?.toJson(),
//       'supplier_id': supplier?.toJson(),
//       'tax_id': tax?.toJson(),
//       'receipt_img': receiptImg,
//       'payment_status': paymentStatus,
//       'exchange_rate': exchangeRate,
//       'total': total,
//       'discount': discount,
//       'shipping_cost': shippingCost,
//       'grand_total': grandTotal,
//       'note': note,
//       'reference': reference,
//       'items': items.map((e) => e.toJson()).toList(),
//       'invoices': invoices.map((e) => e.toJson()).toList(),
//       'duePayments': duePayments.map((e) => e.toJson()).toList(),
//     };
//   }
// }


// class PurchaseItem {
//   final String id;
//   final Product? product;
//   final CategoryModel? category;
//   final String? warehouseId; // In items, this is often just an ID string
//   final num quantity;
//   final num unitCost;
//   final num subtotal;
//   final num discountShare;
//   final num unitCostAfterDiscount;
//   final num tax;
//   final List<ItemOption> options;

//   PurchaseItem({
//     required this.id,
//     this.product,
//     this.category,
//     this.warehouseId,
//     required this.quantity,
//     required this.unitCost,
//     required this.subtotal,
//     required this.discountShare,
//     required this.unitCostAfterDiscount,
//     required this.tax,
//     required this.options,
//   });

//   factory PurchaseItem.fromJson(Map<String, dynamic> json) {
//     return PurchaseItem(
//       id: json['_id'] as String,
//       product: json['product_id'] != null && json['product_id'] is Map
//           ? Product.fromJson(json['product_id'])
//           : null,
//       category: json['category_id'] != null && json['category_id'] is Map
//           ? CategoryModel.fromJson(json['category_id'])
//           : null,
//       // Handle warehouseId generally appearing as a String here in the items list
//       warehouseId: json['warehouse_id'] is String ? json['warehouse_id'] : null,
//       quantity: json['quantity'] as num? ?? 0,
//       unitCost: json['unit_cost'] as num? ?? 0,
//       subtotal: json['subtotal'] as num? ?? 0,
//       discountShare: json['discount_share'] as num? ?? 0,
//       unitCostAfterDiscount: json['unit_cost_after_discount'] as num? ?? 0,
//       tax: json['tax'] as num? ?? 0,
//       options: (json['options'] as List? ?? [])
//           .map((e) => ItemOption.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'product_id': product?.toJson(),
//       'category_id': category?.toJson(),
//       'warehouse_id': warehouseId,
//       'quantity': quantity,
//       'unit_cost': unitCost,
//       'subtotal': subtotal,
//       'discount_share': discountShare,
//       'unit_cost_after_discount': unitCostAfterDiscount,
//       'tax': tax,
//       'options': options.map((e) => e.toJson()).toList(),
//     };
//   }
// }




// class ItemOption {
//   final String id;
//   final num quantity;
//   final OptionDetail? optionDetail;
//   final ProductPriceDetail? productPrice;

//   ItemOption({
//     required this.id,
//     required this.quantity,
//     this.optionDetail,
//     this.productPrice,
//   });

//   factory ItemOption.fromJson(Map<String, dynamic> json) {
//     return ItemOption(
//       id: json['_id'] as String,
//       quantity: json['quantity'] as num? ?? 0,
//       optionDetail: json['option_id'] != null
//           ? OptionDetail.fromJson(json['option_id'])
//           : null,
//       productPrice: json['product_price_id'] != null
//           ? ProductPriceDetail.fromJson(json['product_price_id'])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'quantity': quantity,
//       'option_id': optionDetail?.toJson(),
//       'product_price_id': productPrice?.toJson(),
//     };
//   }
// }

// class OptionDetail {
//   final String id;
//   final String name;

//   OptionDetail({required this.id, required this.name});

//   factory OptionDetail.fromJson(Map<String, dynamic> json) {
//     return OptionDetail(
//       id: json['_id'] as String,
//       name: json['name'] as String? ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'_id': id, 'name': name};
//   }
// }

// class ProductPriceDetail {
//   final String id;
//   final String code;
//   final num price;
//   final num quantity;

//   ProductPriceDetail({
//     required this.id,
//     required this.code,
//     required this.price,
//     required this.quantity,
//   });

//   factory ProductPriceDetail.fromJson(Map<String, dynamic> json) {
//     return ProductPriceDetail(
//       id: json['_id'] as String,
//       code: json['code'] as String? ?? '',
//       price: json['price'] as num? ?? 0,
//       quantity: json['quantity'] as num? ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'code': code,
//       'price': price,
//       'quantity': quantity,
//     };
//   }
// }

// class InvoiceModel {
//   final String id;
//   final num amount;
//   final String date;

//   InvoiceModel({required this.id, required this.amount, required this.date});

//   factory InvoiceModel.fromJson(Map<String, dynamic> json) {
//     return InvoiceModel(
//       id: json['_id'] as String,
//       amount: json['amount'] as num? ?? 0,
//       date: json['date'] as String? ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'_id': id, 'amount': amount, 'date': date};
//   }
// }

// class DuePaymentModel {
//   final String id;
//   final num amount;
//   final String date;

//   DuePaymentModel({required this.id, required this.amount, required this.date});

//   factory DuePaymentModel.fromJson(Map<String, dynamic> json) {
//     return DuePaymentModel(
//       id: json['_id'] as String,
//       amount: json['amount'] as num? ?? 0,
//       date: json['date'] as String? ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'_id': id, 'amount': amount, 'date': date};
//   }
// }

// // Supplier model for embedded objects in purchases
// class Supplier {
//   final String id;
//   final String image;
//   final String username;
//   final String email;
//   final String phoneNumber;
//   final String address;
//   final String companyName;
//   final String cityId;
//   final String countryId;

//   Supplier({
//     required this.id,
//     required this.image,
//     required this.username,
//     required this.email,
//     required this.phoneNumber,
//     required this.address,
//     required this.companyName,
//     required this.cityId,
//     required this.countryId,
//   });

//   factory Supplier.fromJson(Map<String, dynamic> json) {
//     return Supplier(
//       id: json['_id'] as String? ?? '',
//       image: json['image'] as String? ?? '',
//       username: json['username'] as String? ?? '',
//       email: json['email'] as String? ?? '',
//       phoneNumber: json['phone_number'] as String? ?? '',
//       address: json['address'] as String? ?? '',
//       companyName: json['company_name'] as String? ?? '',
//       cityId: json['cityId'] as String? ?? '',
//       countryId: json['countryId'] as String? ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'image': image,
//       'username': username,
//       'email': email,
//       'phone_number': phoneNumber,
//       'address': address,
//       'company_name': companyName,
//       'cityId': cityId,
//       'countryId': countryId,
//     };
//   }
// }

// main response model
import '../../product/models/product_model.dart' as product_model;

class PurchaseResponse {
  final bool success;
  final PurchaseData data;

  PurchaseResponse({
    required this.success,
    required this.data,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      success: json['success'] ?? false,
      data: PurchaseData.fromJson(json['data'] ?? {}),
    );
  }
}

// data model
class PurchaseData {
  final PurchaseStats stats;
  final Purchases purchases;

  PurchaseData({
    required this.stats,
    required this.purchases,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) {
    return PurchaseData(
      stats: PurchaseStats.fromJson(json['stats'] ?? {}),
      purchases: Purchases.fromJson(json['purchases'] ?? {}),
    );
  }
}

// stats model
class PurchaseStats {
  final int totalPurchases;
  final int fullCount;
  final int laterCount;
  final int partialCount;
  final int totalAmount;
  final int fullAmount;
  final int laterAmount;
  final int partialAmount;

  PurchaseStats({
    required this.totalPurchases,
    required this.fullCount,
    required this.laterCount,
    required this.partialCount,
    required this.totalAmount,
    required this.fullAmount,
    required this.laterAmount,
    required this.partialAmount,
  });

  factory PurchaseStats.fromJson(Map<String, dynamic> json) {
    return PurchaseStats(
      totalPurchases: json['total_purchases'] ?? 0,
      fullCount: json['full_count'] ?? 0,
      laterCount: json['later_count'] ?? 0,
      partialCount: json['partial_count'] ?? 0,
      totalAmount: json['total_amount'] ?? 0,
      fullAmount: json['full_amount'] ?? 0,
      laterAmount: json['later_amount'] ?? 0,
      partialAmount: json['partial_amount'] ?? 0,
    );
  }
}

class Purchases {
  final List<Purchase> full;
  final List<Purchase> later;
  final List<Purchase> partial;

  Purchases({
    required this.full,
    required this.later,
    required this.partial,
  });

  factory Purchases.fromJson(Map<String, dynamic> json) {
    return Purchases(
      full: List<Purchase>.from(
          (json['full'] ?? []).map((x) => Purchase.fromJson(x))),
      later: List<Purchase>.from(
          (json['later'] ?? []).map((x) => Purchase.fromJson(x))),
      partial: List<Purchase>.from(
          (json['partial'] ?? []).map((x) => Purchase.fromJson(x))),
    );
  }
}

// purchase model
class Purchase {
  final String id;
  final DateTime date;
  final Warehouse warehouse;
  final Supplier supplier;
  final Tax? tax;
  final String receiptImg;
  final String paymentStatus;
  final double exchangeRate;
  final double total;
  final double discount;
  final double shippingCost;
  final double grandTotal;
  final String? note;
  final String reference;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final List<PurchaseItem> items;
  final List<Invoice> invoices;
  final List<DuePayment> duePayments;

  // Additional fields from older entries
  final List<String>? currencyId;
  final double? subtotal;

  Purchase({
    required this.id,
    required this.date,
    required this.warehouse,
    required this.supplier,
    required this.tax,
    required this.receiptImg,
    required this.paymentStatus,
    required this.exchangeRate,
    required this.total,
    required this.discount,
    required this.shippingCost,
    required this.grandTotal,
    this.note,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.items,
    required this.invoices,
    required this.duePayments,
    this.currencyId,
    this.subtotal,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? json['_id'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      warehouse: Warehouse.fromJson(json['warehouse_id'] ?? {}),
      supplier: Supplier.fromJson(json['supplier_id'] ?? {}),
      tax: json['tax_id'] != null ? Tax.fromJson(json['tax_id']) : null,
      receiptImg: json['receipt_img'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      exchangeRate: (json['exchange_rate'] ?? 1).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      shippingCost: (json['shipping_cost'] ?? json['shiping_cost'] ?? 0)
          .toDouble(),
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
      note: json['note'],
      reference: json['reference'] ?? '',
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
      items: List<PurchaseItem>.from(
          (json['items'] ?? []).map((x) => PurchaseItem.fromJson(x))),
      invoices: List<Invoice>.from(
          (json['invoices'] ?? []).map((x) => Invoice.fromJson(x))),
      duePayments: List<DuePayment>.from(
          (json['duePayments'] ?? []).map((x) => DuePayment.fromJson(x))),
      currencyId: json['currency_id'] != null
          ? List<String>.from(json['currency_id'])
          : null,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

// warehouse model
class Warehouse {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int numberOfProducts;
  final int stockQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isOnline;

  Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.numberOfProducts,
    required this.stockQuantity,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isOnline,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      numberOfProducts: json['number_of_products'] ?? 0,
      stockQuantity: json['stock_Quantity'] ?? 0,
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
      isOnline: json['Is_Online'] ?? json['is_online'] ?? false,
    );
  }
}

// supplier model
class Supplier {
  final String id;
  final String image;
  final String username;
  final String email;
  final String phoneNumber;
  final String address;
  final String companyName;
  final String cityId;
  final String countryId;
  final int version;

  Supplier({
    required this.id,
    required this.image,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.companyName,
    required this.cityId,
    required this.countryId,
    required this.version,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? json['_id'] ?? '',
      image: json['image'] ?? json['image_url'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      companyName: json['company_name'] ?? '',
      cityId: json['cityId'] ?? json['city_id'] ?? '',
      countryId: json['countryId'] ?? json['country_id'] ?? '',
      version: json['__v'] ?? 0,
    );
  }
}

// tax model
class Tax {
  final String id;
  final String name;
  final bool status;
  final double amount;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Tax({
    required this.id,
    required this.name,
    required this.status,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? false,
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }
}

// purchase item model
class PurchaseItem {
  final String id;
  final DateTime date;
  final Product? product;
  final Category? category;
  final DateTime? dateOfExpiry;
  final String purchaseId;
  final String warehouseId;
  final String? patchNumber;
  final int quantity;
  final double unitCost;
  final double subtotal;
  final double discountShare;
  final double unitCostAfterDiscount;
  final double tax;
  final String itemType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final List<Option> options;

  PurchaseItem({
    required this.id,
    required this.date,
    this.product,
    this.category,
    this.dateOfExpiry,
    required this.purchaseId,
    required this.warehouseId,
    this.patchNumber,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
    required this.discountShare,
    required this.unitCostAfterDiscount,
    required this.tax,
    required this.itemType,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.options,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] ?? json['_id'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      product: json['product_id'] != null
          ? Product.fromJson(json['product_id'])
          : null,
      category: json['category_id'] != null
          ? Category.fromJson(json['category_id'])
          : null,
      dateOfExpiry: (json['date_of_expiery'] ?? json['date_of_expiry']) != null
          ? DateTime.parse(json['date_of_expiery'] ?? json['date_of_expiry'])
          : null,
      purchaseId: json['purchase_id'] ?? '',
      warehouseId: json['warehouse_id'] ?? '',
      patchNumber: json['patch_number'],
      quantity: (json['quantity'] ?? 0).toInt(),
      unitCost: (json['unit_cost'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountShare: (json['discount_share'] ?? 0).toDouble(),
      unitCostAfterDiscount: (json['unit_cost_after_discount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      itemType: json['item_type'] ?? '',
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
      options: List<Option>.from(
          (json['options'] ?? []).map((x) => Option.fromJson(x))),
    );
  }
}

// product model
class Product {
  final String id;
  final String name;
  final String? arName;
  final String? arDescription;
  final String image;
  final List<String> categoryId;
  final String brandId;
  final String unit;
  final double price;
  final int quantity;
  final String description;
  final bool expAbility;
  final DateTime? dateOfExpiry;
  final int minimumQuantitySale;
  final double wholePrice;
  final int startQuantity;
  final String? taxesId;
  final bool productHasImei;
  final bool showQuantity;
  final int maximumToShow;
  final List<String> galleryProduct;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final double? cost;
  final int? lowStock;

  Product({
    required this.id,
    required this.name,
    this.arName,
    this.arDescription,
    required this.image,
    required this.categoryId,
    required this.brandId,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.description,
    required this.expAbility,
    this.dateOfExpiry,
    required this.minimumQuantitySale,
    required this.wholePrice,
    required this.startQuantity,
    this.taxesId,
    required this.productHasImei,
    required this.showQuantity,
    required this.maximumToShow,
    required this.galleryProduct,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.cost,
    this.lowStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'],
      arDescription: json['ar_description'],
      image: json['image'] ?? json['image_url'] ?? '',
      categoryId: List<String>.from(json['categoryId'] ?? json['category_id'] ?? []),
      brandId: json['brandId'] ?? json['brand_id'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      description: json['description'] ?? '',
      expAbility: json['exp_ability'] ?? false,
      dateOfExpiry: (json['date_of_expiery'] ?? json['date_of_expiry']) != null
          ? DateTime.parse(json['date_of_expiery'] ?? json['date_of_expiry'])
          : null,
      minimumQuantitySale: (json['minimum_quantity_sale'] ?? 0).toInt(),
      wholePrice: (json['whole_price'] ?? 0).toDouble(),
      startQuantity: (json['start_quantaty'] ?? json['start_quantity'] ?? 0).toInt(),
      taxesId: json['taxesId'] ?? json['tax_id'],
      productHasImei: json['product_has_imei'] ?? false,
      showQuantity: json['show_quantity'] ?? true,
      maximumToShow: (json['maximum_to_show'] ?? 0).toInt(),
      galleryProduct: List<String>.from(json['gallery_product'] ?? []),
      isFeatured: json['is_featured'] ?? false,
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
      cost: (json['cost'] ?? 0).toDouble(),
      lowStock: (json['low_stock'] ?? 0).toInt(),
    );
  }
}

// category model
class Category {
  final String id;
  final String name;
  final String? arName;
  final String image;
  final int productQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Category({
    required this.id,
    required this.name,
    this.arName,
    required this.image,
    required this.productQuantity,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'],
      image: json['image'] ?? json['image_url'] ?? '',
      productQuantity: json['product_quantity'] ?? 0,
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }
}

// option model (for product variations)
class Option {
  final String id;
  final String purchaseItemId;
  final OptionDetails? option;
  final int quantity;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Option({
    required this.id,
    required this.purchaseItemId,
    this.option,
    required this.quantity,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? json['_id'] ?? '',
      purchaseItemId: json['purchase_item_id'] ?? '',
      option: json['option_id'] != null
          ? OptionDetails.fromJson(json['option_id'])
          : null,
      quantity: (json['quantity'] ?? 0).toInt(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }
}

// option details model
class OptionDetails {
  final String id;
  final String variationId;
  final String name;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  OptionDetails({
    required this.id,
    required this.variationId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory OptionDetails.fromJson(Map<String, dynamic> json) {
    return OptionDetails(
      id: json['id'] ?? json['_id'] ?? '',
      variationId: json['variationId'] ?? json['variation_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? false,
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }
}

// invoice model
class Invoice {
  final String id;
  final List<String> purchaseId;
  final List<String> financialId;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Invoice({
    required this.id,
    required this.purchaseId,
    required this.financialId,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? json['_id'] ?? '',
      purchaseId: List<String>.from(json['purchase_id'] ?? []),
      financialId: List<String>.from(json['financial_id'] ?? []),
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }
}

// due payment model
class DuePayment {
  final String id;
  final List<String> purchaseId;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  DuePayment({
    required this.id,
    required this.purchaseId,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory DuePayment.fromJson(Map<String, dynamic> json) {
    return DuePayment(
      id: json['id'] ?? json['_id'] ?? '',
      purchaseId: List<String>.from(json['purchase_id'] ?? []),
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }
}


// models/purchase_item_model.dart
class PurchaseItemModel {
  final String productId;
  final String productCode;
  final int quantity;
  final DateTime? dateOfExpiery;
  final double unitCost;
  final double discount;
  final double tax;
  final double subtotal;
  
  // For UI reference
  final product_model.Product product;

  PurchaseItemModel({
    required this.productId,
    required this.productCode,
    required this.quantity,
    this.dateOfExpiery,
    required this.unitCost,
    required this.discount,
    required this.tax,
    required this.subtotal,
    required this.product,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_code': productCode,
      'product_id': productId,
      'date': dateOfExpiery?.toIso8601String().split('T')[0],
      'quantity': quantity,
      'date_of_expiery': dateOfExpiery?.toIso8601String().split('T')[0],
      'unit_cost': unitCost,
      'discount': discount,
      'tax': tax,
      'subtotal': subtotal,
    };
  }
}

class PaymentModel {
  final String financialId;
  final double paymentAmount;
  final DateTime? date;

  PaymentModel({
    required this.financialId,
    required this.paymentAmount,
    this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'financial_id': financialId,
      'payment_amount': paymentAmount,
      if (date != null) 'date': date!.toIso8601String().split('T')[0],
    };
  }
}

class DuePaymentModel {
  final double amount;
  final DateTime date;

  DuePaymentModel({
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
    };
  }
}
