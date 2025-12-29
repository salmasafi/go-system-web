import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/pandel/model/pandel_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedPandelCard extends StatefulWidget {
  final PandelModel pandel;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedPandelCard({
    super.key,
    required this.pandel,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedPandelCard> createState() => _AnimatedPandelCardState();
}

class _AnimatedPandelCardState extends State<AnimatedPandelCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pandel = widget.pandel;
    // final now = DateTime.now();
    // final isActive = now.isAfter(pandel.startDate) && now.isBefore(pandel.endDate);
    // final isUpcoming = pandel.startDate.isAfter(now);

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
                  _buildPandelItem(pandel),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(pandel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPandelItem(PandelModel pandel) {
    final hasImages = pandel.images.isNotEmpty;
    final firstImage = hasImages ? pandel.images.first : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Status indicator
        // Container(
        //   width: ResponsiveUI.value(context, 8),
        //   height: ResponsiveUI.value(context, 40),
        //   decoration: BoxDecoration(
        //     color: pandel.status ? AppColors.successGreen : AppColors.holdBeige,
        //     borderRadius: BorderRadius.circular(
        //       ResponsiveUI.borderRadius(context, 4),
        //     ),
        //   ),
        // ),
        // SizedBox(width: ResponsiveUI.spacing(context, 12)),
        
        // Image/Icon
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.lightBlueBackground,
          child: hasImages
              ? ClipOval(
                  child: Image.network(
                    firstImage,
                    fit: BoxFit.cover,
                    width: ResponsiveUI.borderRadius(context, 50),
                    height: ResponsiveUI.borderRadius(context, 50),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.primaryBlue,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildIconPlaceholder();
                    },
                  ),
                )
              : _buildIconPlaceholder(),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        
        // Pandel Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pandel.name,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                // "ss",
                '${pandel.products.length} ${LocaleKeys.products.tr()}',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),

        // Price tag
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 12),
            vertical: ResponsiveUI.padding(context, 4),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 16),
            ),
          ),
          child: Text(
            '\$${pandel.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        
        SizedBox(width: ResponsiveUI.spacing(context, 8)),

        // Action menu
        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildFooter(PandelModel pandel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Images preview
        if (pandel.images.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${LocaleKeys.images.tr()} (${pandel.images.length})',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 8)),
              SizedBox(
                height: ResponsiveUI.value(context, 60),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pandel.images.length > 3 ? 3 : pandel.images.length,
                  separatorBuilder: (context, index) => 
                    SizedBox(width: ResponsiveUI.spacing(context, 8)),
                  itemBuilder: (context, index) {
                    return Container(
                      width: ResponsiveUI.value(context, 60),
                      height: ResponsiveUI.value(context, 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 8),
                        ),
                        border: Border.all(
                          color: AppColors.lightGray,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 8),
                        ),
                        child: Image.network(
                          pandel.images[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.primaryBlue,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
            ],
          ),

        // Date range
        Row(
          children: [
            _buildDateInfo(
              icon: Icons.calendar_today,
              label: LocaleKeys.starts.tr(),
              date: pandel.startDate,
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 16)),
            _buildDateInfo(
              icon: Icons.event,
              label: LocaleKeys.ends.tr(),
              date: pandel.endDate,
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // Status badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 12),
                vertical: ResponsiveUI.padding(context, 6),
              ),
              decoration: BoxDecoration(
                color: pandel.status 
                  ? AppColors.successGreen.withOpacity(0.1)
                  // : isUpcoming
                    // ? AppColors.holdBeige.withOpacity(0.1)
                    : AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    pandel.status 
                      ? Icons.check_circle
                      // : isUpcoming
                      //   ? Icons.schedule
                        : Icons.history,
                    size: ResponsiveUI.iconSize(context, 14),
                    color: pandel.status 
                      ? AppColors.successGreen
                      // : isUpcoming
                      //   ? AppColors.holdBeige
                        : AppColors.red,
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 4)),
                  Text(
                    pandel.status  
                      ? LocaleKeys.active.tr()
                      // : isUpcoming
                      //   ? LocaleKeys.upcoming.tr()
                        : LocaleKeys.expired.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      fontWeight: FontWeight.w500,
                      color: pandel.status  
                        ? AppColors.successGreen
                        // : isUpcoming
                        //   ? AppColors.holdBeige
                          : AppColors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Days remaining/elapsed
            Text(
              pandel.status 
                ? '${LocaleKeys.ends_in.tr()} ${_calculateDaysBetween(DateTime.now(), pandel.endDate)} ${LocaleKeys.days.tr()}'
                // : isUpcoming
                //   ? '${LocaleKeys.starts_in.tr()} ${_calculateDaysBetween(DateTime.now(), pandel.startDate)} ${LocaleKeys.days.tr()}'
                  : '${_calculateDaysBetween(pandel.endDate, DateTime.now())} ${LocaleKeys.days_ago.tr()}',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkGray.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required DateTime date,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: ResponsiveUI.iconSize(context, 14),
                color: AppColors.darkGray.withOpacity(0.6),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 4)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 4)),
          Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder() {
    return Icon(
      Icons.collections_bookmark,
      color: AppColors.primaryBlue,
      size: ResponsiveUI.fontSize(context, 24),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  int _calculateDaysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays.abs();
  }
}