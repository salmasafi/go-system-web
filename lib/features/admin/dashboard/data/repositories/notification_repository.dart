import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../core/migration/migration_service.dart';
import '../../../../../../core/services/dio_helper.dart';
import '../../../../../../core/services/endpoints.dart';
import '../../../../../../core/supabase/supabase_client.dart';
import '../../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../../core/utils/error_handler.dart';
import '../../model/notification_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  SupabaseNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory SupabaseNotificationModel.fromJson(Map<String, dynamic> json) {
    return SupabaseNotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      relatedId: json['related_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  NotificationModel toLegacyModel() {
    return NotificationModel(
      id: id,
      type: type,
      productId: relatedId ?? '',
      message: body,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: createdAt,
      version: 0,
      title: title,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class NotificationRepositoryInterface {
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<List<NotificationModel>> getAllNotifications();
  Future<int> getUnreadCount();
  Future<bool> markAsRead(String id);
  Future<bool> markAllAsRead();
  void subscribeToNotifications({
    required Function(NotificationModel notification) onNewNotification,
    String? userId,
  });
  void unsubscribeFromNotifications();
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class NotificationRepository implements NotificationRepositoryInterface {
  late final NotificationRepositoryInterface _dataSource;

  NotificationRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('notifications')) {
      log('NotificationRepository: Using Supabase');
      _dataSource = _NotificationSupabaseDataSource();
    } else {
      log('NotificationRepository: Using Dio (legacy)');
      _dataSource = _NotificationDioDataSource();
    }
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() =>
      _dataSource.getUnreadNotifications();

  @override
  Future<List<NotificationModel>> getAllNotifications() =>
      _dataSource.getAllNotifications();

  @override
  Future<int> getUnreadCount() => _dataSource.getUnreadCount();

  @override
  Future<bool> markAsRead(String id) => _dataSource.markAsRead(id);

  @override
  Future<bool> markAllAsRead() => _dataSource.markAllAsRead();

  @override
  void subscribeToNotifications({
    required Function(NotificationModel notification) onNewNotification,
    String? userId,
  }) =>
      _dataSource.subscribeToNotifications(
        onNewNotification: onNewNotification,
        userId: userId,
      );

  @override
  void unsubscribeFromNotifications() => _dataSource.unsubscribeFromNotifications();

  void enableSupabase() {
    MigrationService.enableSupabase('notifications');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('notifications');
    _initializeDataSource();
  }
}

// ─────────────────────────────────────────────
// Supabase Implementation
// ─────────────────────────────────────────────

class _NotificationSupabaseDataSource implements NotificationRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'notifications';

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      log('NotificationSupabase: Fetching unread notifications');
      final response = await _client
          .from(_table)
          .select()
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final model = SupabaseNotificationModel.fromJson(json as Map<String, dynamic>);
        return model.toLegacyModel();
      }).toList();
    } catch (e) {
      log('NotificationSupabase: Error fetching unread notifications - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _client
          .from(_table)
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('is_read', false);
      
      return response.count;
    } catch (e) {
      log('NotificationSupabase: Error getting unread count - $e');
      return 0;
    }
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      log('NotificationSupabase: Fetching all notifications');
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final model = SupabaseNotificationModel.fromJson(json as Map<String, dynamic>);
        return model.toLegacyModel();
      }).toList();
    } catch (e) {
      log('NotificationSupabase: Error fetching notifications - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> markAsRead(String id) async {
    try {
      await _client
          .from(_table)
          .update({'is_read': true})
          .eq('id', id);
      return true;
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      // Typically only updates the logged-in user's unread notifications
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from(_table)
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
      return true;
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  void subscribeToNotifications({
    required Function(NotificationModel notification) onNewNotification,
    String? userId,
  }) {
    final channelName = 'notifications_realtime';
    final targetUserId = userId ?? _client.auth.currentUser?.id;

    _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: targetUserId != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'user_id',
                  value: targetUserId,
                )
              : null,
          callback: (payload) {
            log('NotificationSupabase: Real-time notification received');
            if (payload.newRecord != null) {
              final model = SupabaseNotificationModel.fromJson(payload.newRecord!);
              onNewNotification(model.toLegacyModel());
            }
          },
        )
        .subscribe();
  }

  @override
  void unsubscribeFromNotifications() {
    _client.channel('notifications_realtime').unsubscribe();
  }
}

// ─────────────────────────────────────────────
// Dio (Legacy) Implementation
// ─────────────────────────────────────────────

class _NotificationDioDataSource implements NotificationRepositoryInterface {
  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<int> getUnreadCount() async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<bool> markAsRead(String id) async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<bool> markAllAsRead() async {
    throw UnimplementedError('markAllAsRead not supported via legacy API');
  }

  @override
  void subscribeToNotifications({
    required Function(NotificationModel notification) onNewNotification,
    String? userId,
  }) {
    // No-op for legacy
  }

  @override
  void unsubscribeFromNotifications() {
    // No-op for legacy
  }
}
