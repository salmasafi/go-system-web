import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/currency/cubit/currency_cubit.dart';
import 'package:systego/features/admin/currency/model/currency_model.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import 'animated_currency_card.dart';
import 'currrency_form_dialog.dart';

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
        return AnimatedCurrencyCard(
          currency: currencies[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, currencies[index]),
          onEdit: () => _showEditDialog(context, currencies[index]),
          // onTap: () => context.read<CurrencyCubit>().getCurrencyById(
          //   currencies[index].id,
          // ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, CurrencyModel currency) {
    showDialog(
      context: context,
      builder: (context) => CurrencyFormDialog(currency: currency),
    );
  }

  void _showDeleteDialog(BuildContext context, CurrencyModel currency) {
    if (currency.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid Currency ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Currency',
        message:
            'Are you sure you want to delete this currency?\n"${currency.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CurrencyCubit>().deleteCurrency(currency.id);
        },
      ),
    );
  }
}
