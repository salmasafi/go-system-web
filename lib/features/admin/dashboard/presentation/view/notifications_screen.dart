import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../cubit/notifications_cubit.dart';
import '../widgets/notifications_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  void notificationsInit() async {
    context.read<NotificationsCubit>().getNotifications();
  }

  @override
  void initState() {
    super.initState();
    notificationsInit();
  }

  Future<void> _refresh() async {
    notificationsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsError) {
          CustomSnackbar.showError(context, 'Notification error');
          //notificationsInit();
        }
      },
      builder: (context, state) {
        if (state is NotificationsLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is NotificationsSuccess) {
          final notifications = state.notifications;

          if (notifications.isEmpty) {
            String title = notifications.isEmpty
                ? 'No Notifications'
                : 'No Matching Notifications';
            String message = notifications.isEmpty
                ? 'You\'re all caught up!'
                : 'Try adjusting your filters';
            return CustomEmptyState(
              icon: Icons.notifications_outlined,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: NotificationsList(
                notifications: notifications,
                // unreadCount: state.unreadCount,
              ),
            );
          }
        } else if (state is NotificationsError) {
          return CustomEmptyState(
            icon: Icons.notifications_outlined,
            title: 'Error Occurred',
            message: state.message,
            onRefresh: _refresh,
            actionLabel: 'Retry',
            onAction: _refresh,
          );
        } else {
          return CustomEmptyState(
            icon: Icons.notifications_outlined,
            title: 'No Notifications',
            message: 'Pull to refresh or check your connection',
            onRefresh: _refresh,
            actionLabel: 'Retry',
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(context, title: 'Notifications'),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: AnimatedElement(
            delay: const Duration(milliseconds: 200),
            child: _buildListContent(),
          ),
        ),
      ),
    );
  }
}
