class UserModel {
  UserModel({this.success, this.data});

  UserModel.fromJson(dynamic json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  bool? success;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({this.message, this.token, this.user});

  Data.fromJson(dynamic json) {
    message = json['message'];
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  String? message;
  String? token;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['token'] = token;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }
}

class User {
  User({
    this.id,
    this.username,
    this.email,
    this.position,
    this.status,
    this.role,
    this.roles,
    this.actions,
    this.hasOpenShift = false,
    this.warehouseId,
    this.warehouseName,
  });

  User.fromJson(dynamic json) {
    id = json['id'] ?? json['_id'];
    username = json['username'];
    email = json['email'];
    position = json['position'];
    status = json['status'];
    role = json['role'];
    roles = json['roles'] != null ? List<dynamic>.from(json['roles']) : null;
    actions = json['actions'] != null ? List<dynamic>.from(json['actions']) : null;
    hasOpenShift = json['hasOpenShift'] ?? false;
    warehouseId = json['warehouse_id'] ?? json['warehouseId'];
    warehouseName = json['warehouse_name'] ?? json['warehouseName'];
  }

  String? id;
  String? username;
  String? email;
  dynamic position;
  String? status;
  String? role;
  List<dynamic>? roles;
  List<dynamic>? actions;
  bool? hasOpenShift;
  /// UUID of the warehouse this user is assigned to (non-null → cashier/branch user)
  String? warehouseId;
  String? warehouseName;

  /// True when this user is a cashier (has a warehouse assignment)
  bool get isCashier =>
      warehouseId != null && warehouseId!.isNotEmpty && role == 'cashier';

  /// True when this user is admin/owner (can see all branches)
  bool get isAdmin =>
      role == 'admin' || role == 'owner' || role == 'super_admin' ||
      (warehouseId == null || warehouseId!.isEmpty);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['email'] = email;
    map['position'] = position;
    map['status'] = status;
    map['role'] = role;
    map['roles'] = roles;
    map['actions'] = actions;
    map['hasOpenShift'] = hasOpenShift;
    map['warehouse_id'] = warehouseId;
    map['warehouse_name'] = warehouseName;
    return map;
  }
}
