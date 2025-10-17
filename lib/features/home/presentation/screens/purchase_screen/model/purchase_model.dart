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