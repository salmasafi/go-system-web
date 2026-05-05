class ExpenseCategoryResponse {
  final bool success;
  final ExpenseCategoryData data;

  ExpenseCategoryResponse({
    required this.success,
    required this.data,
  });

  factory ExpenseCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryResponse(
      success: json['success'] as bool,
      data: ExpenseCategoryData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ExpenseCategoryData {
  final List<ExpenseCategoryModel> expenseCategories;

  ExpenseCategoryData({
    required this.expenseCategories,
  });

  factory ExpenseCategoryData.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryData(
      expenseCategories: (json['expenseCategories'] as List<dynamic>)
          .map((item) => ExpenseCategoryModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseCategories': expenseCategories.map((e) => e.toJson()).toList(),
    };
  }
}

class ExpenseCategoryModel {
  final String id;
  final String name;
  final String arName;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final int version;

  ExpenseCategoryModel copyWith({
    String? id,
    String? name,
    String? arName,
    bool? status,
    String? createdAt,
    String? updatedAt,
    int? version,
  }) {
    return ExpenseCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      arName: arName ?? this.arName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  ExpenseCategoryModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      arName: json['ar_name']?.toString() ?? '',
      status: json['status'] == true || json['status'] == 1,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '',
      version: (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}
