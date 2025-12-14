import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../warehouses/view/widgets/custom_stat_chip.dart';
import '../../model/adjustment_model.dart';

class AnimatedAdjustmentCard extends StatefulWidget {
  final AdjustmentModel adjustment;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;
  const AnimatedAdjustmentCard({
    super.key,
    required this.adjustment,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedAdjustmentCard> createState() => _AnimatedAdjustmentCardState();
}

class _AnimatedAdjustmentCardState extends State<AnimatedAdjustmentCard> {
  @override
  Widget build(BuildContext context) {
    final adjustment = widget.adjustment;
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
                  _buildHeader(adjustment),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(adjustment),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AdjustmentModel adjustment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Icon(
            Icons.inventory_2_rounded,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Text(
            adjustment.note,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Spacer(),
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildFooter(AdjustmentModel adjustment) {
    return Row(
      children: [
        Expanded(
          child: CustomStatChip(
            icon: Icons.adjust_rounded,
            label: '${LocaleKeys.reason.tr()}: ${ LocaleKeys.unknown.tr()}',
            color: AppColors.linkBlue,
          ),
        ),
      ],
    );
  }
}