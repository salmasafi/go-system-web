import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
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
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: 'Expense Admin',
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<ExpenseAdminCubit>(),
            child: const AddExpenseAdminDialog(),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: Column(
            children: [
              // ── Search bar ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUI.padding(context, 16),
                  ResponsiveUI.padding(context, 12),
                  ResponsiveUI.padding(context, 16),
                  0,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      context.read<ExpenseAdminCubit>().search(v),
                  decoration: InputDecoration(
                    hintText: 'Search by name, account, note...',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.shadowGray,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.shadowGray,
                      size: ResponsiveUI.iconSize(context, 20),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: AppColors.shadowGray),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ExpenseAdminCubit>().search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                      vertical: ResponsiveUI.padding(context, 12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.lightGray.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                      borderSide: BorderSide(
                        color: Color(0xFFE53935),
                        width: ResponsiveUI.value(context, 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 8)),

              // ── List ──
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
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
