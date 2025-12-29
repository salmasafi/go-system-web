import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/popup/model/popup_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedPopupCard extends StatefulWidget {
  final PopupModel popup;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedPopupCard({
    super.key,
    required this.popup,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedPopupCard> createState() =>
      _AnimatedPopupCardState();
}

class _AnimatedPopupCardState extends State<AnimatedPopupCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final popup = widget.popup;

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
                  _buildPopupItem(popup),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(popup),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupItem(PopupModel popup) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.lightBlueBackground,
          child: popup.image.isEmpty
              ? Icon(
                  Icons.account_balance,
                  color: AppColors.white,
                  size: ResponsiveUI.fontSize(context, 24),
                )
              : ClipOval(
                  child: Image.network(
                    popup.image,
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
                      return _buildErrorPlaceholder();
                    },
                  ),
                ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                popup.titleEn,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),

        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildFooter(PopupModel popup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                   LocaleKeys.popup_description_en.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.darkGray.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 2)),
                  Text(
                    '${popup.descriptionEn}',
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGray,
                      overflow: TextOverflow.ellipsis,
                      
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(width: ResponsiveUI.spacing(context, 16)),
            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: [
            //       Text(
            //         'Initial Balance',
            //         style: TextStyle(
            //           fontSize: ResponsiveUI.fontSize(context, 12),
            //           color: AppColors.darkGray.withOpacity(0.6),
            //         ),
            //       ),
            //       SizedBox(height: ResponsiveUI.spacing(context, 2)),
            //       Text(
            //         '${popup.initialBalance.toStringAsFixed(2)}',
            //         style: TextStyle(
            //           fontSize: ResponsiveUI.fontSize(context, 14),
            //           fontWeight: FontWeight.w500,
            //           color: AppColors.successGreen,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),

        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // if (popup.note.isNotEmpty)
        //   Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         'Note:',
        //         style: TextStyle(
        //           fontSize: ResponsiveUI.fontSize(context, 12),
        //           color: AppColors.darkGray.withOpacity(0.6),
        //         ),
        //       ),
        //       SizedBox(height: ResponsiveUI.spacing(context, 4)),
        //       Text(
        //         popup.note,
        //         style: TextStyle(
        //           fontSize: ResponsiveUI.fontSize(context, 13),
        //           color: AppColors.darkGray.withOpacity(0.8),
        //         ),
        //         maxLines: 2,
        //         overflow: TextOverflow.ellipsis,
        //       ),
        //     ],
        //   ),

        // SizedBox(height: ResponsiveUI.spacing(context, 8)),

        // Status and date information
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       popup.status ? 'Active' : 'Inactive',
        //       style: TextStyle(
        //         fontSize: ResponsiveUI.fontSize(context, 12),
        //         color: popup.status
        //             ? AppColors.successGreen
        //             : AppColors.darkGray.withOpacity(0.6),
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),

        //   ],
        // ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final height120 = ResponsiveUI.value(context, 120);
    return Container(
      width: double.infinity,
      height: height120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(borderRadius12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            LocaleKeys.failed_to_load_image.tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  
}