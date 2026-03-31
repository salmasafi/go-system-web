import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/units/model/units_model.dart';
import '../../../../../generated/locale_keys.g.dart';

class AnimatedUnitCard extends StatefulWidget {
  final UnitModel unit;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;
  final Function(bool)? onchangeStatus;

  const AnimatedUnitCard({
    super.key,
    required this.unit,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onchangeStatus,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedUnitCard> createState() => _AnimatedUnitCardState();
}

class _AnimatedUnitCardState extends State<AnimatedUnitCard> {
  late bool _status;

  @override
  void initState() {
    super.initState();
    _status = widget.unit.status;
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;

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
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              blurRadius: ResponsiveUI.borderRadius(context, 10),
              offset: const Offset(0, 5),
            ),
          ],
          border: unit.status
              ? Border.all(
                  color: AppColors.darkBlue,
                  width: ResponsiveUI.value(context, 2.5),
                )
              : null,
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
                  _buildUnitItem(unit),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(unit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitItem(UnitModel unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.darkBlue,
          child: Icon(
            Icons.straighten_rounded,
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
                unit.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              if (unit.arName.isNotEmpty)
                Text(
                  unit.arName,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: AppColors.darkGray.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),

        Spacer(),

        Switch(
          value: _status,
          onChanged: (value) {
            setState(() {
              _status = value;
            });

            if (widget.onchangeStatus != null) {
              widget.onchangeStatus!(value);
            }
          },
          activeColor: AppColors.white,
          activeTrackColor: AppColors.primaryBlue,

          inactiveThumbColor: AppColors.white,
          inactiveTrackColor: AppColors.darkGray.withValues(alpha: 
            0.4,
          ), // soft grey track

          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }
            return AppColors.white;
          }),

          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryBlue;
            }
            return AppColors.darkGray.withValues(alpha: 0.4);
          }),
        ),

        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildFooter(UnitModel unit) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.unit_code.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
          
              Text(
                unit.code,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.base_unit.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
          
              Text(
                unit.isBaseUnit ? LocaleKeys.unit_yes.tr() : (unit.baseUnit?.name ?? LocaleKeys.unit_no.tr()),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.operation.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
          
              Text(
                unit.isBaseUnit ? LocaleKeys.base.tr() : '${unit.operator} ${unit.operatorValue}',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

      ],
    );
  }
}
