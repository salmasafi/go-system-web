// class TransferResponse {
//   final bool success;
//   final TransferData data;

//   TransferResponse({required this.success, required this.data});

//   factory TransferResponse.fromJson(Map<String, dynamic> json) {
//     return TransferResponse(
//       success: json['success'] as bool,
//       data: TransferData.fromJson(json['data'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'success': success, 'data': data.toJson()};
//   }
// }

// class TransferData {
//   final String message;
//   // API 1 returns 'transfers'
//   final List<TransferModel> allTransfers;
//   // API 2 & 3 return 'pending' and 'done'
//   final List<TransferModel> pending;
//   final List<TransferModel> done;

//   TransferData({
//     required this.message,
//     this.allTransfers = const [],
//     this.pending = const [],
//     this.done = const [],
//   });

//   factory TransferData.fromJson(Map<String, dynamic> json) {
//     return TransferData(
//       message: json['message'] as String? ?? '',
//       // Check if 'transfers' exists (API 1), otherwise empty list
//       allTransfers: (json['transfers'] as List<dynamic>?)
//               ?.map((item) => TransferModel.fromJson(item as Map<String, dynamic>))
//               .toList() ??
//           [],
//       // Check if 'pending' exists (API 2 & 3), otherwise empty list
//       pending: (json['pending'] as List<dynamic>?)
//               ?.map((item) => TransferModel.fromJson(item as Map<String, dynamic>))
//               .toList() ??
//           [],
//       // Check if 'done' exists (API 2 & 3), otherwise empty list
//       done: (json['done'] as List<dynamic>?)
//               ?.map((item) => TransferModel.fromJson(item as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       if (allTransfers.isNotEmpty) 'transfers': allTransfers.map((e) => e.toJson()).toList(),
//       if (pending.isNotEmpty) 'pending': pending.map((e) => e.toJson()).toList(),
//       if (done.isNotEmpty) 'done': done.map((e) => e.toJson()).toList(),
//     };
//   }
  
//   // Helper to get a single unified list for UI if needed
//   List<TransferModel> get unifiedList => [...allTransfers, ...pending, ...done];
// }

// class TransferModel {
//   final String id;
//   final WarehouseModel fromWarehouse;
//   final WarehouseModel toWarehouse;
//   final List<TransferProductModel> products;
//   final String status;
//   final String date;
//   final String reference;

//   TransferModel({
//     required this.id,
//     required this.fromWarehouse,
//     required this.toWarehouse,
//     required this.products,
//     required this.status,
//     required this.date,
//     required this.reference,
//   });

//   factory TransferModel.fromJson(Map<String, dynamic> json) {
//     return TransferModel(
//       id: json['_id'] as String,
//       fromWarehouse: WarehouseModel.fromJson(json['fromWarehouseId'] as Map<String, dynamic>),
//       toWarehouse: WarehouseModel.fromJson(json['toWarehouseId'] as Map<String, dynamic>),
//       products: (json['products'] as List<dynamic>)
//           .map((item) => TransferProductModel.fromJson(item as Map<String, dynamic>))
//           .toList(),
//       status: json['status'] as String,
//       date: json['date'] as String,
//       reference: json['reference'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'fromWarehouseId': fromWarehouse.toJson(),
//       'toWarehouseId': toWarehouse.toJson(),
//       'products': products.map((e) => e.toJson()).toList(),
//       'status': status,
//       'date': date,
//       'reference': reference,
//     };
//   }
// }

// class WarehouseModel {
//   final String id;
//   final String name;

//   WarehouseModel({required this.id, required this.name});

//   factory WarehouseModel.fromJson(Map<String, dynamic> json) {
//     return WarehouseModel(
//       id: json['_id'] as String,
//       name: json['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() => {'_id': id, 'name': name};
// }

// class TransferProductModel {
//   final String id;
//   final int quantity;
//   final ProductDetailModel product;

//   TransferProductModel({
//     required this.id,
//     required this.quantity,
//     required this.product,
//   });

