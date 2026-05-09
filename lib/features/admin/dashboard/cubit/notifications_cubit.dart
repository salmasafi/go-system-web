import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../data/repositories/notification_repository.dart';
import '../model/notification_model.dart';
part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationModel> _cachedNotifications = [];
  int _unreadCount = 0;

  NotificationsCubit() : super(NotificationsInitial()) {
    _initRealtime();
  }

  static NotificationsCubit get(context) => BlocProvider.of(context);

  void _initRealtime() {
    _repository.subscribeToNotifications(
      onNewNotification: (notification) {
        if (isClosed) return;
        _unreadCount++;
        _cachedNotifications.insert(0, notification);
        _emitUpdatedState();
      },
    );
  }

  Future<void> getNotifications() async {
    try {
      emit(NotificationsLoading());
      final notifications = await _repository.getAllNotifications();
      _cachedNotifications = notifications;
      _unreadCount = notifications.where((n) => !n.isRead).length;
      _emitUpdatedState();
    } catch (e) {
      log('NotificationsCubit: getNotifications error - $e');
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final idx = _cachedNotifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        _cachedNotifications[idx] = _cachedNotifications[idx].copyWith(isRead: true);
        _unreadCount = _cachedNotifications.where((n) => !n.isRead).length;
        _emitUpdatedState();
      }
    } catch (e) {
      log('NotificationsCubit: markAsRead error - $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _cachedNotifications = _cachedNotifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      _emitUpdatedState();
    } catch (e) {
      log('NotificationsCubit: markAllAsRead error - $e');
    }
  }

  void _emitUpdatedState() {
    emit(NotificationsSuccess(
      notifications: List.from(_cachedNotifications),
      unreadCount: _unreadCount,
    ));
  }

  @override
  Future<void> close() {
    _repository.unsubscribeFromNotifications();
    return super.close();
  }
}
