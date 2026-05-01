import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/pos/expenses/cubit/expense_cubit.dart';
import 'package:systego/features/pos/expenses/model/expense_model.dart';
import 'package:systego/features/pos/expenses/presentation/add_expense_dialog.dart';
import 'package:systego/features/admin/bank_account/cubit/bank_account_cubit.dart';

const _purple = Color(0xFF7C3AED);

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ExpenseCubit()..getExpenses()..getCategories()),
        BlocProvider.value(value: context.read<BankAccountCubit>()..getBankAccounts()),
      ],
      child: const _ExpensesScreenContent(),
    );
  }
}

class _ExpensesScreenContent extends StatelessWidget {
  const _ExpensesScreenContent();

  void _openDialog(BuildContext context, {ExpenseModel? expense}) {
    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ExpenseCubit>()),
          BlocProvider.value(value: context.read<BankAccountCubit>()),
        ],
        child: AddExpenseDialog(expense: expense),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF4F6FB),
        appBar: AppBar(
          title: Text(
            'Expenses',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 18)),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkGray,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
          ),
        ),
        body: BlocBuilder<ExpenseCubit, ExpenseState>(
          buildWhen: (_, curr) =>
              curr is ExpensesLoading ||
              curr is ExpensesLoaded ||
              curr is ExpenseError,
          builder: (context, state) {
            if (state is ExpensesLoading) {
              return Center(child: CustomLoadingState());
            }
            if (state is ExpensesLoaded) {
              if (state.expenses.isEmpty) {
                return _EmptyView(
                    onAdd: () => _openDialog(context));
              }
              return RefreshIndicator(
                color: _purple,
                onRefresh: () => context.read<ExpenseCubit>().getExpenses(),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: state.expenses.length,
                  itemBuilder: (_, i) => _ExpenseCard(
                    expense: state.expenses[i],
                    onEdit: () =>
                        _openDialog(context, expense: state.expenses[i]),
                  ),
                ),
              );
            }
            return SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openDialog(context),
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          elevation: ResponsiveUI.value(context, 4),
          child: Icon(Icons.add_rounded, size: ResponsiveUI.iconSize(context, 28)),
        ),
      ),
    );
  }
}

// ─── Expense Card ─────────────────────────────────────────────────────────────

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;

  const _ExpenseCard({required this.expense, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: icon ──
            Container(
              width: ResponsiveUI.value(context, 44),
              height: ResponsiveUI.value(context, 44),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              ),
              child: Icon(Icons.receipt_long_rounded,
                  color: _purple, size: ResponsiveUI.iconSize(context, 22)),
            ),
            SizedBox(width: ResponsiveUI.value(context, 12)),

            // ── Middle: details ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGray,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 6)),
                  _InfoRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Price',
                      value: '${expense.amount.toStringAsFixed(2)} EGP'),
                  _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: expense.categoryName),
                  _InfoRow(
                      icon: Icons.account_balance_outlined,
                      label: 'Financial Account',
                      value: expense.financialAccountName),
                  if (expense.note.isNotEmpty)
                    _InfoRow(
                        icon: Icons.notes_rounded,
                        label: 'Note',
                        value: expense.note),
                ],
              ),
            ),

            // ── Right: edit ──
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                ),
                child: Icon(Icons.edit_outlined,
                    color: _purple, size: ResponsiveUI.iconSize(context, 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ResponsiveUI.padding(context, 4)),
      child: Row(
        children: [
          Icon(icon, size: ResponsiveUI.iconSize(context, 13), color: AppColors.shadowGray),
          SizedBox(width: ResponsiveUI.value(context, 4)),
          Text(
            '$label: ',
            style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.shadowGray),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty ────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: ResponsiveUI.iconSize(context, 52), color: _purple),
          ),
          SizedBox(height: ResponsiveUI.value(context, 20)),
          Text('No Expenses',
              style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 20),
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray)),
          SizedBox(height: ResponsiveUI.value(context, 8)),
          Text('Tap + to add your first expense',
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.shadowGray)),
        ],
      ),
    );
  }
}
