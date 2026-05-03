import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';

class POSCartItemCard extends StatelessWidget {
  final CartItem item;
  final int index;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const POSCartItemCard({
    required this.item,
    required this.index,
    required this.onQuantityChanged,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.lightBlueBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveUI.value(context, 60),
            height: ResponsiveUI.value(context, 60),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Center(
              child: Text(
                item.product.image ?? '',
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 32)),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 4)),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    color: AppColors.red,
                    onPressed: () => onQuantityChanged(-1),
                  ),
                  Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    color: AppColors.successGreen,
                    onPressed: () => onQuantityChanged(1),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_outline),
                color: AppColors.red,
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

