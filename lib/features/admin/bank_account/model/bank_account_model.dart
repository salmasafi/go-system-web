class BankAccountResponse {
  final bool success;
  final BankAccountData data;

  BankAccountResponse({required this.success, required this.data});

  factory BankAccountResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountResponse(
      success: json['success'] as bool,
      data: BankAccountData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class BankAccountData {
  final String message;
  final List<BankAccountModel> accounts;
  final double totalBalance;

  BankAccountData({
    required this.message,
    required this.accounts,
    required this.totalBalance,
  });

  factory BankAccountData.fromJson(Map<String, dynamic> json) {
    return BankAccountData(
      message: json['message'] as String,
      accounts: (json['bankAccounts'] as List<dynamic>)
          .map((item) => BankAccountModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalBalance: (json['total'] as num?)?.toDouble() ??
          (json['bankAccounts'] as List<dynamic>)
              .fold(0.0, (sum, item) => sum + (item['balance']?.toDouble() ?? 0.0)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'bankAccounts': accounts.map((e) => e.toJson()).toList(),
      'total': totalBalance,
    };
  }
}

class BankAccountModel {
  final String id;
  final String name;
  final String wareHouseId;
  final String? warehouseName;
  final String image;
  final bool status;
  final bool inPos;
  final String description;
  final double balance;
  final String createdAt;
  final String updatedAt;
  final int version;

  BankAccountModel({
    required this.id,
    required this.name,
    required this.wareHouseId,
    this.warehouseName,
    required this.image,
    required this.status,
    required this.inPos,
    required this.description,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    // Handle warehouseId being either a string or an object
    String warehouseId = '';
    String? warehouseName;

    final warehouseJson = json['warehouse_id'] ?? json['warehouseId'] ?? json['warhouseId'];
    if (warehouseJson is String) {
      warehouseId = warehouseJson;
    } else if (warehouseJson is Map<String, dynamic>) {
      warehouseId = (warehouseJson['id'] ?? warehouseJson['_id'] ?? '').toString();
      warehouseName = warehouseJson['name'] as String?;
    }

    return BankAccountModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      wareHouseId: warehouseId,
      warehouseName: warehouseName,
      image: json['image']?.toString() ?? json['image_url']?.toString() ?? "",
      status: json['status'] as bool? ?? true,
      inPos: json['in_pos'] ?? json['in_POS'] ?? false,
      description: json['description']?.toString() ?? "",
      balance: (json['balance'] ?? json['current_balance'] ?? 0).toDouble(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
      version: json['version'] ?? json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'warehouseId': wareHouseId,
      if (warehouseName != null) 'warehouseName': warehouseName,
      'image': image,
      'status': status,
      'in_POS': inPos,
      'description': description,
      'balance': balance,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}
