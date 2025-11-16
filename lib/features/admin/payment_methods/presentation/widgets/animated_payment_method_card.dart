import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import '../../../warehouses/view/widgets/custom_stat_chip.dart';
import '../../model/payment_method_model.dart';

class AnimatedPaymentMethodCard extends StatefulWidget {
  final PaymentMethodModel paymentMethod;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Duration? animationDelay;

  const AnimatedPaymentMethodCard({
    super.key,
    required this.paymentMethod,
    this.index,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDuration,
    this.animationDelay,
  });

  @override
  State<AnimatedPaymentMethodCard> createState() =>
      _AnimatedPaymentMethodCardState();
}

class _AnimatedPaymentMethodCardState extends State<AnimatedPaymentMethodCard> {
  @override
  Widget build(BuildContext context) {
    final paymentMethod = widget.paymentMethod;

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
              // PaymentMethod.isDefault
              //     ? Border.all(
              //         color: AppColors.primaryBlue.withOpaPaymentMethod(0.8),
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
                  _buildHeader(paymentMethod),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 15)),
                  _buildFooter(paymentMethod),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PaymentMethodModel paymentMethod) {
    return Row(
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
          child: Icon(
            Icons.attach_money_rounded,
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
                paymentMethod.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                paymentMethod.description,
                //  maxLines: 1,
                // overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.shadowGray,
                ),
              ),
            ],
          ),
        ),

        //Spacer(),

        if (widget.onEdit != null || widget.onDelete != null)
          CustomPopupMenu(onEdit: widget.onEdit, onDelete: widget.onDelete),
      ],
    );
  }

  Widget _buildFooter(PaymentMethodModel paymentMethod) {
    return Row(
      children: [
        Expanded(
          child: CustomStatChip(
            icon: Icons.info,
            label: 'Type: ${widget.paymentMethod.type}',
            color: AppColors.linkBlue,
          ),
        ),
        // SizedBox(width: ResponsiveUI.spacing(context, 10)),
        // Expanded(
        //   child: CustomStatChip(
        //     icon: Icons.location_city_rounded,
        //     label: 'City: ${widget.paymentMethod.city.name}',
        //     color: AppColors.successGreen,
        //   ),
        // ),

        // if (PaymentMethod.isDefault) ...[
        //   Icon(
        //     Icons.check_circle,
        //     color: AppColors.linkBlue,
        //     size: ResponsiveUI.fontSize(context, 18),
        //   ),
        //   SizedBox(width: ResponsiveUI.spacing(context, 6)),
        //   Text(
        //     'Selected PaymentMethod',
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
