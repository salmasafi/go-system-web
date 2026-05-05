import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/pos/history/cubit/history_cubit.dart';
import 'package:GoSystem/features/pos/history/cubit/history_state.dart';
import 'package:GoSystem/features/pos/history/model/sale_model.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class PayDueDialog extends StatefulWidget {
  final DueSaleModel due;

  const PayDueDialog({super.key, required this.due});

  @override
  State<PayDueDialog> createState() => _PayDueDialogState();
}

class _PayDueDialogState extends State<PayDueDialog> {
  late List<BankAccount> _accounts;
  BankAccount? _selectedAccount;
  late TextEditingController _amountCtrl;

  static const _purple = AppColors.primaryBlue;

  @override
  void initState() {
    super.initState();
    _accounts = context.read<PosCubit>().accounts;
    _selectedAccount = _accounts.isNotEmpty ? _accounts.first : null;
    
    // Pre-fill with the remaining due amount
    _amountCtrl = TextEditingController(
      text: widget.due.remainingAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _paidNow => double.tryParse(_amountCtrl.text) ?? 0;

  void _confirm() {
    final amount = _paidNow;
    if (amount <= 0) {
      CustomSnackbar.showError(context, "Please enter a valid amount");
      return;
    }
    if (amount > widget.due.remainingAmount) {
      CustomSnackbar.showError(context, "Amount cannot exceed remaining due");
      return;
    }
    if (_selectedAccount == null) {
      CustomSnackbar.showError(context, "Please select a payment account");
      return;
    }

    context.read<HistoryCubit>().payDue(
          widget.due.id,
          widget.due.customerId,
          amount,
          _selectedAccount!.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistoryCubit, HistoryState>(
      listener: (context, state) {
        if (state is DuesPaySuccess) {
          Navigator.pop(context);
          CustomSnackbar.showSuccess(context, "Payment recorded successfully");
          context.read<HistoryCubit>().getAllDues();
        } else if (state is DuesPayError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 16),
          vertical: ResponsiveUI.padding(context, 24),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              _buildHeader(),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Summary card ──
                      _SummaryCard(due: widget.due, paidNow: _paidNow),
                      SizedBox(height: ResponsiveUI.value(context, 20)),

                      // ── Account dropdown ──
                      if (_accounts.isEmpty)
                        const _NoAccountsHint()
                      else ...[
                        Text(
                          'Payment Account',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 8)),
                        Container(
                          height: ResponsiveUI.value(context, 52),
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 12),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightGray),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUI.borderRadius(context, 12),
                            ),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BankAccount>(
                              value: _selectedAccount,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: ResponsiveUI.iconSize(context, 20),
                                color: _purple,
                              ),
                              items: _accounts
                                  .map((a) => DropdownMenuItem(
                                        value: a,
                                        child: Text(
                                          a.name,
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(context, 14),
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkGray,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (acc) {
                                if (acc != null) {
                                  setState(() => _selectedAccount = acc);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 16)),

                        // ── Amount field ──
                        Text(
                          'Payment Amount',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 8)),
                        SizedBox(
                          height: ResponsiveUI.value(context, 52),
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 15),
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              prefixText: 'EGP  ',
                              prefixStyle: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                color: AppColors.darkGray.withValues(alpha: 0.5),
                              ),
                              hintText: widget.due.remainingAmount.toStringAsFixed(2),
                              hintStyle: TextStyle(
                                color: AppColors.darkGray.withValues(alpha: 0.4),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 14),
                                vertical: ResponsiveUI.padding(context, 14),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUI.borderRadius(context, 12),
                                ),
                                borderSide: const BorderSide(color: AppColors.lightGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUI.borderRadius(context, 12),
                                ),
                                borderSide: BorderSide(
                                  color: _purple,
                                  width: ResponsiveUI.value(context, 1.5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUI.borderRadius(context, 12),
                                ),
                                borderSide: const BorderSide(color: AppColors.lightGray),
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: ResponsiveUI.value(context, 24)),

                      // ── Actions ──
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveUI.padding(context, 14),
                                ),
                                side: const BorderSide(color: AppColors.lightGray),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUI.borderRadius(context, 12),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.darkGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.value(context, 12)),
                          Expanded(
                            flex: 2,
                            child: BlocBuilder<HistoryCubit, HistoryState>(
                              builder: (context, state) {
                                final isLoading = state is DuesPayLoading;
                                return ElevatedButton(
                                  onPressed: (_paidNow > 0 && !isLoading) ? _confirm : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _purple,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: _purple.withValues(alpha: 0.4),
                                    padding: EdgeInsets.symmetric(
                                      vertical: ResponsiveUI.padding(context, 14),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUI.borderRadius(context, 12),
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Confirm Payment',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: ResponsiveUI.fontSize(context, 14),
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
        child: Row(
          children: [
            Icon(Icons.payment, color: _purple, size: ResponsiveUI.iconSize(context, 24)),
            SizedBox(width: ResponsiveUI.value(context, 10)),
            Expanded(
              child: Text(
                'Pay Due Amount',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 18),
                  fontWeight: FontWeight.w800,
                  color: _purple,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: AppColors.shadowGray),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final DueSaleModel due;
  final double paidNow;

  const _SummaryCard({required this.due, required this.paidNow});

  @override
  Widget build(BuildContext context) {
    final remaining =
        (due.remainingAmount - paidNow).clamp(0.0, double.infinity);

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 14),
        ),
        border: Border.all(
          color: AppColors.lightGray,
          width: ResponsiveUI.value(context, 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: ResponsiveUI.iconSize(context, 16),
                  color: AppColors.shadowGray),
              SizedBox(width: ResponsiveUI.value(context, 6)),
              Text(
                'Customer: ',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  color: AppColors.darkGray.withValues(alpha: 0.7),
                ),
              ),
              Expanded(
                child: Text(
                  '${due.customerName} (${due.phone})',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.value(context, 8)),
          // Reference
          Row(
            children: [
              Icon(Icons.receipt_outlined,
                  size: ResponsiveUI.iconSize(context, 16),
                  color: AppColors.shadowGray),
              SizedBox(width: ResponsiveUI.value(context, 6)),
              Text(
                'Ref: ${due.reference}',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 12),
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Divider(
            height: ResponsiveUI.value(context, 1),
            color: AppColors.lightGray,
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          _SummaryRow(
            label: 'Grand Total:',
            value: '${due.grandTotal.toStringAsFixed(2)} EGP',
            valueColor: AppColors.darkGray,
            bold: false,
          ),
          SizedBox(height: ResponsiveUI.value(context, 6)),
          _SummaryRow(
            label: 'Already Paid:',
            value: '${due.paidAmount.toStringAsFixed(2)} EGP',
            valueColor: AppColors.successGreen,
            bold: false,
          ),
          SizedBox(height: ResponsiveUI.value(context, 6)),
          _SummaryRow(
            label: 'Total Due:',
            value: '${due.remainingAmount.toStringAsFixed(2)} EGP',
            valueColor: AppColors.red,
            bold: true,
          ),
          SizedBox(height: ResponsiveUI.value(context, 6)),
          _SummaryRow(
            label: 'Paying Now:',
            value: '${paidNow.toStringAsFixed(2)} EGP',
            valueColor: AppColors.primaryBlue,
            bold: false,
          ),
          SizedBox(height: ResponsiveUI.value(context, 6)),
          _SummaryRow(
            label: 'Remaining After:',
            value: '${remaining.toStringAsFixed(2)} EGP',
            valueColor: remaining > 0 ? AppColors.red : AppColors.successGreen,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            color: bold
                ? AppColors.darkGray
                : AppColors.darkGray.withValues(alpha: 0.7),
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            color: valueColor,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── No Accounts Hint ─────────────────────────────────────────────────────────

class _NoAccountsHint extends StatelessWidget {
  const _NoAccountsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 14)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 10),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: ResponsiveUI.iconSize(context, 18),
              color: AppColors.primaryBlue),
          SizedBox(width: ResponsiveUI.value(context, 8)),
          Expanded(
            child: Text(
              'No financial accounts found. Please add accounts first.',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
