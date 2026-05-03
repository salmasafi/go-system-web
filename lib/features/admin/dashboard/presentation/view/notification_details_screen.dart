import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_gradient_divider.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../product/presentation/screens/product_details_screen.dart';
import '../../cubit/notifications_cubit.dart';
import '../../model/notification_model.dart';

class NotificationDetailsScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  State<NotificationDetailsScreen> createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  @override
  void initState() {
    context.read<NotificationsCubit>().markAsRead(widget.notification.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM d, yyyy – hh:mm a',
    ).format(widget.notification.createdAt);
    final formattedUpdateDate = DateFormat(
      'MMM d, yyyy – hh:mm a',
    ).format(widget.notification.updatedAt);
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.update_account_details.tr(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Title
            AnimatedElement(
              delay: Duration.zero,
              child: Text(
                widget.notification.title,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            
            // Notification Date
            AnimatedElement(
              delay: const Duration(milliseconds: 100),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withValues(alpha: 0.7),
                ),
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            
            // Notification Content
            AnimatedElement(
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.notification.message,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    color: AppColors.darkGray,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            
            // Product Reference (if exists)
            if (widget.notification.productId != null) ...[
              SizedBox(height: ResponsiveUI.spacing(context, 24)),
              AnimatedElement(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.products.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 8)),
                      Text(
                        '${LocaleKeys.product_id.tr()}: ${widget.notification.productId}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          color: AppColors.darkGray,
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveUI.value(context, 40),
                        child: CustomElevatedButton(
                          onPressed: () {
                            // Navigate to product details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                  productId: widget.notification.productId!,
                                ),
                              ),
                            );
                          },
                          text: LocaleKeys.location_details.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            SizedBox(height: ResponsiveUI.spacing(context, 32)),
            
            // Update Date (if different from creation date)
            if (widget.notification.createdAt != widget.notification.updatedAt) ...[
              AnimatedElement(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                  decoration: BoxDecoration(
                    color: AppColors.shadowGray[50],
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.update,
                        size: ResponsiveUI.iconSize(context, 16),
                        color: AppColors.darkGray.withValues(alpha: 0.7),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 8)),
                      Text(
                        '${LocaleKeys.last_updated.tr()}: $formattedUpdateDate',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.darkGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }

  Widget _buildHeaderCard(BuildContext context, String formattedDate) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.notification.isRead
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
      child: Row(
        children: [
          CircleAvatar(
            radius: ResponsiveUI.borderRadius(context, 30),
            backgroundColor: widget.notification.isRead
                ? Colors.grey.shade300
                : AppColors.darkBlue,
            child: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.white,
              size: ResponsiveUI.fontSize(context, 28),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.linkBlue,
                      size: ResponsiveUI.fontSize(context, 18),
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 6)),
                    Text(
                      widget.notification.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.linkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
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
          if (!widget.notification.isRead)
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
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          const CustomGradientDivider(),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          Text(
            widget.notification.message,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 15),
              fontWeight: FontWeight.w400,
              color: AppColors.darkGray,
              height: ResponsiveUI.value(context, 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, String formattedUpdateDate) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          const CustomGradientDivider(),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),

          // _buildDetailRow(
          //   context,
          //   'Notification ID',
          //   widget.notification.id,
          //   Icons.tag_outlined,
          // ),
          // SizedBox(height: ResponsiveUI.spacing(context, 14)),
          // _buildDetailRow(
          //   context,
          //   'Product ID',
          //   widget.notification.productId.isNotEmpty
          //       ? widget.notification.productId
          //       : 'N/A',
          //   Icons.inventory_2_outlined,
          // ),
          // SizedBox(height: ResponsiveUI.spacing(context, 14)),
          _buildDetailRow(
            context,
            'Status',
            widget.notification.isRead ? 'Read' : 'Unread',
            widget.notification.isRead
                ? Icons.mark_email_read_outlined
                : Icons.mark_email_unread_outlined,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 14)),

          _buildDetailRow(
            context,
            'Last Updated',
            formattedUpdateDate,
            Icons.update_outlined,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          const CustomGradientDivider(),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),

          if (widget.notification.productId.isNotEmpty)
            CustomElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                    productId: widget.notification.productId,
                  ),
                ),
              ),
              text: 'View Product Details',
            )
          else
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
                vertical: ResponsiveUI.padding(context, 12),
              ),
              decoration: BoxDecoration(
                color: AppColors.darkGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.darkGray.withValues(alpha: 0.6),
                    size: ResponsiveUI.fontSize(context, 18),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 8)),
                  Text(
                    'No product linked to this notification',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      color: AppColors.darkGray.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.linkBlue,
          size: ResponsiveUI.fontSize(context, 20),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


