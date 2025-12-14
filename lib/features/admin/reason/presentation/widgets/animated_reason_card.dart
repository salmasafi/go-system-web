import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../warehouses/view/widgets/custom_stat_chip.dart';
import '../../model/reason_model.dart';

class AnimatedReasonCard extends StatefulWidget {
  final ReasonModel reason;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedReasonCard({
    super.key,
    required this.reason,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedReasonCard> createState() => _AnimatedReasonCardState();
}

class _AnimatedReasonCardState extends State<AnimatedReasonCard> {
  @override
  Widget build(BuildContext context) {
    final reason = widget.reason;

    // Validate reason data
    if (reason.id.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedElement(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, AppColors.lightBlueBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.1),
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
                  _buildHeader(reason),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(reason),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ReasonModel reason) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Icon(
            Icons.receipt_long_rounded,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Text(
            reason.reason.isNotEmpty ? reason.reason : 'No reason text',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

Widget _buildFooter(ReasonModel reason) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: ResponsiveUI.value(context, 40),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: CustomStatChip(
            icon: Icons.calendar_today_rounded,
            label: DateFormat('dd MMM yyyy').format(reason.createdAt),
            color: AppColors.linkBlue,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),
        Flexible(
          child: CustomStatChip(
            icon: Icons.access_time_rounded,
            label: DateFormat('hh:mm a').format(reason.createdAt),
            color: AppColors.successGreen,
          ),
        ),
      ],
    ),
  );
}
}