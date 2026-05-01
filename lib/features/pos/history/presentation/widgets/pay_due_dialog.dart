import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/pos/history/cubit/history_cubit.dart';
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
  final List<_PaymentRow> _rows = [];
  late List<BankAccount> _accounts;

  static const _purple = AppColors.primaryBlue;

  @override
  void initState() {
    super.initState();
    // Use accounts already loaded & filtered by PosCubit (from posSelections endpoint)
    _accounts = context.read<PosCubit>().accounts;
    if (_accounts.isNotEmpty) {
      _rows.add(_PaymentRow(account: _accounts.first));
    }
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.controller.dispose();
    }
    super.dispose();
  }

  double get _paidNow =>
      _rows.fold(0, (s, r) => s + (double.tryParse(r.controller.text) ?? 0));

  void _addRow() {
    if (_accounts.isEmpty) return;
    setState(() => _rows.add(_PaymentRow(account: _accounts.first)));
  }

  void _removeRow(int index) {
    _rows[index].controller.dispose();
    setState(() => _rows.removeAt(index));
  }

  void _confirm() {
    final total = _paidNow;
    if (total <= 0) return;

    final financials = _rows
        .where((r) => (double.tryParse(r.controller.text) ?? 0) > 0)
        .map((r) => {
              'account_id': r.account.id,
              'amount': double.tryParse(r.controller.text) ?? 0,
              'description': '',
            })
        .toList();

    Navigator.pop(context);
    context.read<HistoryCubit>().payDue(
          widget.due.id,
          widget.due.customerId,
          total,
          financials,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16), vertical: ResponsiveUI.padding(context, 24)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            _Header(onClose: () => Navigator.pop(context)),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary card ──
                    _SummaryCard(due: widget.due, paidNow: _paidNow),
                    SizedBox(height: ResponsiveUI.value(context, 20)),

                    // ── Payment rows ──
                    if (_accounts.isEmpty)
                      const _NoAccountsHint()
                    else ...[
                      ..._rows.asMap().entries.map((e) => _PaymentRowWidget(
                            key: ValueKey(e.key),
                            row: e.value,
                            accounts: _accounts,
                            usedAccountIds: _rows
                                .where((r) => r != e.value)
                                .map((r) => r.account.id)
                                .toList(),
                            canRemove: _rows.length > 1,
                            onRemove: () => _removeRow(e.key),
                            onChanged: () => setState(() {}),
                            onAccountChanged: (acc) =>
                                setState(() => e.value.account = acc),
                          )),
                      SizedBox(height: ResponsiveUI.value(context, 8)),
                      // Add payment method
                      if (_rows.length < _accounts.length)
                        GestureDetector(
                          onTap: _addRow,
                          child: Row(
                            children: [
                              Icon(Icons.add_circle_outline,
                                  color: _purple, size: ResponsiveUI.iconSize(context, 18)),
                              SizedBox(width: ResponsiveUI.value(context, 6)),
                              Text(
                                '+ Add Payment Method',
                                style: TextStyle(
                                  color: _purple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveUI.fontSize(context, 14),
                                ),
                              ),
                            ],
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
                              padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 14)),
                              side: const BorderSide(color: AppColors.lightGray),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12))),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        SizedBox(width: ResponsiveUI.value(context, 12)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _paidNow > 0 ? _confirm : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _purple,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _purple.withValues(alpha: 0.4),
                              padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 14)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12))),
                              elevation: 0,
                            ),
                            child: Text('Confirm Due Payment',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 13))),
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
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Partial Payment & Due',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: AppColors.shadowGray),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final DueSaleModel due;
  final double paidNow;

  const _SummaryCard({required this.due, required this.paidNow});

  @override
  Widget build(BuildContext context) {
    final remaining =
        (due.remainingAmount - paidNow).clamp(0, double.infinity);

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
        border: Border.all(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: ResponsiveUI.iconSize(context, 16), color: AppColors.shadowGray),
              SizedBox(width: ResponsiveUI.value(context, 6)),
              Text(
                'Customer: ',
                style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    color: AppColors.darkGray.withValues(alpha: 0.7)),
              ),
              Expanded(
                child: Text(
                  '${due.customerName} (${due.phone})',
                  style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGray),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Divider(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          _SummaryRow(
              label: 'Total Due:',
              value: '${due.remainingAmount.toStringAsFixed(2)} EGP',
              valueColor: AppColors.darkGray,
              bold: true),
          SizedBox(height: ResponsiveUI.value(context, 6)),
          _SummaryRow(
              label: 'Paid Now:',
              value: '${paidNow.toStringAsFixed(2)} EGP',
              valueColor: AppColors.successGreen,
              bold: false),
          SizedBox(height: ResponsiveUI.value(context, 6)),
          _SummaryRow(
              label: 'Remaining Due:',
              value: '${remaining.toStringAsFixed(2)} EGP',
              valueColor: AppColors.primaryBlue,
              bold: true),
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
        Text(label,
            style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                color: bold
                    ? AppColors.darkGray
                    : AppColors.darkGray.withValues(alpha: 0.7),
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                color: valueColor,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
      ],
    );
  }
}

// ─── Payment Row Model ────────────────────────────────────────────────────────

class _PaymentRow {
  BankAccount account;
  final TextEditingController controller = TextEditingController();

  _PaymentRow({required this.account});
}

// ─── Payment Row Widget ───────────────────────────────────────────────────────

class _PaymentRowWidget extends StatelessWidget {
  final _PaymentRow row;
  final List<BankAccount> accounts;
  final List<String> usedAccountIds;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final ValueChanged<BankAccount> onAccountChanged;

  const _PaymentRowWidget({
    super.key,
    required this.row,
    required this.accounts,
    required this.usedAccountIds,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
    required this.onAccountChanged,
  });

  static const _purple = AppColors.primaryBlue;

  @override
  Widget build(BuildContext context) {
    final available = accounts
        .where((a) => a.id == row.account.id || !usedAccountIds.contains(a.id))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 10)),
      child: Row(
        children: [
          // Account dropdown
          Container(
            height: ResponsiveUI.value(context, 48),
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGray),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BankAccount>(
                value: row.account,
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: ResponsiveUI.iconSize(context, 18), color: _purple),
                items: available
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.name,
                              style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 13),
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGray)),
                        ))
                    .toList(),
                onChanged: (acc) {
                  if (acc != null) onAccountChanged(acc);
                },
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.value(context, 8)),
          // Amount field
          Expanded(
            child: SizedBox(
              height: ResponsiveUI.value(context, 48),
              child: TextField(
                controller: row.controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => onChanged(),
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.darkGray),
                decoration: InputDecoration(
                  prefixText: 'EGP  ',
                  prefixStyle: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.darkGray.withValues(alpha: 0.5)),
                  hintText: '0.00',
                  hintStyle: TextStyle(
                      color: AppColors.darkGray.withValues(alpha: 0.4)),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 12), vertical: ResponsiveUI.padding(context, 12)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                    borderSide: BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                    borderSide: BorderSide(color: _purple, width: ResponsiveUI.value(context, 1.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                ),
              ),
            ),
          ),
          // Remove button
          if (canRemove) ...[
            SizedBox(width: ResponsiveUI.value(context, 6)),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close,
                  size: ResponsiveUI.iconSize(context, 18), color: AppColors.shadowGray),
            ),
          ],
        ],
      ),
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
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: ResponsiveUI.iconSize(context, 18), color: AppColors.primaryBlue),
          SizedBox(width: ResponsiveUI.value(context, 8)),
          Expanded(
            child: Text(
              'No financial accounts found. Please add accounts first.',
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 13), color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }
}

