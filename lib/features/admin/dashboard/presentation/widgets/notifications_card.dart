import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/custom_gradient_divider.dart';
import 'package:GoSystem/core/widgets/custom_popup_menu.dart';
import 'package:intl/intl.dart';
import 'package:GoSystem/features/admin/dashboard/model/notification_model.dart';

class AnimatedNotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedNotificationCard({
    super.key,
    required this.notification,
    this.index,
    this.onDelete,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedNotificationCard> createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<AnimatedNotificationCard> {
  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final formattedDate = DateFormat(
      'MMM d, yyyy – hh:mm a',
    ).format(notification.createdAt);

    return AnimatedElement(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: notification.isRead
                ? [AppColors.white, AppColors.white]
                : [AppColors.white, AppColors.lightBlueBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              blurRadius: ResponsiveUI.borderRadius(context, 10),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(notification, formattedDate),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(notification),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(NotificationModel notification, String formattedDate) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: notification.isRead
              ? Colors.grey.shade300
              : AppColors.darkBlue,
          child: Icon(
            Icons.notifications_active_outlined,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: notification.isRead
                      ? FontWeight.w400
                      : FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        if (widget.onDelete != null) CustomPopupMenu(onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildFooter(NotificationModel notification) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.linkBlue,
              size: ResponsiveUI.fontSize(context, 18),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 6)),
            Text(
              notification.type.toUpperCase(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w500,
                color: AppColors.linkBlue,
              ),
            ),
          ],
        ),
        if (!notification.isRead)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 10),
              vertical: ResponsiveUI.padding(context, 5),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            child: Text(
              'NEW',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
      ],
    );
  }
}

