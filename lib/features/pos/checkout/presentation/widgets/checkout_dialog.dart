import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_textfield/build_text_field.dart';
import 'package:GoSystem/features/pos/checkout/model/reciept_data.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/pos/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:GoSystem/features/pos/checkout/model/checkout_models.dart';
import 'package:GoSystem/features/pos/shift/cubit/pos_shift_cubit.dart';
import 'receipt_dialog.dart';

// --------------------------------------------------------------
//  HELPER WIDGET: buildDropdownField (كما هو)
// --------------------------------------------------------------
Widget buildDropdownField<T>(
  BuildContext context, {
  required T? value,
  required List<T> items,
  required String label,
  IconData? icon,
  required String hint,
  required void Function(T?) onChanged,
  required String Function(T) itemLabel,
  String? Function(T?)? validator,
}) {
  final fontSizeLabel = ResponsiveUI.fontSize(context, 14);
  final spacing8 = ResponsiveUI.spacing(context, 8);
  final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
  final value3 = ResponsiveUI.value(context, 3);
  final iconSize22 = ResponsiveUI.iconSize(context, 22);
  final padding16 = ResponsiveUI.padding(context, 16);
  final padding14 = ResponsiveUI.padding(context, 14);
  final fontSizeHint = ResponsiveUI.fontSize(context, 15);
  final value15 = ResponsiveUI.value(context, 1.5);
  final value2 = ResponsiveUI.value(context, 2);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: fontSizeLabel,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      SizedBox(height: spacing8),
      DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.shadowGray[400],
            fontSize: fontSizeHint,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primaryBlue, size: iconSize22)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(
              color: AppColors.shadowGray[300]!,
              width: value3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(
              color: AppColors.shadowGray[300]!,
              width: value3,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: value2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(color: AppColors.red, width: value15),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius12),
            borderSide: BorderSide(color: AppColors.red, width: value2),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: padding16,
            vertical: padding14,
          ),
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: TextStyle(
                fontSize: fontSizeHint,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primaryBlue,
          size: iconSize22,
        ),
        style: TextStyle(
          fontSize: fontSizeHint,
          fontFamily: 'Rubik',
          color: Colors.grey[800],
        ),
        dropdownColor: AppColors.white,
        isExpanded: true,
      ),
    ],
  );
}

// --------------------------------------------------------------
//  MAIN DIALOG WIDGET
// --------------------------------------------------------------

class POSCheckoutDialog extends StatefulWidget {
  final double totalAmount; // This is the Subtotal
  final List<CartItem> cartItems;
  final PaymentMethod? selectedPaymentMethod;
  final String customerId;

  const POSCheckoutDialog({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    this.selectedPaymentMethod,
    required this.customerId,
  });

  @override
  State<POSCheckoutDialog> createState() => _POSCheckoutDialogState();
}

class _POSCheckoutDialogState extends State<POSCheckoutDialog> {
  final _formKey = GlobalKey<FormState>();

  // ---------- Controllers ----------
  final _totalPayingCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _giftCardCtrl = TextEditingController();
  final _saleNoteCtrl = TextEditingController();

  // ---------- Runtime values ----------
  double _subTotal = 0.0;
  double _grandTotal = 0.0;
  double _totalPaying = 0.0;
  double _change = 0.0;
  double _remainingDue = 0.0;

  String _selectedCardType = 'Visa';
  final List<String> _cardTypes = ['Visa', 'MasterCard'];

  List<Tax> _taxes = [];
  late Tax? _selectedTax;

  List<DiscountModel> _discounts = [];
  late DiscountModel? _selectedDiscount;

  List<BankAccount> _accounts = [];
  BankAccount? _selectedAccount;

  late PaymentMethod? _selectedPaymentMethod;
  List<PaymentMethod> _paymentMethods = [];

  double currentTaxAmount = 0;
  double currentDiscountAmount = 0;
  late PosCubit posCubit;
  bool _autoSyncAmountField = true;
  bool _isProgrammaticAmountUpdate = false;

  String? _normalizeSelectionId(String? id) {
    if (id == null || id.isEmpty || id == 'null') return null;
    return id;
  }

