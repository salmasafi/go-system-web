import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/utils/validators.dart';
import 'package:GoSystem/core/widgets/custom_loading/build_overlay_loading.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/build_text_field.dart';
import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:GoSystem/features/admin/bank_account/model/bank_account_model.dart';
import 'package:GoSystem/features/admin/expences/cubit/expences_cubit.dart';
import 'package:GoSystem/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:GoSystem/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class ExpenseFormDialog extends StatefulWidget {
  const ExpenseFormDialog({super.key});

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategoryModel? _selectedCategory;
  BankAccountModel? _selectedAccount;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  static const _accent = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseCategoryCubit>().getExpenseCategories();
      context.read<BankAccountCubit>().getBankAccounts();
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      CustomSnackbar.showError(context, LocaleKeys.please_select_category.tr());
      return;
    }
    if (_selectedAccount == null) {
      CustomSnackbar.showError(context, LocaleKeys.please_select_financial_account.tr());
      return;
    }
    context.read<ExpensesCubit>().createExpense(
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text.trim().replaceAll(',', '.')),
          categoryId: _selectedCategory!.id,
          financialAccountId: _selectedAccount!.id,
          note: _noteController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<ExpensesCubit, ExpensesState>(
          listener: (context, state) {
            if (state is CreateExpenseSuccess) {
              Navigator.pop(context);
            } else if (state is CreateExpenseError) {
              CustomSnackbar.showError(context, state.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateExpenseLoading;
            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: ResponsiveUI.screenHeight(context) * 0.85,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  Flexible(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.all(
                            ResponsiveUI.padding(context, 24),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                buildTextField(
                                  context,
                                  controller: _nameController,
                                  label: LocaleKeys.revenue_name.tr(),
                                  icon: Icons.receipt_long_rounded,
                                  hint: LocaleKeys.hint_revenue_name.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.revenue_name.tr(),
                                      ),
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _amountController,
                                  label: LocaleKeys.amount.tr(),
                                  icon: Icons.attach_money_rounded,
                                  hint: LocaleKeys.amount_hint.tr(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return LocaleKeys.please_enter_amount.tr();
                                    }
                                    if (double.tryParse(v.trim().replaceAll(',', '.')) == null) {
                                      return LocaleKeys.amount_must_be_valid_number.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                // Categories dropdown
                                BlocBuilder<ExpenseCategoryCubit, ExpenseCategoryState>(
                                  builder: (context, catState) {
                                    List<ExpenseCategoryModel> categories = [];
                                    if (catState is GetExpenseCategoriesSuccess) {
                                      categories = catState.expenseCategories
                                          .where((c) => c.status)
                                          .toList();
                                    }
                                    return buildDropdownField<ExpenseCategoryModel>(
                                      context,
                                      value: _selectedCategory,
                                      items: categories,
                                      label: LocaleKeys.expense_categories_title.tr(),
                                      icon: Icons.category_rounded,
                                      hint: LocaleKeys.select_category.tr(),
                                      onChanged: (val) =>
                                          setState(() => _selectedCategory = val),
                                      itemLabel: (cat) => cat.name,
                                      validator: (v) => v == null
                                          ? LocaleKeys.please_select_category.tr()
                                          : null,
                                    );
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                // Financial accounts dropdown
                                BlocBuilder<BankAccountCubit, BankAccountState>(
                                  builder: (context, accState) {
                                    List<BankAccountModel> accounts = [];
                                    if (accState is GetBankAccountsSuccess) {
                                      accounts = accState.accounts;
                                    }
                                    return buildDropdownField<BankAccountModel>(
                                      context,
                                      value: _selectedAccount,
                                      items: accounts,
                                      label: LocaleKeys.financial_account.tr(),
                                      icon: Icons.account_balance_rounded,
                                      hint: LocaleKeys.select_financial_account.tr(),
                                      onChanged: (val) =>
                                          setState(() => _selectedAccount = val),
                                      itemLabel: (acc) => acc.name,
                                      validator: (v) => v == null
                                          ? LocaleKeys.please_select_financial_account.tr()
                                          : null,
                                    );
                                  },
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                buildTextField(
                                  context,
                                  controller: _noteController,
                                  label: LocaleKeys.note.tr(),
                                  icon: Icons.notes_rounded,
                                  hint: LocaleKeys.hint_note.tr(),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  _buildButtons(context, isLoading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accent, Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
          topRight: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: ResponsiveUI.iconSize(context, 28),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.expenses_title.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUI.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  LocaleKeys.financial_group.tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
              child: Icon(Icons.close, color: Colors.white,
                  size: ResponsiveUI.iconSize(context, 24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isLoading) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
          bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 16),
                ),
                side: BorderSide(color: AppColors.shadowGray[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
              ),
              child: Text(LocaleKeys.cancel.tr()),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _submit,
              icon: Icon(Icons.add_rounded, size: ResponsiveUI.iconSize(context, 20)),
              label: Text(LocaleKeys.expenses_title.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
