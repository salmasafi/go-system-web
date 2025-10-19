import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';

class InstructionsCard extends StatelessWidget {
  const InstructionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 8),
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.primaryBlue,
                  size: ResponsiveUI.iconSize(context, 20),
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          InstructionItem(number: '1', text: 'Tap "Start Scanning" button'),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          InstructionItem(number: '2', text: 'Point camera at the barcode'),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          InstructionItem(number: '3', text: 'Wait for automatic detection'),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          InstructionItem(number: '4', text: 'View product details instantly'),
        ],
      ),
    );
  }
}

class InstructionItem extends StatelessWidget {
  final String number;
  final String text;

  const InstructionItem({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ResponsiveUI.value(context, 28),
          height: ResponsiveUI.value(context, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.linkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