  @override
  void initState() {
    super.initState();
    posCubit = context.read<PosCubit>();
    _subTotal = widget.totalAmount;

    _taxes = posCubit.taxes;
    _discounts = posCubit.discounts;
    _accounts = posCubit.accounts;
    _paymentMethods = posCubit.paymentMethods;

    _selectedTax =
        posCubit.selectedTax ?? (_taxes.isNotEmpty ? _taxes.first : null);
    _selectedDiscount =
        posCubit.selectedDiscount ??
        (_discounts.isNotEmpty ? _discounts.first : null);
    _selectedAccount =
        posCubit.selectedAccount ??
        (_accounts.isNotEmpty ? _accounts.first : null);
    _selectedPaymentMethod = 
        widget.selectedPaymentMethod ?? posCubit.selectedPaymentMethod;

    _calculateValues();
    _totalPayingCtrl.addListener(_onAmountFieldChanged);

    // Initialize the payment amount with the grand total after calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formatted = _grandTotal.toStringAsFixed(2);
      _isProgrammaticAmountUpdate = true;
      _totalPayingCtrl.text = formatted;
    });
  }

  // ─── Core Calculation Logic ───
  void _calculateValues() {
    setState(() {
      _totalPaying = double.tryParse(_totalPayingCtrl.text) ?? 0.0;

      // 1. Discount
      double discountVal = 0.0;
      if (_selectedDiscount != null) {
        if (_selectedDiscount!.type == 'percentage') {
          discountVal = _subTotal * _selectedDiscount!.amount;
        } else {
          discountVal = _selectedDiscount!.amount;
        }
      }
      currentDiscountAmount = discountVal;

      // 2. Tax Base
      double taxableAmount = _subTotal - currentDiscountAmount;
      if (taxableAmount < 0) taxableAmount = 0;

      // 3. Tax
      double taxVal = 0.0;
      if (_selectedTax != null) {
        if (_selectedTax!.type == 'percentage') {
          taxVal = taxableAmount * _selectedTax!.amount;
        } else {
          taxVal = _selectedTax!.amount;
        }
      }
      currentTaxAmount = taxVal;

      // 4. Grand Total
      _grandTotal = taxableAmount + currentTaxAmount;

      if (_autoSyncAmountField) {
        final formatted = _grandTotal.toStringAsFixed(2);
        if (_totalPayingCtrl.text != formatted) {
          _isProgrammaticAmountUpdate = true;
          _totalPayingCtrl.text = formatted;
        }
        _totalPaying = _grandTotal;
      }

      if (_totalPaying > _grandTotal) {
        _totalPaying = _grandTotal;
        final formatted = _grandTotal.toStringAsFixed(2);
        if (_totalPayingCtrl.text != formatted) {
          _isProgrammaticAmountUpdate = true;
          _totalPayingCtrl.text = formatted;
        }
      }

      // 5. Change & Due Calculation
      if (_totalPaying >= _grandTotal) {
        _change = _totalPaying - _grandTotal;
        _remainingDue = 0.0;
      } else {
        _change = 0.0;
        _remainingDue = _grandTotal - _totalPaying;
      }
      _autoSyncAmountField = false;
    });
  }

  void _onAmountFieldChanged() {
    if (_isProgrammaticAmountUpdate) {
      _isProgrammaticAmountUpdate = false;
      return;
    }
    _autoSyncAmountField = false;
    _calculateValues();
  }

  @override
  void dispose() {
    _totalPayingCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _giftCardCtrl.dispose();
    _saleNoteCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  //  UI BUILD
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: ResponsiveUI.screenHeight(context) * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _paymentMethodDropdown(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _dynamicFields(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _taxDropdown(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _discountDropdown(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _accountDropdown(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _notesSection(),
                    ],
                  ),
                ),
              ),
            ),
            _summaryPanel(),
            _footer(), // الأزرار هنا (Hold, Complete, Cancel)
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    padding: EdgeInsets.all(ResponsiveUI.padding(context, 15)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.darkBlue],
      ),
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.point_of_sale,
          color: AppColors.white,
          size: ResponsiveUI.iconSize(context, 28),
        ),
        SizedBox(width: ResponsiveUI.value(context, 15)),
        Expanded(
          child: Text(
            'Complete payment',
            style: TextStyle(
              color: AppColors.white,
              fontSize: ResponsiveUI.fontSize(context, 20),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );

  Widget _paymentMethodDropdown() => buildDropdownField<PaymentMethod>(
    context,
    value: _selectedPaymentMethod,
    items: _paymentMethods,
    label: 'Payment Method',
    hint: 'Select Method',
    icon: Icons.payment,
    onChanged: (v) {
      if (v != null) setState(() => _selectedPaymentMethod = v);
    },
    itemLabel: (m) => m.name,
  );

  Widget _summaryPanel() => Container(
    margin: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 20)),
    padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
    decoration: BoxDecoration(
      color: AppColors.shadowGray[50],
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 16),
      ),
      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        _row('Grand Total', _grandTotal, AppColors.darkGray, bold: true),
        Divider(),
        _row('Subtotal', _subTotal, AppColors.categoryPurple),
        SizedBox(height: ResponsiveUI.value(context, 5)),
        _row('Tax (+)', currentTaxAmount, AppColors.warningOrange),
        SizedBox(height: ResponsiveUI.value(context, 5)),
        _row('Discount (-)', currentDiscountAmount, AppColors.successGreen),
        Divider(),
        _row('Paid Amount', _totalPaying, Colors.black),
        _row('Change', _change, AppColors.clearPink),
        SizedBox(height: ResponsiveUI.value(context, 5)),
        _row(
          'Remaining Due',
          _remainingDue,
          _remainingDue > 0 ? AppColors.red : Colors.green,
          bold: true,
        ),
      ],
    ),
  );

  Widget _row(String label, double amount, Color color, {bool bold = false}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUI.padding(context, 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: bold ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );

  // --------------------------------------------------------------
  //  FOOTER with HOLD & COMPLETE
  // --------------------------------------------------------------
  Widget _footer() => Container(
    padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
    child: Row(
      children: [
        // زر الإلغاء (صغير)
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 14),
              ),
            ),
            child: Text('Cancel', style: TextStyle(color: AppColors.darkGray)),
          ),
        ),
        SizedBox(width: ResponsiveUI.value(context, 8)),

        // زر الإيقاف المؤقت (Hold)
        Expanded(
          flex: 1,
          child: ElevatedButton.icon(
            onPressed: _hold, // استدعاء دالة الإيقاف
            icon: Icon(
              Icons.pause_circle_outline,
              size: ResponsiveUI.iconSize(context, 20),
            ),
            label: Text('Hold', overflow: TextOverflow.ellipsis),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 14),
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.value(context, 8)),

        // زر إتمام البيع (Complete / Due)
        Expanded(
          flex: 2,
          child: BlocBuilder<CheckoutCubit, CheckoutState>(
            builder: (context, state) {
              final isLoading = state is CheckoutLoading;
              return ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? SizedBox(
                        width: ResponsiveUI.iconSize(context, 18),
                        height: ResponsiveUI.iconSize(context, 18),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(Icons.check_circle_outline),
                label: Text(
                  _remainingDue > 0 ? 'Pay & Due' : 'Complete',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _remainingDue > 0
                      ? Colors.redAccent
                      : AppColors.mediumBlue700,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor:
                      (_remainingDue > 0
                              ? Colors.redAccent
                              : AppColors.mediumBlue700)
                          .withValues(alpha: 0.6),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUI.padding(context, 14),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _notesSection() => buildTextField(
    context,
    controller: _saleNoteCtrl,
    label: 'Sale Note',
    icon: Icons.note_alt_outlined,
    hint: 'Type a sale note',
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );

  Widget _dynamicFields() {
    if (_selectedPaymentMethod == null) return SizedBox.shrink();
    final method = _selectedPaymentMethod!.name.toLowerCase();
    if (method.contains('card') && !method.contains('gift')) {
      return Column(
        children: [
          buildTextField(
            context,
            controller: _cardNumberCtrl,
            label: 'Card Number',
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            hint: 'Enter Card Number',
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          _cardTypeDropdown(),
        ],
      );
    }
    return buildTextField(
      context,
      controller: _totalPayingCtrl,
      label: 'Amount Received',
      icon: Icons.attach_money,
      hint: _grandTotal.toStringAsFixed(2),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _cardTypeDropdown() => buildDropdownField<String>(
    context,
    value: _selectedCardType,
    items: _cardTypes,
    label: 'Card Type',
    hint: 'Select Type',
    icon: Icons.credit_card_outlined,
    onChanged: (v) {
      if (v != null) setState(() => _selectedCardType = v);
    },
    itemLabel: (item) => item,
  );

  Widget _taxDropdown() => buildDropdownField<Tax>(
    context,
    value: _selectedTax,
    items: _taxes,
    label: 'Tax',
    hint: 'Select Tax',
    icon: Icons.percent,
    onChanged: (v) {
      if (v != null) {
        _selectedTax = v;
        _autoSyncAmountField = true;
        _calculateValues();
      }
    },
    itemLabel: (t) =>
        '${t.name} (${t.type == 'fixed' ? t.amount : '${t.amount * 100}%'})',
  );

  Widget _discountDropdown() => buildDropdownField<DiscountModel>(
    context,
    value: _selectedDiscount,
    items: _discounts,
    label: 'Discount',
    hint: 'Select Discount',
    icon: Icons.discount_outlined,
    onChanged: (v) {
      if (v != null) {
        _selectedDiscount = v;
        _autoSyncAmountField = true;
        _calculateValues();
      }
    },
    itemLabel: (d) =>
        '${d.name} (${d.type == 'fixed' ? d.amount : '${d.amount * 100}%'})',
  );

  Widget _accountDropdown() => buildDropdownField<BankAccount>(
    context,
    value: _selectedAccount,
    items: _accounts,
    label: 'Payment Account',
    hint: 'Select Account',
    icon: Icons.account_balance_outlined,
    onChanged: (v) => setState(() => _selectedAccount = v),
    itemLabel: (a) => a.name,
  );

  // --------------------------------------------------------------
  //  HOLD LOGIC (Pause Sale)
  // --------------------------------------------------------------
  void _hold() async {
    final posCubit = context.read<PosCubit>();
    final checkOutCubit = context.read<CheckoutCubit>();
    final shiftCubit = context.read<PosShiftCubit>();

    if (widget.customerId.isEmpty) {
      CustomSnackbar.showError(context, "Please select a customer first");
      return;
    }

    final success = await checkOutCubit.createSale(
      totalAmount: _grandTotal,
      paidAmount: 0,
      note: _saleNoteCtrl.text.isEmpty ? "Sale on Hold" : _saleNoteCtrl.text,
      isPending: true,
      customerId: widget.customerId,
      warehouseId: posCubit.selectedWarhouse?.id,
      paymentMethodId: _selectedPaymentMethod?.id,
      shiftId: shiftCubit.currentShift?.id,
      cashierId: shiftCubit.selectedCashier?.id,
      taxAmount: currentTaxAmount,
      discountAmount: currentDiscountAmount,
      taxId: _normalizeSelectionId(_selectedTax?.id),
      discountId: _normalizeSelectionId(_selectedDiscount?.id),
    );

    if (success && mounted) {
      Navigator.pop(context);
      CustomSnackbar.showSuccess(context, "Sale put on hold successfully");
    }
  }

  // --------------------------------------------------------------
  //  SUBMIT LOGIC (Complete or Due Sale)
  // --------------------------------------------------------------
  void _submit() async {
    final posCubit = context.read<PosCubit>();
    final checkOutCubit = context.read<CheckoutCubit>();
    final shiftCubit = context.read<PosShiftCubit>();

    double actualPaidToSend = _totalPaying >= _grandTotal
        ? _grandTotal
        : _totalPaying;

    final success = await checkOutCubit.createSale(
      totalAmount: _grandTotal,
      paidAmount: actualPaidToSend,
      note: _saleNoteCtrl.text.isEmpty ? null : _saleNoteCtrl.text,
      isPending: false,
      customerId: widget.customerId,
      warehouseId: posCubit.selectedWarhouse?.id,
      accountId: _selectedAccount?.id,
      paymentMethodId: _selectedPaymentMethod?.id,
      shiftId: shiftCubit.currentShift?.id,
      cashierId: shiftCubit.selectedCashier?.id,
      taxAmount: currentTaxAmount,
      discountAmount: currentDiscountAmount,
      taxId: _normalizeSelectionId(_selectedTax?.id),
      discountId: _normalizeSelectionId(_selectedDiscount?.id),
    );

    if (success && mounted) {
      Navigator.pop(context);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return POSReceiptDialog(
            recieptData: RecieptData(
              cartItems: widget.cartItems,
              totalAmount: _subTotal,
              taxAmount: currentTaxAmount,
              selectedTax: _selectedTax,
              discountAmount: currentDiscountAmount,
              selectedDiscount: _selectedDiscount,
              paidAmount: _totalPaying,
              change: _change,
              reference: checkOutCubit.reference ?? 'N/A',
            ),
          );
        },
      );
    }
  }
}
