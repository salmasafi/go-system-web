class UserModel {
  UserModel({
    this.success,
    this.data,
  });

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
  Data({
    this.message,
    this.token,
    this.user,
  });

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
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    position = json['position'];
    status = json['status'];
    role = json['role'];
    // Fix: Convert dynamic lists to List<dynamic>
    roles = json['roles'] != null ? List<dynamic>.from(json['roles']) : null;
    actions = json['actions'] != null ? List<dynamic>.from(json['actions']) : null;
  }

  String? id;
  String? username;
  String? email;
  dynamic position;
  String? status;
  String? role;
  List<dynamic>? roles;
  List<dynamic>? actions;

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
    return map;
  }
}