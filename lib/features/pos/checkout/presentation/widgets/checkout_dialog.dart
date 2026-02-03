import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/features/POS/checkout/model/reciept_data.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import 'package:systego/features/admin/discount/model/discount_model.dart';
import '../../../../../core/widgets/custom_drop_down_menu.dart';
import '../../cubit/checkout_cubit/checkout_cubit.dart';
import '../../model/checkout_models.dart';
import 'receipt_dialog.dart';

class POSCheckoutDialog extends StatefulWidget {
  final double totalAmount; // This is the Subtotal
  final List<CartItem> cartItems;
  final PaymentMethod selectedPaymentMethod;

  const POSCheckoutDialog({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    required this.selectedPaymentMethod,
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
  double _grandTotal = 0.0; // الإجمالي النهائي المطلوب دفعه
  double _totalPaying = 0.0; // المبلغ الذي أدخله المستخدم
  double _change = 0.0; // الباقي
  double _remainingDue = 0.0; // المبلغ المتبقي (للعرض)

  String _selectedCardType = 'Visa';
  final List<String> _cardTypes = ['Visa', 'MasterCard'];

  List<Tax> _taxes = [];
  late Tax? _selectedTax;

  List<DiscountModel> _discounts = [];
  late DiscountModel? _selectedDiscount;

  double currentTaxAmount = 0;
  double currentDiscountAmount = 0;
  late PosCubit posCubit;

  @override
  void initState() {
    super.initState();
    posCubit = context.read<PosCubit>();
    _subTotal = widget.totalAmount;

    // 1. Setup Lists
    _taxes = posCubit.taxes;
    _discounts = posCubit.discounts;

    // 2. Setup Defaults
    _selectedTax =
        posCubit.selectedTax ?? (_taxes.isNotEmpty ? _taxes.first : null);
    _selectedDiscount =
        posCubit.selectedDiscount ??
        (_discounts.isNotEmpty ? _discounts.first : null);

    // 3. Initial Calculation
    _calculateValues();

    // 4. Listeners
    _totalPayingCtrl.addListener(_calculateValues);
  }

  // ─── Core Calculation Logic (المنطق الحسابي الصحيح) ───
  void _calculateValues() {
    setState(() {
      // 1. Get Payment Input
      _totalPaying = double.tryParse(_totalPayingCtrl.text) ?? 0.0;

      // 2. Calculate Discount First (Usually applied on Subtotal)
      double discountVal = 0.0;
      if (_selectedDiscount != null) {
        if (_selectedDiscount!.type == 'percentage') {
          discountVal = _subTotal * _selectedDiscount!.amount;
        } else {
          discountVal = _selectedDiscount!.amount;
        }
      }
      currentDiscountAmount = discountVal;

      // 3. Calculate Tax Base (Subtotal - Discount)
      // الضرائب عادة تحسب على المبلغ بعد الخصم
      double taxableAmount = _subTotal - currentDiscountAmount;
      if (taxableAmount < 0) taxableAmount = 0;

      // 4. Calculate Tax
      double taxVal = 0.0;
      if (_selectedTax != null) {
        if (_selectedTax!.type == 'percentage') {
          taxVal = taxableAmount * _selectedTax!.amount;
        } else {
          taxVal = _selectedTax!.amount;
        }
      }
      currentTaxAmount = taxVal;

      // 5. Calculate Grand Total
      _grandTotal = taxableAmount + currentTaxAmount;

      // 6. Calculate Change & Due
      if (_totalPaying >= _grandTotal) {
        _change = _totalPaying - _grandTotal;
        _remainingDue = 0.0;
      } else {
        _change = 0.0;
        _remainingDue = _grandTotal - _totalPaying;
      }
    });
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
                      _paymentMethodDisplay(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _dynamicFields(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _notesSection(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _taxDropdown(),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _discountDropdown(),
                    ],
                  ),
                ),
              ),
            ),
            _summaryPanel(),
            _footer(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  //  WIDGETS
  // --------------------------------------------------------------
  Widget _header() => Container(
    padding: EdgeInsets.all(ResponsiveUI.padding(context, 15)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
      ),
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
    ),
    child: Row(
      children: [
        Icon(Icons.point_of_sale, color: AppColors.white, size: 28),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            'Complete payment',
            style: TextStyle(color: AppColors.white, fontSize: 20),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );

  Widget _paymentMethodDisplay() => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.lightBlueBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.payment, color: AppColors.primaryBlue),
        SizedBox(width: 12),
        Text(
          widget.selectedPaymentMethod.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget _summaryPanel() => Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.shadowGray[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        _row('Grand Total', _grandTotal, AppColors.darkGray, bold: true),
        Divider(),
        _row('Subtotal', _subTotal, AppColors.categoryPurple),
        SizedBox(height: 5),
        _row('Tax (+)', currentTaxAmount, AppColors.warningOrange),
        SizedBox(height: 5),
        _row('Discount (-)', currentDiscountAmount, AppColors.successGreen),
        Divider(),
        _row('Paid Amount', _totalPaying, Colors.black),
        _row('Change', _change, AppColors.clearPink),
        SizedBox(height: 5),
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
        padding: const EdgeInsets.symmetric(vertical: 2),
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

  Widget _footer() => Container(
    padding: EdgeInsets.all(20),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Cancel', style: TextStyle(color: AppColors.darkGray)),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _submit,
            icon: Icon(Icons.check_circle_outline),
            label: Text('Complete Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mediumBlue700,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
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
    keyboardType: TextInputType.text,
  );

  Widget _dynamicFields() {
    final method = widget.selectedPaymentMethod.name.toLowerCase();
    if (method.contains('card')) {
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
          SizedBox(height: 12),
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

  // ---- DROPDOWN REPLACEMENTS START ----

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
      setState(() {
        _selectedTax = v;
        _calculateValues();
      });
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
      setState(() {
        _selectedDiscount = v;
        _calculateValues();
      });
    },
    itemLabel: (d) =>
        '${d.name} (${d.type == 'fixed' ? d.amount : '${d.amount * 100}%'})',
  );

  // ---- DROPDOWN REPLACEMENTS END ----

  // --------------------------------------------------------------
  //  SUBMIT LOGIC
  // --------------------------------------------------------------
  void _submit() async {
    // 1. Basic Validation
    // إذا كان الكاش، يمكن قبول دفع جزئي إذا كان النظام يسمح بالديون (Due)
    // إذا لم يسمح، يمكن إلغاء التعليق التالي:
    /*
    if (_remainingDue > 0 && !widget.selectedPaymentMethod.name.toLowerCase().contains('cash')) {
      CustomSnackbar.showError(context, 'Please pay full amount for non-cash methods');
      return;
    }
    */

    final posCubit = context.read<PosCubit>();
    final checkOutCubit = context.read<CheckoutCubit>();

    // تحديد المبلغ المدفوع فعلياً (لا يمكن أن يزيد عن الإجمالي في الدفع)
    // لكن في الكاش يمكن أن يدفع أكثر ونرجع الباقي.
    // للباك إند: نرسل ما تم تحصيله بحد أقصى قيمة الفاتورة.
    double actualPaidToSend = _totalPaying >= _grandTotal
        ? _grandTotal
        : _totalPaying;

    // Call Create Sale
    final success = await checkOutCubit.createSale(
      // posCubit: posCubit,
      totalAmount: _grandTotal, // الإجمالي النهائي
      paidAmount: actualPaidToSend, // المبلغ المدفوع (سيتم حساب Due داخلياً)
      note: _saleNoteCtrl.text.isEmpty ? null : _saleNoteCtrl.text,
      isPending: false, // تعتبر عملية بيع وليست مسودة (Draft)
    );

    if (success && mounted) {
      Navigator.pop(context); // Close the checkout dialog first

      // Show Receipt
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return POSReceiptDialog(
            recieptData: RecieptData(
              cartItems: [],
              totalAmount: _subTotal,
              taxAmount: currentTaxAmount,
              selectedTax: _selectedTax,
              discountAmount: currentDiscountAmount,
              selectedDiscount: _selectedDiscount,
              paidAmount:
                  _totalPaying, // نعرض ما دفعه العميل فعلاً ليشمل الباقي
              change: _change,
              reference: checkOutCubit.reference ?? 'N/A',
              pointsEarned: checkOutCubit.pointsEarned ?? 0,
              paymentMethod: widget.selectedPaymentMethod,
            ),
          );
        },
      );
    }
  }
}
