import 'package:flutter/material.dart';

import 'package:systego/core/constants/app_colors.dart';

import 'package:systego/core/utils/responsive_ui.dart';

import 'package:systego/core/widgets/animation/animated_element.dart';

import 'package:systego/core/widgets/custom_gradient_divider.dart';

import 'package:systego/core/widgets/custom_popup_menu.dart';

import 'package:systego/features/admin/bank_account/model/bank_account_model.dart';

import 'dart:convert';

import 'dart:typed_data';

class AnimatedBankAccountCard extends StatefulWidget {
  final BankAccountModel account;

  final int? index;

  final VoidCallback? onDelete;

  final VoidCallback? onEdit;

  final VoidCallback? onTap;

  final Duration? animationDuration;

  final Duration? animationDelay;

  const AnimatedBankAccountCard({
    super.key,

    required this.account,

    this.index,

    this.onDelete,

    this.onEdit,

    this.onTap,

    this.animationDuration,

    this.animationDelay,
  });

  @override
  State<AnimatedBankAccountCard> createState() =>
      _AnimatedBankAccountCardState();
}

class _AnimatedBankAccountCardState extends State<AnimatedBankAccountCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;

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

          border: account.status
              ? Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.8),

                  width: 2.5,
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
                  _buildAccountItem(account),

                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  const CustomGradientDivider(),

                  SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  _buildFooter(account),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(BankAccountModel account) {
    final size = ResponsiveUI.borderRadius(context, 50);

    if (account.icon.isEmpty) {
      return Icon(
        Icons.account_balance,

        color: AppColors.white,

        size: ResponsiveUI.fontSize(context, 24),
      );
    }

    final isBase64 = account.icon.startsWith('data:');

    Widget image;

    if (isBase64) {
      final parts = account.icon.split(',');

      if (parts.length == 2) {
        try {
          final Uint8List bytes = base64Decode(parts[1]);

          image = Image.memory(
            bytes,

            fit: BoxFit.cover,

            width: size,

            height: size,

            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder(),
          );
        } catch (e) {
          image = _buildErrorPlaceholder();
        }
      } else {
        image = _buildErrorPlaceholder();
      }
    } else {
      // Existing logic for network images

      image = Image.network(
        account.icon,

        fit: BoxFit.cover,

        width: size,

        height: size,

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
      );
    }

    return ClipOval(child: image);
  }

  Widget _buildAccountItem(BankAccountModel account) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),

          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),

          child: _buildImageWidget(account), // USED THE NEW HELPER WIDGET
        ),

        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                account.name,

                style: TextStyle(
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

  Widget _buildFooter(BankAccountModel account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Account Number',

                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),

                      color: AppColors.darkGray.withOpacity(0.6),
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 2)),

                  Text(
                    '#${account.accountNumber}',

                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),

                      fontWeight: FontWeight.w500,

                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: ResponsiveUI.spacing(context, 16)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    'Initial Balance',

                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),

                      color: AppColors.darkGray.withOpacity(0.6),
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 2)),

                  Text(
                    '${account.initialBalance.toStringAsFixed(2)}',

                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),

                      fontWeight: FontWeight.w500,

                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        if (account.note.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Note:',

                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),

                  color: AppColors.darkGray.withOpacity(0.6),
                ),
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                account.note,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),

                  color: AppColors.darkGray.withOpacity(0.8),
                ),
                maxLines: 2,

                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

        SizedBox(height: ResponsiveUI.spacing(context, 8)),

        // Status and date information
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              account.status ? 'Active' : 'Inactive',

              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),

                color: account.status
                    ? AppColors.successGreen
                    : AppColors.darkGray.withOpacity(0.6),

                fontWeight: FontWeight.w500,
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    final size = ResponsiveUI.borderRadius(context, 50);

    return Container(
      width: size,

      height: size,

      decoration: BoxDecoration(
        color: Colors.grey[100],

        shape: BoxShape.circle,
      ),

      child: Icon(
        Icons.broken_image_outlined,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }
}
