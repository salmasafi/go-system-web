import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
          ),
          child: Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 20),
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }
}

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ContactItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Icon(
              icon,
              size: ResponsiveUI.iconSize(context, 22),
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: AppColors.darkGray.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const LocationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        border: Border.all(color: AppColors.lightGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 32),
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: AppColors.darkGray.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
