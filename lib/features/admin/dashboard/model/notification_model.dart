// features/notifications/models/notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final String productId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.productId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle productId which can be a String or a Map
    String productIdValue = '';
    final productIdData = json['productId'];
    if (productIdData is String) {
      productIdValue = productIdData;
    } else if (productIdData is Map<String, dynamic>) {
      productIdValue = productIdData['_id'] ?? '';
    }

    return NotificationModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      productId: productIdValue,
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'productId': productId,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}