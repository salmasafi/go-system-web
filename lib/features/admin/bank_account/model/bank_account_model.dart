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

    if (json['warehouseId'] is String) {
      warehouseId = json['warehouseId'] as String;
    } else if (json['warehouseId'] is Map<String, dynamic>) {
      warehouseId = json['warehouseId']['_id'] as String? ?? '';
      warehouseName = json['warehouseId']['name'] as String?;
    } else if (json['warhouseId'] is String) {
      // handle typo in some items
      warehouseId = json['warhouseId'] as String;
    }

    return BankAccountModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      wareHouseId: warehouseId,
      warehouseName: warehouseName,
      image: json['image']?.toString() ?? "",
      status: json['status'] as bool,
      inPos: json['in_POS'] as bool? ?? json['in_pos'] as bool? ?? false,
      description: json['description']?.toString() ?? "",
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['__v'] as int,
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
