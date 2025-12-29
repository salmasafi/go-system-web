class PandelResponse {
  final bool success;
  final PandelData data;

  PandelResponse({
    required this.success,
    required this.data,
  });

  factory PandelResponse.fromJson(Map<String, dynamic> json) {
    return PandelResponse(
      success: json['success'] as bool,
      data: PandelData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}


class PandelData {
  final String message;
  final List<PandelModel> pandels;

  PandelData({
    required this.message,
    required this.pandels,
  });

  factory PandelData.fromJson(Map<String, dynamic> json) {
    return PandelData(
      message: json['message'],
      pandels: (json['pandels'] as List)
          .map((e) => PandelModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'pandels': pandels.map((e) => e.toJson()).toList(),
    };
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
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory PandelModel.fromJson(Map<String, dynamic> json) {
    return PandelModel(
      id: json['_id'],
      name: json['name'],
      startDate: DateTime.parse(json['startdate']),
      endDate: DateTime.parse(json['enddate']),
      status: json['status'],
      images: List<String>.from(json['images']),
      products: (json['productsId'] as List)
          .map((e) => PandelProduct.fromJson(e))
          .toList(),
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'startdate': startDate.toIso8601String(),
      'enddate': endDate.toIso8601String(),
      'status': status,
      'images': images,
      'productsId': products.map((e) => e.toJson()).toList(),
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}

class PandelProduct {
  final String id;
  final String name;
  final double price;

  PandelProduct({
    required this.id,
    required this.name,
    required this.price,
  });

  factory PandelProduct.fromJson(Map<String, dynamic> json) {
    return PandelProduct(
      id: json['_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
    };
  }
}
