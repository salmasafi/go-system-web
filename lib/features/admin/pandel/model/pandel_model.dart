class PandelResponse {
  final bool success;
  final PandelData data;

  PandelResponse({required this.success, required this.data});

  factory PandelResponse.fromJson(Map<String, dynamic> json) {
    return PandelResponse(
      success: json['success'] as bool,
      data: PandelData.fromJson(json['data']),
    );
  }
}

class PandelData {
  final String message;
  final List<PandelModel> pandels;

  PandelData({required this.message, required this.pandels});

  factory PandelData.fromJson(Map<String, dynamic> json) {
    return PandelData(
      message: json['message'] ?? '',
      pandels: (json['pandels'] as List? ?? [])
          .map((e) => PandelModel.fromJson(e))
          .toList(),
    );
  }
}

class PandelModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool status;
  final List<String> images;
  final List<PandelProduct> products;
  final double price;
  final bool allWarehouses;
  final List<String>? warehouseIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  PandelModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.images,
    required this.products,
    required this.price,
    required this.allWarehouses,
    this.warehouseIds,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory PandelModel.fromJson(Map<String, dynamic> json) {
    // API returns the products array under "products" key
    final rawProducts = json['products'] as List? ?? [];
    return PandelModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      startDate: DateTime.parse(json['startdate']),
      endDate: DateTime.parse(json['enddate']),
      status: json['status'] ?? false,
      images: List<String>.from(json['images'] ?? []),
      products: rawProducts.map((e) => PandelProduct.fromJson(e)).toList(),
      price: (json['price'] as num).toDouble(),
      allWarehouses: json['all_warehouses'] ?? true,
      warehouseIds: json['all_warehouses'] == false 
          ? List<String>.from(json['warehouse_ids'] ?? [])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      '_id': id,
      'name': name,
      'startdate': startDate.toIso8601String(),
      'enddate': endDate.toIso8601String(),
      'status': status,
      'images': images,
      'products': products.map((e) => e.toJson()).toList(),
      'price': price,
      'all_warehouses': allWarehouses,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
    
    if (!allWarehouses && warehouseIds != null) {
      json['warehouse_ids'] = warehouseIds!;
    }
    
    return json;
  }
}

/// Represents a product entry in a pandel bundle.
/// Matches the API shape: { productId: { _id, name, ... }, quantity }
class PandelProduct {
  final String productId;
  final int quantity;

  // Extra fields from the nested productId object (read-only, not sent to API)
  final String? productName;
  final String? productArName;
  final String? productImage;
  final double? productPrice;

  PandelProduct({
    required this.productId,
    required this.quantity,
    this.productName,
    this.productArName,
    this.productImage,
    this.productPrice,
  });

  factory PandelProduct.fromJson(Map<String, dynamic> json) {
    // productId can be a nested object or a plain string ID
    final rawProductId = json['productId'];
    final String resolvedProductId;
    String? productName;
    String? productArName;
    String? productImage;
    double? productPrice;

    if (rawProductId is Map<String, dynamic>) {
      resolvedProductId = rawProductId['_id'] ?? '';
      productName = rawProductId['name'];
      productArName = rawProductId['ar_name'];
      productImage = rawProductId['image'];
      productPrice = (rawProductId['price'] as num?)?.toDouble();
    } else {
      resolvedProductId = rawProductId?.toString() ?? '';
    }

    return PandelProduct(
      productId: resolvedProductId,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      productName: productName,
      productArName: productArName,
      productImage: productImage,
      productPrice: productPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
