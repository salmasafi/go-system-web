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
        log('NotificationsCubit: Real-time notification received: ${notification.title}');
        _unreadCount++;
        _cachedNotifications.insert(0, notification);
        _emitUpdatedState();
      },
    );
  }

  Future<void> getNotifications() async {
    emit(NotificationsLoading());

    try {
      log('NotificationsCubit: Fetching notifications...');
      
      final notifications = await _repository.getAllNotifications();
      _unreadCount = await _repository.getUnreadCount();
      _cachedNotifications = notifications;

      log('NotificationsCubit: Fetch successful. Unread: $_unreadCount');
      emit(
        NotificationsSuccess(
          notifications: _cachedNotifications,
          unreadCount: _unreadCount,
        ),
      );
    } catch (error) {
      log('NotificationsCubit: Fetch error: $error');
      emit(NotificationsError(error.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    // Optimistic update
    final index = _cachedNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_cachedNotifications[index].isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      // Create updated notification model if needed, but for now we just refetch after API call
    }

    try {
      log('NotificationsCubit: Marking as read: $notificationId');
      await _repository.markAsRead(notificationId);
      
      // Refetch to ensure data consistency
      await getNotifications();
    } catch (error) {
      log('NotificationsCubit: Mark as read error: $error');
      emit(NotificationsError(error.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    emit(NotificationsLoading());
    try {
      log('NotificationsCubit: Marking all as read');
      await _repository.markAllAsRead();
      await getNotifications();
    } catch (error) {
      log('NotificationsCubit: Mark all as read error: $error');
      emit(NotificationsError(error.toString()));
    }
  }

  void _emitUpdatedState() {
    if (state is NotificationsSuccess) {
      emit(
        NotificationsSuccess(
          notifications: List.from(_cachedNotifications),
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _repository.unsubscribeFromNotifications();
    return super.close();
  }
}
