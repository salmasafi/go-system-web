//import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
//#import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer';
import 'package:systego/core/services/endpoints.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/utils/error_handler.dart';
//import '../../../core/services/cache_helper.dart.dart';
import '../model/notification_model.dart';
part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial()) {
    // # _initSocket(); // Auto-connect on cubit creation
  }

  static NotificationsCubit get(context) => BlocProvider.of(context);

  //#IO.Socket? _socket;
  //int _unreadCount = 0; // Local tracker for efficiency
  //List<NotificationModel> _cachedNotifications = []; // Cache for appending new ones

  //# void _initSocket() {
  //   // Fixed URL without port 0; use https://bcknd.systego.net
  //   _socket = IO.io(
  //     'https://Bcknd.systego.net', // Correct base URL (no port 0)
  //     IO.OptionBuilder()
  //         .setTransports(['websocket']) // Use WebSocket only
  //         .disableAutoConnect() // Prevent auto-connect (like reference)
  //         .setExtraHeaders({
  //           'Authorization':
  //               'Bearer ${CacheHelper.getData(key: 'token')}', // Auth token (keep if needed)
  //         })
  //         .build(),
  //   );

  // Setup listeners before connect
  //# _socket?.onConnect((_) {
  //   log('Socket connected');
  //   _socket?.emit(
  //     'join_notifications',
  //   ); // Optional: Join room for user-specific events
  // });

  //# _socket?.onDisconnect((_) => log('Socket disconnected'));

  //# _socket?.on('notification', (data) {
  //   // Parse data (new notification event - increment unread)
  //   Map<String, dynamic> payload;
  //   if (data is String) {
  //     payload = jsonDecode(data);
  //   } else if (data is Map<String, dynamic>) {
  //     payload = data;
  //   } else {
  //     log('Invalid notification data: $data');
  //     return;
  //   }

  //   // Assume payload is the new notification JSON
  //   final newNotification = NotificationModel.fromJson(payload);
  //   if (newNotification.isRead == false) {
  //     _unreadCount++; // Increment for new unread
  //   }

  //   // Append to cached list
  //   _cachedNotifications.insert(0, newNotification); // Add to top (newest first)

  //   log('New notification received: ${newNotification.message} (Unread now: $_unreadCount)');
  //   _emitUpdatedState(); // Update UI with new count/list
  // });

  //# _socket?.onError((error) => log('Socket error: $error'));

  //# Connect manually after setup (like reference)
  //# _socket?.connect();
  //}

  Future<void> getNotifications() async {
    emit(NotificationsLoading());

    try {
      log('Starting notifications request...');

      final response = await DioHelper.getData(url: EndPoint.getNotifications);

      log('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final notificationsJson =
              data['data']['notifications'] as List<dynamic>? ?? [];
          final notifications = notificationsJson
              .map(
                (json) =>
                    NotificationModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          final unreadCount = data['data']['unreadCount'] as int? ?? 0;
          //# _unreadCount = unreadCount; // Sync local tracker
          //# _cachedNotifications = notifications; // Update cache

          log('Notifications fetch successful');
          emit(
            NotificationsSuccess(
              notifications: notifications,
              unreadCount: unreadCount,
            ),
          );
        } else {
          final errorMessage =
              data['message'] ?? 'Failed to fetch notifications';
          log('Notifications fetch failed: $errorMessage');
          emit(NotificationsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(NotificationsError(errorMessage));
      }
    } catch (error) {
      log('Notifications fetch error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(NotificationsError(errorMessage));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    emit(NotificationsLoading());

    try {
      log('Marking notification as read: $notificationId');

      // Assuming EndPoint.markAsRead is a method that returns the URL with ID, e.g., '/notifications/$notificationId/read'
      // Adjust based on your EndPoint implementation if needed
      final response = await DioHelper.getData(
        url: EndPoint.markAsRead(notificationId), // Replace with actual endpoint method
      //  data: {}, // Empty body if no additional data needed; adjust if required
      );

      log('Mark as read response: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Notification marked as read successfully');
        // Refetch all notifications to update the list and unread count
        await getNotifications();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Mark as read error: $errorMessage');
        emit(NotificationsError(errorMessage));
      }
    } catch (error) {
      log('Mark as read error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(NotificationsError(errorMessage));
    }
  }

  // void _emitUpdatedState() {
  //   // Re-emit current state with updated unreadCount and list (avoids full refetch)
  //   final currentState = state;
  //   if (currentState is NotificationsSuccess) {
  //     emit(
  //       NotificationsSuccess(
  //         notifications: _cachedNotifications, // Updated list
  //         unreadCount: _unreadCount,
  //       ),
  //     );
  //   } else {
  //     // Fallback: Quick refetch if no cached state
  //     getNotifications();
  //   }
  // }

  // void stopListening() {
  //   _socket?.disconnect();
  //   _socket?.dispose();
  //   _socket = null;
  //   log('Socket disconnected');
  // }
}