// features/notifications/models/notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final String productId;
  final String message;
  final String title;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.productId,
    required this.message,
    this.title = '',
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
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      productId: productIdValue,
      message: json['message'] ?? json['body'] ?? '',
      title: json['title'] ?? '',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'productId': productId,
      'message': message,
      'title': title,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
