part of 'notifications_cubit.dart';

// features/notifications/cubit/notifications_state.dart
abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsSuccess({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}
