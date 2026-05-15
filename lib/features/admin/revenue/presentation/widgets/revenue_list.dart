import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/admin/revenue/cubit/revenue_cubit.dart';
import 'package:GoSystem/features/admin/revenue/model/revenue_model.dart';
import 'package:GoSystem/features/admin/revenue/presentation/widgets/animated_revenue_card.dart';
import 'package:GoSystem/features/admin/revenue/presentation/widgets/revenue_form_dialof.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';


class RevenuesList extends StatelessWidget {
  final List<RevenueModel> revenues;
  const RevenuesList({super.key, required this.revenues});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: revenues.length,
      itemBuilder: (context, index) {
        return AnimatedRevenueCard(
          revenue: revenues[index],
          index: index,
          onEdit: () => _showEditDialog(context, revenues[index]),
          onDelete: () => _showDeleteDialog(context, revenues[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, RevenueModel revenue) {
    showDialog(
      context: context,
      builder: (context) => RevenueFormDialog(revenue: revenue),
    );
  }

  void _showDeleteDialog(BuildContext context, RevenueModel revenue) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleKeys.delete.tr()),
        content: Text(
          '${LocaleKeys.delete_confirmation.tr()} "${revenue.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RevenueCubit>().deleteRevenue(revenue.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(LocaleKeys.delete.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
