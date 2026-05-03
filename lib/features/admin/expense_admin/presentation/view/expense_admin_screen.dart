import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../cubit/expense_admin_cubit.dart';
import '../../cubit/expense_admin_state.dart';
import '../widgets/add_expense_admin_dialog.dart';
import '../widgets/expense_admin_card.dart';

class ExpenseAdminScreen extends StatefulWidget {
  const ExpenseAdminScreen({super.key});

  @override
  State<ExpenseAdminScreen> createState() => _ExpenseAdminScreenState();
}

class _ExpenseAdminScreenState extends State<ExpenseAdminScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ExpenseAdminCubit>().getExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _searchController.clear();
    context.read<ExpenseAdminCubit>().search('');
    await context.read<ExpenseAdminCubit>().getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.expenses_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddExpenseAdminDialog(),
          );
        },
      ),
      body: SafeArea(
        child: _buildList(),
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

  Widget _buildList() {
    return BlocConsumer<ExpenseAdminCubit, ExpenseAdminState>(
      listener: (context, state) {
        if (state is GetExpensesAdminError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is CreateExpenseAdminSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
        } else if (state is CreateExpenseAdminError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is GetExpensesAdminLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFFE53935),
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        }

        if (state is GetExpensesAdminSuccess) {
          final expenses = state.expenses;

          if (expenses.isEmpty) {
            return CustomEmptyState(
              icon: Icons.receipt_long_rounded,
              title: _searchController.text.isNotEmpty
                  ? 'No matching expenses'
                  : 'No Expenses',
              message: _searchController.text.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'No expenses found',
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFFE53935),
            child: AnimatedElement(
              delay: const Duration(milliseconds: 100),
              child: ListView.builder(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                itemCount: expenses.length,
                itemBuilder: (context, index) => ExpenseAdminCard(
                  expense: expenses[index],
                  index: index,
                ),
              ),
            ),
          );
        }

        return CustomEmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'No Expenses',
          message: 'Pull to refresh or check your connection',
          onRefresh: _refresh,
          actionLabel: 'Retry',
          onAction: _refresh,
        );
      },
    );
  }
}
