import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/pos/expenses/cubit/expense_cubit.dart';
import 'package:GoSystem/features/pos/expenses/model/expense_model.dart';
import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:GoSystem/features/admin/bank_account/model/bank_account_model.dart';
import 'package:GoSystem/features/admin/expences_category/model/expences_categories_model.dart';

const _purple = Color(0xFF7C3AED);

class AddExpenseDialog extends StatefulWidget {
  /// null = add mode, non-null = edit mode
  final ExpenseModel? expense;

  const AddExpenseDialog({super.key, this.expense});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  late final TextEditingController _expenseCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  ExpenseCategoryModel? _selectedCategory;
  BankAccountModel? _selectedAccount;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _expenseCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl =
        TextEditingController(text: e != null ? e.amount.toString() : '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    // Load categories when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseCubit>().getCategories();
    });
  }

  @override
  void dispose() {
    _expenseCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _expenseCtrl.text.trim();
    final amount = _amountCtrl.text.trim();

    if (name.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter expense name');
      return;
    }
    if (_selectedCategory == null) {
      CustomSnackbar.showWarning(context, 'Please select a category');
      return;
    }
    if (amount.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter amount');
      return;
    }
    if (_selectedAccount == null) {
      CustomSnackbar.showWarning(context, 'Please select a financial account');
      return;
    }

    if (_isEdit) {
      context.read<ExpenseCubit>().updateExpense(
            id: widget.expense!.id,
            name: name,
            categoryId: _selectedCategory!.id,
            amount: amount,
            note: _noteCtrl.text.trim(),
            financialAccountId: _selectedAccount!.id,
          );
    } else {
      context.read<ExpenseCubit>().addExpense(
            name: name,
            categoryId: _selectedCategory!.id,
            amount: amount,
            note: _noteCtrl.text.trim(),
            financialAccountId: _selectedAccount!.id,
          );
    }
  }

  /// Pre-select category & account once lists are loaded
  void _tryPreselect(
      List<ExpenseCategoryModel> cats, List<BankAccountModel> accs) {
    final e = widget.expense;
    if (e == null) return;
    if (_selectedCategory == null && cats.isNotEmpty) {
      final match = cats.where((c) => c.id == e.categoryId);
      if (match.isNotEmpty) setState(() => _selectedCategory = match.first);
    }
    if (_selectedAccount == null && accs.isNotEmpty) {
      final match = accs.where((a) => a.id == e.financialAccountId);
      if (match.isNotEmpty) setState(() => _selectedAccount = match.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseSuccess) {
          Navigator.pop(context);
          CustomSnackbar.showSuccess(
            context,
            _isEdit
                ? 'Expense updated successfully'
                : 'Expense added successfully',
          );
        } else if (state is ExpenseError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding:
            EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16), vertical: ResponsiveUI.padding(context, 24)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16))),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEdit ? 'Edit Expense' : 'Add Expense',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('X',
                        style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray)),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 20)),

              // ── Expense name ──
              _Label('Expense'),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              _InputField(controller: _expenseCtrl),
              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // ── Category ──
              _Label('Category'),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  final cats = state is ExpenseCategoriesLoaded
                      ? state.categories
                      : <ExpenseCategoryModel>[];
                  final accState = context.read<BankAccountCubit>().state;
                  final accs = accState is GetBankAccountsSuccess
                      ? accState.accounts
                      : <BankAccountModel>[];
                  _tryPreselect(cats, accs);
                  return _DropdownField<ExpenseCategoryModel>(
                    hint: state is ExpenseCategoriesLoading
                        ? 'Loading...'
                        : 'Select Category',
                    value: _selectedCategory,
                    items: cats,
                    itemLabel: (c) => c.name,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  );
                },
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // ── Amount ──
              _Label('Amount'),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              _InputField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // ── Note ──
              _Label('Note'),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              _InputField(controller: _noteCtrl, maxLines: 4),
              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // ── Financial Account ──
              _Label('Financial Account'),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              BlocBuilder<BankAccountCubit, BankAccountState>(
                builder: (context, state) {
                  final accs = state is GetBankAccountsSuccess
                      ? state.accounts
                      : <BankAccountModel>[];
                  final catState = context.read<ExpenseCubit>().state;
                  final cats = catState is ExpenseCategoriesLoaded
                      ? catState.categories
                      : <ExpenseCategoryModel>[];
                  _tryPreselect(cats, accs);
                  return _DropdownField<BankAccountModel>(
                    hint: state is GetBankAccountsLoading
                        ? 'Loading...'
                        : 'Select Account',
                    value: _selectedAccount,
                    items: accs,
                    itemLabel: (a) => a.name,
                    onChanged: (v) => setState(() => _selectedAccount = v),
                  );
                },
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // ── Submit ──
              BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  final isLoading = state is ExpenseSubmitting;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _purple.withValues(alpha: 0.5),
                        padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUI.padding(context, 16)),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10))),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: ResponsiveUI.value(context, 20),
                              height: ResponsiveUI.value(context, 20),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _isEdit ? 'Save' : 'Add',
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  const _InputField({
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 12),
            vertical: ResponsiveUI.padding(context, 12),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              borderSide: BorderSide(color: AppColors.lightGray)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              borderSide: BorderSide(color: AppColors.lightGray)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              borderSide:
                  BorderSide(color: Color(0xFF7C3AED), width: ResponsiveUI.value(context, 1.5))),
        ),
      );
}

class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
          vertical: ResponsiveUI.padding(context, 4),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray),
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint,
                style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.darkGray.withValues(alpha: 0.5))),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGray),
            items: items
                .map((e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(itemLabel(e),
                          style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 14),
                              color: AppColors.darkGray)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
