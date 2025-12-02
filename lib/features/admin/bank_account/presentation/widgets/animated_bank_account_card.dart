import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/bank_account/model/bank_account_model.dart';

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

  Widget _buildAccountItem(BankAccountModel account) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: account.icon.isEmpty
              ? Icon(
                  Icons.account_balance,
                  color: AppColors.white,
                  size: ResponsiveUI.fontSize(context, 24),
                )
              : ClipOval(
                  child: Image.network(
                    account.icon,
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
        // Switch(
        //   value: _status,
        //   onChanged: (value) {
        //     setState(() {
        //       _status = value;
        //     });
        //     if (widget.onchangeStatus != null) {
        //       widget.onchangeStatus!(value);
        //     }
        //   },
        //   activeColor: AppColors.white,
        //   activeTrackColor: AppColors.primaryBlue,
        //   inactiveThumbColor: AppColors.white,
        //   inactiveTrackColor: AppColors.darkGray.withOpacity(0.4),
        //   thumbColor: MaterialStateProperty.resolveWith((states) {
        //     return AppColors.white;
        //   }),
        //   trackOutlineColor: MaterialStateProperty.resolveWith((states) {
        //     return states.contains(MaterialState.selected)
        //         ? AppColors.primaryBlue
        //         : AppColors.darkGray.withOpacity(0.4);
        //   }),
        // ),
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
            // Text(
            //   'Updated: ${_formatDate(account.updatedAt)}',
            //   style: TextStyle(
            //     fontSize: ResponsiveUI.fontSize(context, 11),
            //     color: AppColors.darkGray.withOpacity(0.5),
            //   ),
            // ),
          ],
        ),
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
            'Failed to load image',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  //   String _formatDate(String dateString) {
  //   try {
  //     final date = DateTime.parse(dateString);
  //     return '${date.day}/${date.month}/${date.year}';
  //   } catch (e) {
  //     return dateString;
  //   }
  // }
}









// Switch(
//           value: _status,
//           onChanged: (value) {
//             setState(() {
//               _status = value;
//             });
//             if (widget.onchangeStatus != null) {
//               widget.onchangeStatus!(value);
//             }
//           },
//           activeColor: AppColors.white,
//           activeTrackColor: AppColors.primaryBlue,
//           inactiveThumbColor: AppColors.white,
//           inactiveTrackColor: AppColors.darkGray.withOpacity(0.4),
//           thumbColor: MaterialStateProperty.resolveWith((states) {
//             return AppColors.white;
//           }),
//           trackOutlineColor: MaterialStateProperty.resolveWith((states) {
//             return states.contains(MaterialState.selected)
//                 ? AppColors.primaryBlue
//                 : AppColors.darkGray.withOpacity(0.4);
//           }),