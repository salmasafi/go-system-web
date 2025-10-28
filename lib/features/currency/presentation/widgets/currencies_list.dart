import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/currency/model/currency_model.dart';
import 'animated_currency_card.dart';

class CurrenciesList extends StatelessWidget {
  final List<CurrencyModel> currencies;
  const CurrenciesList({super.key, required this.currencies});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        return AnimatedCurrencyCard(currency: currencies[index], index: index);
      },
    );
  }

  // void _showDeleteDialog(BuildContext context, NotificationModel notification) {
  //   if (notification.id.isEmpty) {
  //     CustomSnackbar.showError(context, 'Invalid notification ID');
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => CustomDeleteDialog(
  //       title: 'Delete Notification',
  //       message:
  //           'Are you sure you want to delete this notification?\n"${notification.message}"',
  //       onDelete: () {
  //         Navigator.pop(dialogContext);
  //         context.read<CurrenciesCubit>().deleteNotification(notification.id);
  //       },
  //     ),
  //   );
  // }
}
