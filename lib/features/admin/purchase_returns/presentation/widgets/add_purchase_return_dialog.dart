import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:GoSystem/features/admin/bank_account/model/bank_account_model.dart';
import 'package:GoSystem/features/admin/purchase_returns/cubit/purchase_return_cubit.dart';

class AddPurchaseReturnDialog extends StatefulWidget {
  const AddPurchaseReturnDialog({super.key});

  @override
  State<AddPurchaseReturnDialog> createState() =>
      _AddPurchaseReturnDialogState();
}

class _AddPurchaseReturnDialogState extends State<AddPurchaseReturnDialog>
    with SingleTickerProviderStateMixin {
  // Step 1
  final _refCtrl = TextEditingController();

  // Step 2 - items with return quantities
  Map<String, dynamic>? _purchase;
  List<_ReturnItemEntry> _items = [];

  // Step 3
  final _noteCtrl = TextEditingController();
  final _refundMethodCtrl = TextEditingController(text: 'original_method');
  BankAccountModel? _selectedAccount;

  int _step = 1; // 1=search, 2=items, 3=confirm

  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _animCtrl.forward();
    context.read<BankAccountCubit>().getBankAccounts();
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _noteCtrl.dispose();
    _refundMethodCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _search() {
    if (_refCtrl.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter purchase reference');
      return;
    }
    context.read<PurchaseReturnCubit>().searchPurchaseByReference(
      _refCtrl.text.trim(),
    );
  }

  void _submit() {
    final selectedItems = _items.where((i) => i.returnQty > 0).toList();
    if (selectedItems.isEmpty) {
      CustomSnackbar.showWarning(context, 'Select at least one item to return');
      return;
    }
    if (_selectedAccount == null) {
      CustomSnackbar.showWarning(context, 'Please select a refund account');
      return;
    }

    final items = selectedItems
        .map(
          (i) => {
            'product_id': i.productId,
            'original_quantity': i.originalQty,
            'returned_quantity': i.returnQty,
            'price': i.price,
            'subtotal': i.price * i.returnQty,
          },
        )
        .toList();

    context.read<PurchaseReturnCubit>().createReturn(
      purchaseId: _purchase!['_id'] ?? '',
      note: _noteCtrl.text.trim(),
      refundMethod: _refundMethodCtrl.text.trim(),
      refundAccountId: _selectedAccount!.id,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<PurchaseReturnCubit, PurchaseReturnState>(
          listener: (context, state) {
            if (state is SearchPurchaseSuccess) {
              _purchase = state.purchase;
              final rawItems = state.purchase['items'] as List? ?? [];
              _items = rawItems.map((item) {
                final prod = item['product_id'] is Map
                    ? item['product_id'] as Map
                    : {};
                return _ReturnItemEntry(
                  productId:
                      prod['_id']?.toString() ??
                      item['product_id']?.toString() ??
                      '',
                  productName: prod['name']?.toString() ?? 'Unknown',
                  originalQty: (item['quantity'] as num?)?.toInt() ?? 0,
                  price: (item['unit_cost'] as num?)?.toDouble() ?? 0,
                );
              }).toList();
              setState(() => _step = 2);
            } else if (state is SearchPurchaseError) {
              CustomSnackbar.showError(context, state.error);
            } else if (state is CreateReturnSuccess) {
              Navigator.pop(context);
              CustomSnackbar.showSuccess(context, state.message);
            } else if (state is CreateReturnError) {
              CustomSnackbar.showError(context, state.error);
            }
          },
          builder: (context, state) {
            return Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(step: _step),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(
                        ResponsiveUI.padding(context, 24),
                      ),
                      child: _step == 1
                          ? _Step1(
                              controller: _refCtrl,
                              isLoading: state is SearchPurchaseLoading,
                              onSearch: _search,
                            )
                          : _step == 2
                          ? _Step2(
                              purchase: _purchase!,
                              items: _items,
                              onChanged: () => setState(() {}),
                              onNext: () => setState(() => _step = 3),
                            )
                          : _Step3(
                              items: _items
                                  .where((i) => i.returnQty > 0)
                                  .toList(),
                              noteCtrl: _noteCtrl,
                              refundMethodCtrl: _refundMethodCtrl,
                              selectedAccount: _selectedAccount,
                              onAccountChanged: (a) =>
                                  setState(() => _selectedAccount = a),
                            ),
                    ),
                  ),
                  _Footer(
                    step: _step,
                    isLoading: state is CreateReturnLoading,
                    onBack: _step > 1 ? () => setState(() => _step -= 1) : null,
                    onNext: _step == 1
                        ? _search
                        : _step == 2
                        ? () => setState(() => _step = 3)
                        : _submit,
                    onCancel: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int step;
  const _Header({required this.step});

  @override
  Widget build(BuildContext context) {
    final titles = ['Search Purchase', 'Select Items', 'Confirm Return'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 24),
        vertical: ResponsiveUI.padding(context, 20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
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
              Icons.assignment_return_rounded,
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
                  'Add Purchase Return',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUI.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Step $step/3 · ${titles[step - 1]}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveUI.fontSize(context, 12),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 20),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: ResponsiveUI.iconSize(context, 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Search ───────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;

  const _Step1({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The field labels marked with * are required input fields.',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            color: AppColors.shadowGray,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 20)),
        _FieldLabel('Purchase Reference *'),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        TextField(
          controller: controller,
          enabled: !isLoading,
          onSubmitted: (_) => onSearch(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. 01158665',
            hintStyle: TextStyle(
              color: AppColors.darkGray.withValues(alpha: 0.4),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 14),
              vertical: ResponsiveUI.padding(context, 14),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 10),
              ),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: ResponsiveUI.value(context, 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Items ────────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final Map<String, dynamic> purchase;
  final List<_ReturnItemEntry> items;
  final VoidCallback onChanged;
  final VoidCallback onNext;

  const _Step2({
    required this.purchase,
    required this.items,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final reference = purchase['reference']?.toString() ?? '';
    final grandTotal =
        (purchase['grand_total'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final supplier =
        (purchase['supplier_id'] is Map
                ? purchase['supplier_id']['name']
                : null)
            ?.toString() ??
        '';
    final warehouse =
        (purchase['warehouse_id'] is Map
                ? purchase['warehouse_id']['name']
                : null)
            ?.toString() ??
        '';
    final rawDate = purchase['date']?.toString() ?? '';
    String formattedDate = rawDate;
    try {
      final dt = DateTime.parse(rawDate);
      formattedDate =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Purchase info card (POS style) ──────────────────────────────
        _PurchaseInfoCard(
          reference: reference,
          grandTotal: grandTotal,
          supplier: supplier,
          warehouse: warehouse,
          date: formattedDate,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),

        // ── Section label ────────────────────────────────────────────────
        _SectionLabel(label: 'Select Items to Return'),
        SizedBox(height: ResponsiveUI.spacing(context, 10)),

        // ── Items table (POS style) ──────────────────────────────────────
        _PurchaseItemsTable(items: items, onChanged: onChanged),
      ],
    );
  }
}

// ─── Purchase Info Card (inspired by POS _SaleInfoCard) ──────────────────────

class _PurchaseInfoCard extends StatelessWidget {
  final String reference;
  final String grandTotal;
  final String supplier;
  final String warehouse;
  final String date;

  const _PurchaseInfoCard({
    required this.reference,
    required this.grandTotal,
    required this.supplier,
    required this.warehouse,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient header with reference + total
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.darkBlue],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: ResponsiveUI.iconSize(context, 20),
                ),
                SizedBox(width: ResponsiveUI.value(context, 8)),
                Expanded(
                  child: Text(
                    '#$reference',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 10),
                    vertical: ResponsiveUI.padding(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 20),
                    ),
                  ),
                  child: Text(
                    '$grandTotal EGP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: ResponsiveUI.fontSize(context, 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Detail rows
          Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              children: [
                if (date.isNotEmpty)
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: date,
                  ),
                if (supplier.isNotEmpty) ...[
                  _Divider(),
                  _InfoTile(
                    icon: Icons.local_shipping_outlined,
                    label: 'Supplier',
                    value: supplier,
                  ),
                ],
                if (warehouse.isNotEmpty) ...[
                  _Divider(),
                  _InfoTile(
                    icon: Icons.warehouse_outlined,
                    label: 'Warehouse',
                    value: warehouse,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 6)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 18),
            color: AppColors.primaryBlue,
          ),
          SizedBox(width: ResponsiveUI.value(context, 10)),
          SizedBox(
            width: ResponsiveUI.value(context, 72),
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  _Divider();
  @override
  Widget build(BuildContext context) => Divider(
    height: ResponsiveUI.value(context, 1),
    thickness: ResponsiveUI.value(context, 1),
    color: Color(0xFFF0F0F0),
  );
}

// ─── Section Label (POS style) ────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ResponsiveUI.value(context, 4),
          height: ResponsiveUI.value(context, 18),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 2),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.value(context, 8)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 15),
            fontWeight: FontWeight.w700,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }
}

// ─── Purchase Items Table (POS style) ─────────────────────────────────────────

class _PurchaseItemsTable extends StatelessWidget {
  final List<_ReturnItemEntry> items;
  final VoidCallback onChanged;
  const _PurchaseItemsTable({required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 14),
              vertical: ResponsiveUI.padding(context, 10),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveUI.value(context, 50),
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveUI.value(context, 90),
                  child: Text(
                    'Return Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table rows
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
              child: Center(
                child: Text(
                  'No items',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: ResponsiveUI.fontSize(context, 14),
                  ),
                ),
              ),
            )
          else
            ...items.asMap().entries.map(
              (e) => _ItemRow(
                index: e.key,
                item: e.value,
                isLast: e.key == items.length - 1,
                onChanged: onChanged,
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final int index;
  final _ReturnItemEntry item;
  final bool isLast;
  final VoidCallback onChanged;
  const _ItemRow({
    required this.index,
    required this.item,
    required this.isLast,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;
    return Container(
      decoration: BoxDecoration(
        color: item.returnQty > 0
            ? AppColors.primaryBlue.withValues(alpha: 0.06)
            : isEven
            ? AppColors.white
            : Color(0xFFF5F5F5),
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Color(0xFFF0F0F0),
                  width: ResponsiveUI.value(context, 1),
                ),
              ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 14),
        vertical: ResponsiveUI.padding(context, 10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  '${item.price.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 11),
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: ResponsiveUI.value(context, 50),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 8),
                  vertical: ResponsiveUI.padding(context, 3),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 20),
                  ),
                ),
                child: Text(
                  '${item.originalQty}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Quantity stepper
          SizedBox(
            width: ResponsiveUI.value(context, 90),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepBtn(
                  icon: Icons.remove,
                  active: item.returnQty > 0,
                  onTap: item.returnQty > 0
                      ? () {
                          item.returnQty--;
                          onChanged();
                        }
                      : null,
                ),
                Container(
                  width: ResponsiveUI.value(context, 32),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.returnQty}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      color: item.returnQty > 0
                          ? AppColors.primaryBlue
                          : AppColors.darkGray,
                    ),
                  ),
                ),
                _StepBtn(
                  icon: Icons.add,
                  active: item.returnQty < item.originalQty,
                  onTap: item.returnQty < item.originalQty
                      ? () {
                          item.returnQty++;
                          onChanged();
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: ResponsiveUI.value(context, 28),
      height: ResponsiveUI.value(context, 28),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryBlue.withValues(alpha: 0.12)
            : const Color(0xFFF0F0F0),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: ResponsiveUI.iconSize(context, 16),
        color: active ? AppColors.primaryBlue : const Color(0xFFCCCCCC),
      ),
    ),
  );
}

// ─── Step 3: Confirm ──────────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final List<_ReturnItemEntry> items;
  final TextEditingController noteCtrl;
  final TextEditingController refundMethodCtrl;
  final BankAccountModel? selectedAccount;
  final ValueChanged<BankAccountModel?> onAccountChanged;

  const _Step3({
    required this.items,
    required this.noteCtrl,
    required this.refundMethodCtrl,
    required this.selectedAccount,
    required this.onAccountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0.0, (s, i) => s + i.price * i.returnQty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 14)),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 10),
            ),
          ),
          child: Column(
            children: [
              ...items.map(
                (i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveUI.padding(context, 6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          i.productName,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 13),
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      Text(
                        'x${i.returnQty}  •  ${(i.price * i.returnQty).toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: ResponsiveUI.value(context, 1),
                color: Color(0xFFF0F0F0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Refund',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGray,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      fontWeight: FontWeight.w800,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),

        // Refund method
        _FieldLabel('Refund Method'),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        _InputField(controller: refundMethodCtrl),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),

        // Refund account
        _FieldLabel('Refund Account *'),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        BlocBuilder<BankAccountCubit, BankAccountState>(
          builder: (context, state) {
            final accounts = state is GetBankAccountsSuccess
                ? state.accounts
                : <BankAccountModel>[];
            return _AccountDropdown(
              value: selectedAccount,
              accounts: accounts,
              onChanged: onAccountChanged,
            );
          },
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),

        // Note
        _FieldLabel('Note'),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        _InputField(controller: noteCtrl, maxLines: 3),
      ],
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final int step;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback onCancel;

  const _Footer({
    required this.step,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
          bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            OutlinedButton.icon(
              onPressed: isLoading ? null : onBack,
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: ResponsiveUI.iconSize(context, 14),
              ),
              label: Text('Back'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 14),
                  horizontal: ResponsiveUI.padding(context, 16),
                ),
                side: BorderSide(color: AppColors.shadowGray[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 8)),
          ] else ...[
            OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 14),
                  horizontal: ResponsiveUI.padding(context, 16),
                ),
                side: BorderSide(color: AppColors.shadowGray[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.shadowGray[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 8)),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onNext,
              icon: isLoading
                  ? SizedBox(
                      width: ResponsiveUI.value(context, 16),
                      height: ResponsiveUI.value(context, 16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      step == 3
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward_ios,
                      size: ResponsiveUI.iconSize(context, 16),
                    ),
              label: Text(
                step == 1
                    ? 'Search'
                    : step == 2
                    ? 'Next'
                    : 'Confirm Return',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _ReturnItemEntry {
  final String productId;
  final String productName;
  final int originalQty;
  final double price;
  int returnQty = 0;

  _ReturnItemEntry({
    required this.productId,
    required this.productName,
    required this.originalQty,
    required this.price,
  });
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
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
  final int maxLines;
  const _InputField({required this.controller, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    style: TextStyle(
      fontSize: ResponsiveUI.fontSize(context, 14),
      color: AppColors.darkGray,
    ),
    decoration: InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 12),
        vertical: ResponsiveUI.padding(context, 12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 8),
        ),
        borderSide: BorderSide(color: AppColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 8),
        ),
        borderSide: BorderSide(color: AppColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 8),
        ),
        borderSide: BorderSide(
          color: AppColors.primaryBlue,
          width: ResponsiveUI.value(context, 1.5),
        ),
      ),
    ),
  );
}

class _AccountDropdown extends StatelessWidget {
  final BankAccountModel? value;
  final List<BankAccountModel> accounts;
  final ValueChanged<BankAccountModel?> onChanged;
  const _AccountDropdown({
    required this.value,
    required this.accounts,
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
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 8),
      ),
      color: Colors.white,
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<BankAccountModel>(
        value: value,
        hint: Text(
          'Select Account',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray.withValues(alpha: 0.5),
          ),
        ),
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.darkGray,
        ),
        items: accounts
            .map(
              (a) => DropdownMenuItem(
                value: a,
                child: Text(
                  a.name,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

