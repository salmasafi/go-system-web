
class WarehouseProduct {
  final String id;
  final ProductId? productId;
  final String warehouseId;
  final int quantity;
  final int v;

  WarehouseProduct({
    required this.id,
    this.productId,
    required this.warehouseId,
    required this.quantity,
    required this.v,
  });

  factory WarehouseProduct.fromJson(Map<String, dynamic> json) {
    return WarehouseProduct(
      id: json['_id'] as String,
      productId: json['productId'] != null ? ProductId.fromJson(json['productId'] as Map<String, dynamic>) : null,
      warehouseId: json['WarehouseId'] as String,
      quantity: json['quantity'] as int,
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId?.toJson(),
      'WarehouseId': warehouseId,
      'quantity': quantity,
      '__v': v,
    };
  }
}

class ProductId {
  final String id;
  final String name;

  ProductId({
    required this.id,
    required this.name,
  });

  factory ProductId.fromJson(Map<String, dynamic> json) {
    return ProductId(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}
