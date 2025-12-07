class DepartmentResponse {
  final bool success;
  final DepartmentData data;

  DepartmentResponse({required this.success, required this.data});

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentResponse(
      success: json['success'] as bool,
      data: DepartmentData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class DepartmentData {
  final String message;
  final List<DepartmentModel> departments;

  DepartmentData({required this.message, required this.departments});

  factory DepartmentData.fromJson(Map<String, dynamic> json) {
    return DepartmentData(
      message: json['message'] as String,
      departments: (json['departments'] as List<dynamic>)
          .map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'departments': departments.map((item) => item.toJson()).toList(),
    };
  }
}

class DepartmentModel {
  final String id;
  final String name;
  final String description;
  final String? arName;
  final String? arDescription;
  final String createdAt;
  final String updatedAt;
  final int version;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.arName,
    required this.arDescription,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      arName: json['ar_name'] as String?,
      arDescription: json['ar_description'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'ar_name': arName,
      'ar_description': arDescription,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}
