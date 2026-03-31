import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import '../../model/expense_admin_model.dart';

class ExpenseAdminCard extends StatelessWidget {
  final ExpenseAdminModel expense;
  final int index;

  const ExpenseAdminCard({
    super.key,
    required this.expense,
    required this.index,
  });

  static const _accentColor = Color(0xFFE53935); // red accent like the website

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedElement(
      delay: Duration(milliseconds: 100 * (index % 10)),
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
              color: _accentColor.withValues(alpha: 0.08),
              blurRadius: ResponsiveUI.borderRadius(context, 10),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: ResponsiveUI.spacing(context, 14)),
              const CustomGradientDivider(),
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: ResponsiveUI.borderRadius(context, 24),
          backgroundColor: _accentColor.withValues(alpha: 0.12),
          child: Icon(
            Icons.receipt_long_rounded,
            color: _accentColor,
            size: ResponsiveUI.fontSize(context, 22),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
              Text(
                _formatDate(expense.createdAt),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.shadowGray,
                ),
              ),
            ],
          ),
        ),
        // Amount badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 12),
            vertical: ResponsiveUI.padding(context, 6),
          ),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
          ),
          child: Text(
            '${expense.amount.toStringAsFixed(0)} EGP',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w800,
              color: _accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Wrap(
      spacing: ResponsiveUI.spacing(context, 8),
      runSpacing: ResponsiveUI.spacing(context, 8),
      children: [
        _InfoChip(
          context: context,
          icon: Icons.account_balance_rounded,
          label: expense.financialAccountName ?? '-',
          color: AppColors.primaryBlue,
        ),
        _InfoChip(
          context: context,
          icon: Icons.category_rounded,
          label: expense.categoryId != null ? 'Category' : '-',
          color: AppColors.categoryPurple,
        ),
        if (expense.note.isNotEmpty)
          _InfoChip(
            context: context,
            icon: Icons.notes_rounded,
            label: expense.note,
            color: AppColors.successGreen,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.context,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 10),
        vertical: ResponsiveUI.padding(context, 5),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ResponsiveUI.iconSize(context, 13), color: color),
          SizedBox(width: ResponsiveUI.spacing(context, 5)),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUI.value(context, 160),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
