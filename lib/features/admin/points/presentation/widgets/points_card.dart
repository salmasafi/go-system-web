import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import '../../cubit/points_cubit.dart';
import '../../model/points_model.dart';
import 'add_points_dialog.dart';

class PointsCard extends StatelessWidget {
  final PointsModel point;
  final int index;

  const PointsCard({
    super.key,
    required this.point,
    required this.index,
  });

  static const _accentColor = Color(0xFF4CAF50); // Green accent for points

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
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              _buildActions(context),
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
            Icons.stars_rounded,
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
                'Points Configuration',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 2)),
              Text(
                'ID: ${point.id.substring(0, 8)}...',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.shadowGray,
                ),
              ),
            ],
          ),
        ),
        // Points badge
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
            '${point.points} pts',
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
          icon: Icons.monetization_on_rounded,
          label: 'Amount: ${point.amount.toStringAsFixed(2)} EGP',
          color: AppColors.primaryBlue,
        ),
        _InfoChip(
          context: context,
          icon: Icons.calculate_rounded,
          label: 'Ratio: 1 EGP = ${(point.amount / point.points).toStringAsFixed(2)} pts',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: context.read<PointsCubit>(),
                child: AddPointsDialog(point: point),
              ),
            );
          },
          icon: Icon(Icons.edit_rounded, color: AppColors.primaryBlue),
          tooltip: 'Edit',
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),
        IconButton(
          onPressed: () {
            _showDeleteConfirmation(context);
          },
          icon: Icon(Icons.delete_rounded, color: AppColors.red),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppColors.red,
              size: ResponsiveUI.iconSize(context, 24),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Text(
              'Delete Points',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this points configuration?\nThis action cannot be undone.',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.darkGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PointsCubit>().deletePoints(point.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
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
              maxWidth: ResponsiveUI.value(context, 200),
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
