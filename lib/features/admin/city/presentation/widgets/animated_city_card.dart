import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../warehouses/view/widgets/custom_stat_chip.dart';
import '../../model/city_model.dart';

class AnimatedCityCard extends StatefulWidget {
  final CityModel city;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedCityCard({
    super.key,
    required this.city,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedCityCard> createState() => _AnimatedCityCardState();
}

class _AnimatedCityCardState extends State<AnimatedCityCard> {
  @override
  Widget build(BuildContext context) {
    final city = widget.city;

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
          border:
              // city.isDefault
              //     ? Border.all(
              //         color: AppColors.primaryBlue.withOpacity(0.8),
              //         width: 2.5,
              //       ) :
              null,
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
                  _buildHeader(city),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(city),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CityModel city) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Icon(
            Icons.location_city_rounded,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Text(
          city.name,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        Spacer(),

        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildFooter(CityModel city) {
    return Row(
      children: [
        Expanded(
          child: CustomStatChip(
            icon: Icons.location_on_rounded,
            label: '${LocaleKeys.country.tr()}: ${widget.city.country?.name ?? LocaleKeys.unknown.tr()}',
            color: AppColors.linkBlue,
          ),
        ),

        // if (City.isDefault) ...[
        //   Icon(
        //     Icons.check_circle,
        //     color: AppColors.linkBlue,
        //     size: ResponsiveUI.fontSize(context, 18),
        //   ),
        //   SizedBox(width: ResponsiveUI.spacing(context, 6)),
        //   Text(
        //     'Selected City',
        //     style: TextStyle(
        //       fontSize: ResponsiveUI.fontSize(context, 13),
        //       color: AppColors.linkBlue,
        //     ),
        //   ),
        // ],
      ],
    );
  }
}
