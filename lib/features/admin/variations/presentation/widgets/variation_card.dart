import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/variations/model/variation_model.dart';

class VariationCard extends StatefulWidget {
  final VariationModel variation;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const VariationCard({
    super.key,
    required this.variation,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<VariationCard> createState() => _VariationCardState();
}

class _VariationCardState extends State<VariationCard> {
  @override
  Widget build(BuildContext context) {
    final variation = widget.variation;

    return AnimatedElement(
      delay: widget.animationDelay ?? const Duration(milliseconds: 200),
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
                  _buildHeader(variation),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildOptionsSummary(variation),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VariationModel variation) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue,
          child: Icon(
            Icons.list_alt,
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
                variation.name,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),

              // SizedBox(
              //   width: double.infinity,
              //   height: ResponsiveUI.value(context, 48),
              //   child: CustomElevatedButton(
              //     onPressed: () {
              //       context.read<VariationCubit>().deleteoption(
              //       "69356c1a0040cd480f1c76fb",
              //       );
              //     },
              //     text: 'Save Variation',
              //     // isLoading: isLoading,
              //   ),
              // ),
              // SizedBox(height: ResponsiveUI.spacing(context, 4)),
              // Text(
              //   variation.arName ?? '',
              //   style: TextStyle(
              //     fontSize: ResponsiveUI.fontSize(context, 14),
              //     fontWeight: FontWeight.w500,
              //     color: AppColors.darkGray.withOpacity(0.7),
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
            ],
          ),
        ),
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildOptionsSummary(VariationModel variation) {
    final allOptions = variation.options.toList();
    final activeOptions = variation.options.where((o) => o.status).toList();
    final inactiveOptions = variation.options.where((o) => !o.status).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options: ${allOptions.map((o) => o.name).join(', ')}',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        Text(
          'Active: ${activeOptions.isEmpty ? "no active items" : activeOptions.map((o) => o.name).join(', ')}',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.successGreen,
          ),
        ),
        Text(
          'Inactive: ${inactiveOptions.isEmpty ? "no inactive items" : inactiveOptions.map((o) => o.name).join(', ')}',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
