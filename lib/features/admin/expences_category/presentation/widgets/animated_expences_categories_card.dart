import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class AnimatedExpenseCategoryCard extends StatelessWidget {
  final ExpenseCategoryModel category;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Duration? animationDelay;

  const AnimatedExpenseCategoryCard({
    super.key,
    required this.category,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: animationDelay ?? const Duration(milliseconds: 200),
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
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.4),
            width: 1.8,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  const CustomGradientDivider(),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  _buildBody(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 25),
          backgroundColor:
              category.status ? AppColors.primaryBlue : AppColors.red,
          child: Icon(
            Icons.category,
            color: AppColors.white,
            size: ResponsiveUI.fontSize(context, 24),
          ),
        ),

        SizedBox(width: ResponsiveUI.spacing(context, 14)),

        Expanded(
          child: Text(
            context.locale.languageCode == 'ar'
                ? category.arName
                : category.name,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ),

        if (onEdit != null || onDelete != null)
          CustomPopupMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }

  // ================= BODY =================
  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _infoRow(
          _infoItem(
            context,
            LocaleKeys.status.tr(),
            category.status
                ? LocaleKeys.active.tr()
                : LocaleKeys.inactive_label.tr(),
                isActive: category.status
          ),
         SizedBox(),
          context,
        ),
      ],
    );
  }

  Widget _infoRow(Widget first, Widget second, BuildContext context) {
    return Row(
      children: [
        Expanded(child: first),
        SizedBox(width: ResponsiveUI.spacing(context, 36)),
        Expanded(child: second),
      ],
    );
  }

  Widget _infoItem(BuildContext context, String label, String value, {bool isActive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: AppColors.darkGray.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 2)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.successGreen : AppColors.darkGray,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
