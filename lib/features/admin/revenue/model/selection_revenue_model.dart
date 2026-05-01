class RevenueSelectionDataResponse {
  final bool success;
  final SelectionData data;

  RevenueSelectionDataResponse({required this.success, required this.data});

  factory RevenueSelectionDataResponse.fromJson(Map<String, dynamic> json) {
    return RevenueSelectionDataResponse(
      success: json['success'] as bool,
      data: SelectionData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class SelectionData {
  final String message;
  final List<CategorySelection> categories;
  final List<AccountSelection> accounts;

  SelectionData({
    required this.message,
    required this.categories,
    required this.accounts,
  });

  factory SelectionData.fromJson(Map<String, dynamic> json) {
    return SelectionData(
      message: json['message'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((item) => CategorySelection.fromJson(item as Map<String, dynamic>))
          .toList(),
      accounts: (json['accounts'] as List<dynamic>)
          .map((item) => AccountSelection.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'categories': categories.map((item) => item.toJson()).toList(),
      'accounts': accounts.map((item) => item.toJson()).toList(),
    };
  }
}

class CategorySelection {
  final String id;
  final String name;
  final String arName;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  CategorySelection({
    required this.id,
    required this.name,
    required this.arName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CategorySelection.fromJson(Map<String, dynamic> json) {
    return CategorySelection(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      arName: json['ar_name']?.toString() ?? '',
      status: json['status'] as bool? ?? true,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      version: json['version'] ?? json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}

class AccountSelection {
  final String id;
  final String name;
  final List<String> warehouseId;
  final String? image;
  final double balance;
  final String description;
  final bool status;
  final bool inPOS;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  AccountSelection({
    required this.id,
    required this.name,
    required this.warehouseId,
    this.image,
    required this.balance,
    required this.description,
    required this.status,
    required this.inPOS,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory AccountSelection.fromJson(Map<String, dynamic> json) {
    return AccountSelection(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      warehouseId: (json['warehouse_id'] ?? json['warehouseId'] ?? []) is List
          ? List<String>.from((json['warehouse_id'] ?? json['warehouseId'] ?? []).map((x) => x.toString()))
          : [],
      image: (json['image'] ?? json['image_url'])?.toString(),
      balance: (json['balance'] ?? json['current_balance'] ?? 0).toDouble(),
      description: json['description']?.toString() ?? '',
      status: json['status'] as bool? ?? true,
      inPOS: json['in_pos'] ?? json['in_POS'] ?? false,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      version: json['version'] ?? json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'warehouseId': warehouseId,
      'image': image,
      'balance': balance,
      'description': description,
      'status': status,
      'in_POS': inPOS,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String arName;
  final bool status; // Add this
  final DateTime createdAt; // Add this
  final DateTime updatedAt; // Add this
  final int version; // Add this

  CategoryModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      arName: json['ar_name']?.toString() ?? '',
      status: json['status'] as bool? ?? true,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      version: json['version'] ?? json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}

class FinancialAccountModel {
  final String id;
  final String name;
  final List<String> warehouseId; // Add this
  final String? image; // Add this
  final double balance; // Add this
  final String description; // Add this
  final bool status; // Add this
  final bool inPOS; // Add this
  final DateTime createdAt; // Add this
  final DateTime updatedAt; // Add this
  final int version; // Add this

  FinancialAccountModel({
    required this.id,
    required this.name,
    required this.warehouseId,
    this.image,
    required this.balance,
    required this.description,
    required this.status,
    required this.inPOS,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory FinancialAccountModel.fromJson(Map<String, dynamic> json) {
    return FinancialAccountModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      warehouseId: (json['warehouse_id'] ?? json['warehouseId'] ?? []) is List
          ? List<String>.from((json['warehouse_id'] ?? json['warehouseId'] ?? []).map((x) => x.toString()))
          : [],
      image: (json['image'] ?? json['image_url'])?.toString(),
      balance: (json['balance'] ?? json['current_balance'] ?? 0).toDouble(),
      description: json['description']?.toString() ?? '',
      status: json['status'] as bool? ?? true,
      inPOS: json['in_pos'] ?? json['in_POS'] ?? false,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      version: json['version'] ?? json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'warehouseId': warehouseId,
      'image': image,
      'balance': balance,
      'description': description,
      'status': status,
      'in_POS': inPOS,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
