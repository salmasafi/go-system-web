import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:intl/intl.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../model/currency_model.dart';

class AnimatedCurrencyCard extends StatefulWidget {
  final CurrencyModel currency;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedCurrencyCard({
    super.key,
    required this.currency,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedCurrencyCard> createState() => _AnimatedCurrencyCardState();
}

class _AnimatedCurrencyCardState extends State<AnimatedCurrencyCard> {
  @override
  Widget build(BuildContext context) {
    final currency = widget.currency;
    final String createdAt = DateFormat(
      'MMM d, yyyy – hh:mm a',
    ).format(currency.createdAt);
    final String updatedAt = DateFormat(
      'MMM d, yyyy – hh:mm a',
    ).format(currency.updatedAt);

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
                  _buildHeader(currency),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildFooter(currency, createdAt, updatedAt),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CurrencyModel currency) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Icon(
            Icons.monetization_on_rounded,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        Text(
          currency.name,
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

  Widget _buildFooter(
    CurrencyModel currency,
    String createdAt,
    String updatedAt,
  ) {
    return Column(
      children: [
        // Icon(
        //   Icons.info_outline,
        //   color: AppColors.linkBlue,
        //   size: ResponsiveUI.fontSize(context, 18),
        // ),

        Row(
          children: [
            Expanded(
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(
                "Amount",
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
              Text(
                currency.amount.toString(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
                    ],
                  ),
            ),
          ],
        ),

        currency.isDefault ? 
        Row(
          children: [
            Expanded(
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(
                "Default Currency",
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.successGreen,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
       
                    ],
                  ),
            ),
          ],
        ) : SizedBox(),

        // Text(
        //   '${LocaleKeys.created_at.tr()}: $createdAt',
        //   style: TextStyle(
        //     fontSize: ResponsiveUI.fontSize(context, 13),
        //     color: AppColors.darkGray.withOpacity(0.6),
        //   ),
        // ),
        // Text(
        //   'Updated at: $updatedAt',
        //   style: TextStyle(
        //     fontSize: 13,
        //     color: AppColors.darkGray.withOpacity(0.6),
        //   ),
        // ),
      ],
    );
  }
}
