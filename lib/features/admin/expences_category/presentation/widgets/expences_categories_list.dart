import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:systego/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:systego/features/admin/expences_category/presentation/widgets/animated_expences_categories_card.dart';
import 'package:systego/features/admin/expences_category/presentation/widgets/expences_categories_form_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class ExpenseCategoriesList extends StatelessWidget {
  final List<ExpenseCategoryModel> expenseCategories;
  
  const ExpenseCategoriesList({
    super.key, 
    required this.expenseCategories
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
        bottom: ResponsiveUI.padding(context, 16),
      ),
      itemCount: expenseCategories.length,
      itemBuilder: (context, index) {
        return AnimatedExpenseCategoryCard(
          category: expenseCategories[index],
          // index: index,
          onDelete: () => _showDeleteDialog(context, expenseCategories[index]),
          onEdit: () => _showEditDialog(context, expenseCategories[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, ExpenseCategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => ExpenseCategoryFormDialog(category: category),
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseCategoryModel category) {
    if (category.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_expense_category_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_expense_category.tr(),
        message:
            '${LocaleKeys.delete_expense_category_message.tr()} \n"${category.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<ExpenseCategoryCubit>().deleteExpenseCategory(category.id);
        },
      ),
    );
  }
}