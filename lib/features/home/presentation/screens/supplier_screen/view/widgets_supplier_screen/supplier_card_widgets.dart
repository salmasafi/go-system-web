import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../model/supplier_model.dart';

class SupplierImage extends StatelessWidget {
  final Suppliers supplier;

  const SupplierImage({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveUI.value(context, 58),
      height: ResponsiveUI.value(context, 58),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        child: supplier.image != null && supplier.image!.isNotEmpty
            ? Image.network(
          supplier.image!,
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
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.store,
              size: ResponsiveUI.iconSize(context, 28),
              color: AppColors.primaryBlue,
            );
          },
        )
            : Icon(
          Icons.store,
          size: ResponsiveUI.iconSize(context, 28),
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class SupplierInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const SupplierInfoItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 18),
            color: AppColors.primaryBlue,
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class SupplierLocationTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const SupplierLocationTag({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 10),
        vertical: ResponsiveUI.padding(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 10),
        ),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 16),
            color: AppColors.primaryBlue,
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 6)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}