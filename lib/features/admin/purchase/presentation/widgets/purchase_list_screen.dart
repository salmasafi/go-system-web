import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/purchase/model/purchase_model.dart';
import 'package:systego/features/admin/purchase/presentation/view/edit_purchase_screen.dart';
import 'package:systego/features/admin/purchase/presentation/widgets/purchase_card.dart';


class PurchaseList extends StatefulWidget {
  final List<Purchase> purchases;

  const PurchaseList({super.key, required this.purchases});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
        bottom: ResponsiveUI.padding(context, 80), // Extra space for FAB if needed
      ),
      itemCount: widget.purchases.length,
      itemBuilder: (context, index) {
        return AnimatedPurchaseCard(
          purchase: widget.purchases[index],
          index: index,
          onEdit: () => _showEditDialog(context, widget.purchases[index]),
        );
      },
    );
  }

    void _showEditDialog(BuildContext context, Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) => EditPurchaseBottomSheet(
        purchase: purchase,
      ),
    );
  }
}