import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:systego/features/admin/expences_category/presentation/widgets/expences_categories_form_dialog.dart';
import 'package:systego/features/admin/expences_category/presentation/widgets/expences_categories_list.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() => _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  void expenseCategoriesInit() async {
    context.read<ExpenseCategoryCubit>().getExpenseCategories();
  }

  @override
  void initState() {
    super.initState();
    expenseCategoriesInit();
  }

  Future<void> _refresh() async {
    expenseCategoriesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<ExpenseCategoryCubit, ExpenseCategoryState>(
      listener: (context, state) {
        if (state is GetExpenseCategoriesError) {
          CustomSnackbar.showError(context, state.errorMessage);
        } else if (state is DeleteExpenseCategoryError) {
          CustomSnackbar.showError(context, state.errorMessage);
          expenseCategoriesInit();
        } else if (state is DeleteExpenseCategorySuccess) {
          CustomSnackbar.showSuccess(context, state.successMessage);
          expenseCategoriesInit();
        } else if (state is CreateExpenseCategorySuccess) {
          CustomSnackbar.showSuccess(context, state.successMessage);
          expenseCategoriesInit();
        } else if (state is UpdateExpenseCategorySuccess) {
          CustomSnackbar.showSuccess(context, state.successMessage);
          expenseCategoriesInit();
        }
      },
      builder: (context, state) {
        if (state is GetExpenseCategoriesLoading ||
            state is DeleteExpenseCategoryLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetExpenseCategoriesSuccess) {
          final expenseCategories = state.expenseCategories;

          if (expenseCategories.isEmpty) {
            String title = expenseCategories.isEmpty
                ? LocaleKeys.no_expense_categories.tr()
                : LocaleKeys.no_matching_expense_categories.tr();
            String message = expenseCategories.isEmpty
                ? LocaleKeys.expense_categories_all_caught_up.tr()
                : LocaleKeys.expense_categories_try_adjusting_filters.tr();
            return CustomEmptyState(
              icon: Icons.category_rounded,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: ExpenseCategoriesList(expenseCategories: expenseCategories),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.category_rounded,
            title: LocaleKeys.no_expense_categories.tr(),
            message: LocaleKeys.empty_connection.tr(),
            onRefresh: _refresh,
            actionLabel: LocaleKeys.retry.tr(),
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.expense_categories_title.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => ExpenseCategoryFormDialog(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: AnimatedElement(
            delay: const Duration(milliseconds: 200),
            child: _buildListContent(),
          ),
        ),
      ),
    );
  }
}