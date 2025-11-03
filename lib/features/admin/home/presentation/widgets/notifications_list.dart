import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../model/notification_model.dart';
import '../view/notification_details_screen.dart';
import 'notifications_card.dart';

class NotificationsList extends StatelessWidget {
  final List<NotificationModel> notifications;
  const NotificationsList({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return AnimatedNotificationCard(
          notification: notifications[index],
          index: index,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotificationDetailsScreen(notification: notifications[index]),
            ),
          ),
        );
      },
    );
  }

  // void _showDeleteDialog(BuildContext context, NotificationModel notification) {
  //   if (notification.id.isEmpty) {
  //     CustomSnackbar.showError(context, 'Invalid notification ID');
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => CustomDeleteDialog(
  //       title: 'Delete Notification',
  //       message:
  //           'Are you sure you want to delete this notification?\n"${notification.message}"',
  //       onDelete: () {
  //         Navigator.pop(dialogContext);
  //         context.read<NotificationsCubit>().deleteNotification(notification.id);
  //       },
  //     ),
  //   );
  // }
}
