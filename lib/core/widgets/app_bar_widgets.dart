import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/settings/presentation/view/settings_screen.dart';
import '../constants/app_colors.dart';

AppBar appBarWithActions(
  BuildContext context, {
  String? title,
  void Function()? onPressed,
  Color? backgroundColor,
  IconData? actionIcon,
  bool showActions = false,
  bool showBackButton = true,
  int notificationCount = 0,
}) {
  return AppBar(
    scrolledUnderElevation: 0,
    elevation: 0,
    backgroundColor: backgroundColor ?? AppColors.white,
    centerTitle: true,
    title: Text(
      title ?? '',
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 20),
        fontWeight: FontWeight.w600,
        color: AppColors.darkGray,
        letterSpacing: 0.5,
      ),
    ),
    leading: showBackButton
        ? Container(
            margin: EdgeInsetsDirectional.only(
              start: ResponsiveUI.padding(context, 8),
              top: ResponsiveUI.padding(context, 8),
              bottom: ResponsiveUI.padding(context, 8),
            ),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.mediumBlue700[700],
                size: ResponsiveUI.fontSize(context, 20),
              ),
              padding: EdgeInsets.zero,
            ),
          )
        : Container(
          margin: EdgeInsetsDirectional.only(
                start: ResponsiveUI.padding(context, 8),
                top: ResponsiveUI.padding(context, 8),
                bottom: ResponsiveUI.padding(context, 8)),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
              },
              icon: Icon(
                Icons.settings,
                color: AppColors.mediumBlue700[700],
                size: ResponsiveUI.iconSize(context, 25),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
    actions: showActions
        ? [
            Container(
              margin: EdgeInsetsDirectional.only(
                end: ResponsiveUI.padding(context, 8),
                top: ResponsiveUI.padding(context, 8),
                bottom: ResponsiveUI.padding(context, 8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                    ),
                    child: IconButton(
                      onPressed: onPressed,
                      icon: Icon(
                        actionIcon ?? Icons.add,
                        color: AppColors.mediumBlue700[700],
                        size: ResponsiveUI.iconSize(context, 25),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  // Notification Badge
                  if (notificationCount > 0)
                    Positioned(
                      right: ResponsiveUI.value(context, -2),
                      top: ResponsiveUI.value(context, -2),
                      child: Container(
                        padding: EdgeInsets.all(
                          ResponsiveUI.padding(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: backgroundColor ?? AppColors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(
                          minWidth: ResponsiveUI.value(context, 20),
                          minHeight: ResponsiveUI.value(context, 20),
                        ),
                        child: Center(
                          child: Text(
                            notificationCount > 99
                                ? '99+'
                                : '$notificationCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUI.fontSize(context, 10),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ]
        : null,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(ResponsiveUI.value(context, 1)),
      child: Container(
        height: ResponsiveUI.value(context, 1),
        color: AppColors.lightGray.withOpacity(0.3),
      ),
    ),
  );
}

AppBar appBarWithActionsWidget(
  BuildContext context, {
  String? title,
  void Function()? onPressed,
  Color? backgroundColor,
  Widget? actionWidget,
  bool showActions = false,
  bool showBackButton = true,
  int notificationCount = 0, // عدد الإشعارات غير المقروءة
}) {
  return AppBar(
    scrolledUnderElevation: 0,
    elevation: 0,
    backgroundColor: backgroundColor ?? AppColors.white,
    centerTitle: true,
    title: Text(
      title ?? '',
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 20),
        fontWeight: FontWeight.w600,
        color: AppColors.darkGray,
        letterSpacing: 0.5,
      ),
    ),
    leading: showBackButton
        ? Container(
            margin: EdgeInsetsDirectional.only(
              start: ResponsiveUI.padding(context, 8),
              top: ResponsiveUI.padding(context, 8),
              bottom: ResponsiveUI.padding(context, 8),
            ),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.mediumBlue700[700],
                size: ResponsiveUI.fontSize(context, 20),
              ),
              padding: EdgeInsets.zero,
            ),
          )
        : null,
    actions: showActions && actionWidget != null ? [actionWidget] : null,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(ResponsiveUI.value(context, 1)),
      child: Container(
        height: ResponsiveUI.value(context, 1),
        color: AppColors.lightGray.withOpacity(0.3),
      ),
    ),
  );
}
