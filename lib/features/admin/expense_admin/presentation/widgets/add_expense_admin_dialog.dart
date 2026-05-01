import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/bank_account/model/bank_account_model.dart';
import 'package:GoSystem/features/admin/expense_admin/cubit/expense_admin_cubit.dart';
import 'package:GoSystem/features/admin/expense_admin/cubit/expense_admin_state.dart';
import 'package:GoSystem/features/admin/expences_category/model/expences_categories_model.dart';

class AddExpenseAdminDialog extends StatefulWidget {
  const AddExpenseAdminDialog({super.key});

  @override
  State<AddExpenseAdminDialog> createState() => _AddExpenseAdminDialogState();
}

class _AddExpenseAdminDialogState extends State<AddExpenseAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<ExpenseCategoryModel> _categories = [];
  List<BankAccountModel> _accounts = [];
  ExpenseCategoryModel? _selectedCategory;
  BankAccountModel? _selectedAccount;
  bool _loadingData = true;

  static const _red = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        DioHelper.getData(url: EndPoint.getAllexpencesCategories),
        DioHelper.getData(url: EndPoint.getAllBankAccounts),
      ]);

      final catRes = results[0];
      final accRes = results[1];

      if (!mounted) return;

      setState(() {
        if (catRes.statusCode == 200 && catRes.data['success'] == true) {
          final list = catRes.data['data']['expenseCategories'] as List? ?? [];
          _categories = list
              .map((e) => ExpenseCategoryModel.fromJson(e))
              .where((c) => c.status)
              .toList();
        }
        if (accRes.statusCode == 200 && accRes.data['success'] == true) {
          final list = accRes.data['data']['accounts'] as List? ?? [];
          _accounts = list.map((e) => BankAccountModel.fromJson(e)).toList();
        }
        _loadingData = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      CustomSnackbar.showError(context, 'Please select a category');
      return;
    }
    if (_selectedAccount == null) {
      CustomSnackbar.showError(context, 'Please select a financial account');
      return;
    }

    context.read<ExpenseAdminCubit>().createExpense(
          name: _nameCtrl.text.trim(),
          amount: double.parse(_amountCtrl.text.trim()),
          categoryId: _selectedCategory!.id,
          financialAccountId: _selectedAccount!.id,
          note: _noteCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseAdminCubit, ExpenseAdminState>(
      listener: (context, state) {
        if (state is CreateExpenseAdminSuccess) {
          Navigator.pop(context);
          CustomSnackbar.showSuccess(context, state.message);
        } else if (state is CreateExpenseAdminError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 20),
          vertical: ResponsiveUI.padding(context, 40),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Divider(height: ResponsiveUI.value(context, 1), color: Color(0xFFF0F0F0)),
              if (_loadingData)
                Padding(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 32)),
                  child: CircularProgressIndicator(color: _red),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Row 1: Name + Amount
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  context,
                                  label: 'Expenses Name *',
                                  controller: _nameCtrl,
                                  hint: 'e.g. Robabicia',
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              SizedBox(width: ResponsiveUI.spacing(context, 12)),
                              Expanded(
                                child: _buildField(
                                  context,
                                  label: 'Amount *',
                                  controller: _amountCtrl,
                                  hint: 'e.g. 500',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    if (double.tryParse(v.trim()) == null) return 'Invalid number';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),

                          // Row 2: Category + Financial Account
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  context,
                                  label: 'Categories *',
                                  hint: 'Select category',
                                  value: _selectedCategory,
                                  items: _categories
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 13)),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedCategory = v),
                                ),
                              ),
                              SizedBox(width: ResponsiveUI.spacing(context, 12)),
                              Expanded(
                                child: _buildDropdownField(
                                  context,
                                  label: 'Financial Account *',
                                  hint: 'Select account',
                                  value: _selectedAccount,
                                  items: _accounts
                                      .map((a) => DropdownMenuItem(
                                            value: a,
                                            child: Text(
                                              a.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 13)),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedAccount = v),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),

                          // Note
                          _buildField(
                            context,
                            label: 'Note',
                            controller: _noteCtrl,
                            hint: 'Monthly payment',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Divider(height: ResponsiveUI.value(context, 1), color: Color(0xFFF0F0F0)),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            child: Icon(
              Icons.person_add_outlined,
              color: _red,
              size: ResponsiveUI.iconSize(context, 22),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Expense',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 17),
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                'Create a new expense entry',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.shadowGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            color: AppColors.darkGray,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              color: AppColors.shadowGray,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 14),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: BorderSide(color: _red, width: ResponsiveUI.value(context, 1.5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: const BorderSide(color: _red),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>(
    BuildContext context, {
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              color: AppColors.shadowGray,
            ),
          ),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            color: AppColors.darkGray,
            fontFamily: 'Rubik',
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.shadowGray),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 14),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: BorderSide(color: _red, width: ResponsiveUI.value(context, 1.5)),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<ExpenseAdminCubit, ExpenseAdminState>(
      builder: (context, state) {
        final isLoading = state is CreateExpenseAdminLoading;
        return Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkGray,
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 24),
                    vertical: ResponsiveUI.padding(context, 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 10),
                    ),
                  ),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? SizedBox(
                        width: ResponsiveUI.value(context, 16),
                        height: ResponsiveUI.value(context, 16),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.add_rounded, size: ResponsiveUI.iconSize(context, 18)),
                label: Text(
                  isLoading ? 'Creating...' : 'Create Expense',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 14)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 24),
                    vertical: ResponsiveUI.padding(context, 12),
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isRequired = text.endsWith('*');
    final label = isRequired ? text.replaceAll(' *', '') : text;
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 13),
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
          fontFamily: 'Rubik',
        ),
        children: isRequired
            ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE53935)),
                ),
              ]
            : [],
      ),
    );
  }
}
