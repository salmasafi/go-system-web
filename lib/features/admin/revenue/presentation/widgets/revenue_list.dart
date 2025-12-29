import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/revenue/model/revenue_model.dart';
import 'package:systego/features/admin/revenue/presentation/widgets/animated_revenue_card.dart';
import 'package:systego/features/admin/revenue/presentation/widgets/revenue_form_dialof.dart';


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

}