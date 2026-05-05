import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart';
import 'package:GoSystem/features/admin/purchase/presentation/view/edit_purchase_screen.dart';
import 'package:GoSystem/features/admin/purchase/presentation/widgets/purchase_card.dart';


class PurchaseList extends StatefulWidget {
  final List<Purchase> purchases;

  const PurchaseList({super.key, required this.purchases});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.purchase_list.tr(),
        showBackButton: true,
      ),
      body: SafeArea(
        child: widget.purchases.isEmpty
            ? Center(
                child: Text(
                  LocaleKeys.no_popups_default_message.tr(),
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                itemCount: widget.purchases.length,
                itemBuilder: (context, index) {
                  final purchase = widget.purchases[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
                    child: AnimatedPurchaseCard(
                      purchase: purchase,
                      onEdit: () => _showEditDialog(context, purchase),
                      onDelete: () {
                        // Implement delete if needed or pass from parent
                      },
                    ),
                  );
                },
              ),
      ),
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
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
