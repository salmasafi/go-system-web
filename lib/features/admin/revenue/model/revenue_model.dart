class RevenueResponse {
  final bool success;
  final RevenueData data;

  RevenueResponse({required this.success, required this.data});

  factory RevenueResponse.fromJson(Map<String, dynamic> json) {
    return RevenueResponse(
      success: json['success'] as bool,
      data: RevenueData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class RevenueData {
  final String message;
  final List<RevenueModel> revenues;

  RevenueData({
    required this.message,
    required this.revenues,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      message: json['message'] as String,
      revenues: (json['revenues'] as List<dynamic>)
          .map((item) => RevenueModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'revenues': revenues.map((item) => item.toJson()).toList(),
    };
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String arName;

  CategoryModel({
    required this.id,
    required this.name,
    required this.arName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
    };
  }
}

class AdminModel {
  final String id;
  final String username;

  AdminModel({
    required this.id,
    required this.username,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['_id'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
    };
  }
}

class FinancialAccountModel {
  final String id;
  final String name;

  FinancialAccountModel({
    required this.id,
    required this.name,
  });

  factory FinancialAccountModel.fromJson(Map<String, dynamic> json) {
    return FinancialAccountModel(
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

// class RevenueModel {
//   final String id;
//   final String name;
//   final double amount;
//   final CategoryModel category;
//   final AdminModel? admin; // Fix: Admin might be null in some responses
//   final String? note;
//   final FinancialAccountModel financialAccount;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final int version;

//   RevenueModel({
//     required this.id,
//     required this.name,
//     required this.amount,
//     required this.category,
//      this.admin,
//      this.note,
//     required this.financialAccount,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.version,
//   });

//   factory RevenueModel.fromJson(Map<String, dynamic> json) {
//     return RevenueModel(
//       id: json['_id'] as String,
//       name: json['name'] as String,
//       amount: (json['amount'] as num).toDouble(),
//       // category: CategoryModel.fromJson(
//       //     json['Category_id'] as Map<String, dynamic>),
//       // admin: AdminModel.fromJson(json['admin_id'] as Map<String, dynamic>),
//       // note: json['note'] as String,
//       // Fix: Ensure nested objects aren't null before parsing
//       category: CategoryModel.fromJson(json['Category_id'] as Map<String, dynamic>),
      
//       // Fix: Handle case where admin_id is null or missing
//       admin: json['admin_id'] != null 
//           ? AdminModel.fromJson(json['admin_id'] as Map<String, dynamic>) 
//           : null,
          
//       // Fix: Allow note to be nullable
//       note: json['note'] as String?,
//       financialAccount: FinancialAccountModel.fromJson(
//           json['financial_accountId'] as Map<String, dynamic>),
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: DateTime.parse(json['updatedAt'] as String),
//       version: json['__v'] as int,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'amount': amount,
//       'Category_id': category.toJson(),
//       'admin_id': admin?.toJson(),
//       'note': note,
//       'financial_accountId': financialAccount.toJson(),
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       '__v': version,
//     };
//   }
// }


class RevenueModel {
  final String id;
  final String name;
  final double amount;
  
  // CHANGED: Made these nullable (?) because update responses might not return full objects
  final CategoryModel? category; 
  final AdminModel? admin;
  final FinancialAccountModel? financialAccount;
  
  // CHANGED: Note is often optional/null
  final String? note; 
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  RevenueModel({
    required this.id,
    required this.name,
    required this.amount,
    this.category, // Now optional
    this.admin,    // Now optional
    this.financialAccount, // Now optional
    this.note,     // Now optional
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) {
    return RevenueModel(
      // Use helper to safely get String, defaulting to empty if null
      id: json['_id'] as String? ?? '', 
      name: json['name'] as String? ?? '',
      
      // Safely parse numbers
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,

      // CRITICAL FIX: Check if 'Category_id' exists AND is a Map before parsing.
      // If it's just an ID string (common in updates), this will be null to prevent crash.
      category: (json['Category_id'] is Map<String, dynamic>)
          ? CategoryModel.fromJson(json['Category_id'] as Map<String, dynamic>)
          : null,

      // CRITICAL FIX: Admin is often missing in update responses
      admin: (json['admin_id'] is Map<String, dynamic>)
          ? AdminModel.fromJson(json['admin_id'] as Map<String, dynamic>)
          : null,

      // CRITICAL FIX: Handle note being null
      note: json['note'] as String?, 

      financialAccount: (json['financial_accountId'] is Map<String, dynamic>)
          ? FinancialAccountModel.fromJson(json['financial_accountId'] as Map<String, dynamic>)
          : null,

      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
      version: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'amount': amount,
      'Category_id': category?.toJson(), // Handle null
      'admin_id': admin?.toJson(),       // Handle null
      'note': note,
      'financial_accountId': financialAccount?.toJson(), // Handle null
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}