//   factory TransferProductModel.fromJson(Map<String, dynamic> json) {
//     return TransferProductModel(
//       id: json['_id'] as String,
//       quantity: json['quantity'] as int,
//       product: ProductDetailModel.fromJson(json['productId'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'quantity': quantity,
//       'productId': product.toJson(),
//     };
//   }
// }

// class ProductDetailModel {
//   final String id;
//   final String name;

//   ProductDetailModel({required this.id, required this.name});

//   factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
//     return ProductDetailModel(
//       id: json['_id'] as String,
//       name: json['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() => {'_id': id, 'name': name};
// }

class TransferResponse {
  final bool success;
  final TransferData data;

  TransferResponse({required this.success, required this.data});

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      success: json['success'] as bool,
      data: TransferData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class TransferData {
  final String message;
  // For the "All Transfers" API
  final List<TransferModel> allTransfers;
  // For the "In/Out" APIs
  final List<TransferModel> pending;
  final List<TransferModel> done;

  TransferData({
    required this.message,
    this.allTransfers = const [],
    this.pending = const [],
    this.done = const [],
  });

  factory TransferData.fromJson(Map<String, dynamic> json) {
    return TransferData(
      message: json['message'] as String? ?? '',
      // Map 'transfers' list if it exists (API 1)
      allTransfers: (json['transfers'] as List<dynamic>?)
              ?.map((item) => TransferModel.fromJson(item))
              .toList() ??
          [],
      // Map 'pending' list if it exists (API 2 & 3)
      pending: (json['pending'] as List<dynamic>?)
              ?.map((item) => TransferModel.fromJson(item))
              .toList() ??
          [],
      // Map 'done' list if it exists (API 2 & 3)
      done: (json['done'] as List<dynamic>?)
              ?.map((item) => TransferModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  // Helper to combine lists for UI if needed
  List<TransferModel> get combinedFiltered => [...pending, ...done];
}

class TransferModel {
  final String id;
  final WarehouseLiteModel? fromWarehouse;
  final WarehouseLiteModel? toWarehouse;
  final List<TransferProductModel> products;
  final String status; // 'pending', 'done', 'received'
  final String date;
  final String reference;

  TransferModel({
    required this.id,
    this.fromWarehouse,
    this.toWarehouse,
    required this.products,
    required this.status,
    required this.date,
    required this.reference,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      // Handle cases where warehouse might be null or just an ID string (safety check)
      fromWarehouse: (json['from_warehouse_id'] ?? json['fromWarehouseId']) is Map 
          ? WarehouseLiteModel.fromJson(json['from_warehouse_id'] ?? json['fromWarehouseId']) 
          : null,
      toWarehouse: (json['to_warehouse_id'] ?? json['toWarehouseId']) is Map 
          ? WarehouseLiteModel.fromJson(json['to_warehouse_id'] ?? json['toWarehouseId']) 
          : null,
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => TransferProductModel.fromJson(item))
              .toList() ?? [],
      status: json['status'] ?? 'unknown',
      date: (json['created_at'] ?? json['date'] ?? '').toString(),
      reference: json['reference'] ?? '',
    );
  }
}

class WarehouseLiteModel {
  final String id;
  final String name;

  WarehouseLiteModel({required this.id, required this.name});

  factory WarehouseLiteModel.fromJson(Map<String, dynamic> json) {
    return WarehouseLiteModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class TransferProductModel {
  final String id;
  final int quantity;
  final String productName;
  final String productId;

  TransferProductModel({
    required this.id,
    required this.quantity,
    required this.productName,
    required this.productId,
  });

  factory TransferProductModel.fromJson(Map<String, dynamic> json) {
    // Extract product name from nested object
    final productObj = json['product_id'] ?? json['productId']; 
    return TransferProductModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      productName: productObj is Map ? productObj['name'] : 'Unknown Product',
      productId: productObj is Map ? (productObj['id'] ?? productObj['_id'] ?? '').toString() : (productObj ?? '').toString(),
    );
  }
}
