import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/expense_admin/model/expense_admin_model.dart';
import 'package:GoSystem/features/admin/expense_admin/presentation/widgets/expense_admin_card.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../cubit/expences_cubit.dart';
import '../widgets/expences_dorm_dialog.dart' show ExpenseFormDialog;

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  void _init() {
    context.read<ExpensesCubit>().getExpenses();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _refresh() async => _init();

  void _showDeleteDialog(ExpenseAdminModel expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleKeys.delete.tr()),
        content: Text(
          '${LocaleKeys.delete_confirmation.tr()} "${expense.name}"?\n${LocaleKeys.this_action_cannot_be_undone.tr()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ExpensesCubit>().deleteExpense(expense.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(LocaleKeys.delete.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<ExpensesCubit, ExpensesState>(
      listener: (context, state) {
        if (state is GetExpensesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is CreateExpenseSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          _init();
        } else if (state is CreateExpenseError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteExpenseSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          _init();
        } else if (state is DeleteExpenseError) {
          CustomSnackbar.showError(context, state.error);
          _init();
        }
      },
      builder: (context, state) {
        if (state is GetExpensesLoading || state is DeleteExpenseLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFFE53935),
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        }

        if (state is GetExpensesSuccess) {
          if (state.expenses.isEmpty) {
            return CustomEmptyState(
              icon: Icons.receipt_long_rounded,
              title: LocaleKeys.expenses_title.tr(),
              message: LocaleKeys.empty_message_connection.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
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
                itemCount: state.expenses.length,
                itemBuilder: (context, index) {
                  final expense = state.expenses[index];
                  return GestureDetector(
                    onLongPress: () => _showDeleteDialog(expense),
                    child: Stack(
                      children: [
                        ExpenseAdminCard(expense: expense, index: index),
                        Positioned(
                          top: 0,
                          right: ResponsiveUI.value(context, 4),
                          child: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.withValues(alpha: 0.7),
                                size: ResponsiveUI.iconSize(context, 20)),
                            onPressed: () => _showDeleteDialog(expense),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }

        return CustomEmptyState(
          icon: Icons.receipt_long_rounded,
          title: LocaleKeys.expenses_title.tr(),
          message: LocaleKeys.pull_to_refresh_or_check_connection.tr(),
          onRefresh: _refresh,
          actionLabel: LocaleKeys.retry.tr(),
          onAction: _refresh,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.expenses_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ExpenseFormDialog(),
          );
        },
      ),
      body: SafeArea(child: _buildContent()),
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
}
