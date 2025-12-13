import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/features/POS/checkout/model/reciept_data.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import 'package:systego/features/admin/discount/model/discount_model.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../cubit/checkout_cubit/checkout_cubit.dart';
import '../../model/checkout_models.dart';
import 'receipt_dialog.dart';

class POSCheckoutDialog extends StatefulWidget {
  final double totalAmount;
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
  final _totalPayingCtrl =
      TextEditingController(); // Cash / Card / GiftCard / Points
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _giftCardCtrl = TextEditingController();
  final _paymentReceiverCtrl = TextEditingController();
  final _paymentNoteCtrl = TextEditingController();
  final _saleNoteCtrl = TextEditingController();
  final _staffNoteCtrl = TextEditingController();

  // ---------- Runtime values ----------
  double _totalPaying = 0.0;
  double _subTotal = 0.0;
  double _change = 0.0;
  double _due = 0.0;
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
    _taxes = posCubit.taxes;
    _discounts = posCubit.discounts;

    // Set selectedTax, ensuring it's from the list
    if (posCubit.selectedTax != null) {
      // Find matching tax by id
      _selectedTax = posCubit.selectedTax;
    } else {
      _selectedTax = _taxes.first;
    }

    if (_selectedTax!.type == 'percentage') {
      currentTaxAmount = (_selectedTax!.amount * _subTotal);
    } else {
      currentTaxAmount = _selectedTax!.amount;
    }

    // Set selectedDiscount, ensuring it's from the list
    if (posCubit.selectedDiscount != null) {
      // Find matching discount by id
      _selectedDiscount = posCubit.selectedDiscount;
    } else {
      _selectedDiscount = _discounts.first;
    }

    if (_selectedDiscount!.type == 'percentage') {
      currentDiscountAmount = (_selectedDiscount!.amount * _subTotal);
    } else {
      currentDiscountAmount = _selectedDiscount!.amount;
    }

    _due = (_subTotal - currentDiscountAmount) + currentTaxAmount;
    _totalPayingCtrl.addListener(_calc);
  }

  void _calc() {
    setState(() {
      _totalPaying = double.tryParse(_totalPayingCtrl.text) ?? 0.0;

      double taxAmount = 0.0;
      if (_selectedTax != null) {
        if (_selectedTax!.type == 'percentage') {
          taxAmount = _selectedTax!.amount * _subTotal;
        } else {
          taxAmount = _selectedTax!.amount;
        }
      }
      currentTaxAmount = taxAmount;

      double discountAmount = 0.0;
      if (_selectedDiscount != null) {
        if (_selectedDiscount!.type == 'percentage') {
          discountAmount = _selectedDiscount!.amount * (_subTotal + taxAmount);
        } else {
          discountAmount = _selectedDiscount!.amount;
        }
      }
      currentDiscountAmount = discountAmount;

      _due = (_subTotal + taxAmount) - discountAmount;

      if (_totalPaying >= _due) {
        _change = _totalPaying - _due;
        _due = 0.0;
      } else {
        _change = 0.0;
        _due = _due - _totalPaying;
      }
    });
  }

  @override
  void dispose() {
    _totalPayingCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _giftCardCtrl.dispose();
    _paymentReceiverCtrl.dispose();
    _paymentNoteCtrl.dispose();
    _saleNoteCtrl.dispose();
    _staffNoteCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  //  BUILD
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
                      // <<< DYNAMIC SECTION >>>
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
  //  COMMON PARTS
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
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.point_of_sale,
            color: AppColors.white,
            size: ResponsiveUI.iconSize(context, 28),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 18)),
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

  Widget _paymentMethodDisplay() => Container(
    padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
    decoration: BoxDecoration(
      color: AppColors.lightBlueBackground,
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 12),
      ),
      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.payment,
          color: AppColors.primaryBlue,
          size: ResponsiveUI.iconSize(context, 24),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Text(
          widget.selectedPaymentMethod.name,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
      ],
    ),
  );

  Widget _summaryPanel() => Container(
    margin: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 20)),
    padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.linkBlue.withOpacity(0.1),
          AppColors.primaryBlue.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 16),
      ),
      border: Border.all(
        color: AppColors.primaryBlue.withOpacity(0.3),
        width: 1.5,
      ),
    ),
    child: Column(
      children: [
        _row('Total Payable', _due, AppColors.darkGray, bold: true),
        Divider(
          color: AppColors.shadowGray.withOpacity(0.3),
          height: ResponsiveUI.spacing(context, 20),
        ),


        _row('Sub total  ', _subTotal, AppColors.categoryPurple),

        Divider(
          color: AppColors.shadowGray.withOpacity(0.3),
          height: ResponsiveUI.spacing(context, 20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _row('Taxes  ', currentTaxAmount, AppColors.warningOrange),
            _row('Discount  ', currentDiscountAmount, AppColors.successGreen),
          ],
        ),

        Divider(
          color: AppColors.shadowGray.withOpacity(0.3),
          height: ResponsiveUI.spacing(context, 20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _row('Change  ', _change, AppColors.clearPink),
            _row('Due  ', _due, AppColors.red),
          ],
        ),
      ],
    ),
  );

  Widget _row(String label, double amount, Color color, {bool bold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, bold ? 16 : 14),
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, bold ? 18 : 16),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );

  Widget _footer() => Container(
    padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
    decoration: BoxDecoration(
      color: AppColors.shadowGray[50],
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 14),
              ),
              side: BorderSide(color: AppColors.shadowGray[300]!, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: AppColors.shadowGray[700],
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: //_due > 0 ? null :
                _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mediumBlue700,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.shadowGray[300],
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 14),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: ResponsiveUI.iconSize(context, 20),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 8)),
                Text(
                  'Complete Sale',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // --------------------------------------------------------------
  //  NOTES (always the same)
  // --------------------------------------------------------------
  Widget _notesSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Text(
      //   'Additional Notes',
      //   style: TextStyle(
      //     fontSize: ResponsiveUI.fontSize(context, 16),
      //     fontWeight: FontWeight.bold,
      //     color: AppColors.darkGray,
      //   ),
      // ),
      // SizedBox(height: ResponsiveUI.spacing(context, 12)),
      Row(
        children: [
          Expanded(
            child: buildTextField(
              context,
              controller: _saleNoteCtrl,
              label: 'Sale Note',
              icon: Icons.shopping_bag_outlined,
              hint: 'Enter sale note',
              maxLines: 1,
            ),
          ),
          // SizedBox(width: ResponsiveUI.spacing(context, 12)),
          // Expanded(
          //   child: buildTextField(
          //     context,
          //     controller: _staffNoteCtrl,
          //     label: 'Staff Note',
          //     icon: Icons.badge_outlined,
          //     hint: 'Enter staff note',
          //     maxLines: 3,
          //   ),
          // ),
        ],
      ),
    ],
  );

  // --------------------------------------------------------------
  //  DYNAMIC FIELDS – **exact match to your screenshots**
  // --------------------------------------------------------------
  Widget _dynamicFields() {
    final method = widget.selectedPaymentMethod.name.toLowerCase();

    // ---------- CASH ----------
    if (method.contains('cash')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Cash Received',
          //   style: TextStyle(
          //     fontSize: ResponsiveUI.fontSize(context, 16),
          //     fontWeight: FontWeight.bold,
          //     color: AppColors.darkGray,
          //   ),
          // ),
          // SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: _totalPayingCtrl,
            label: 'Cash Received',
            icon: Icons.payments_outlined,
            hint: 'Enter amount',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      );
    }

    // ---------- CARD ----------
    if (method.contains('card') && !method.contains('gift')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Information',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: buildTextField(
                  context,
                  controller: _cardNumberCtrl,
                  label: 'Card Number',
                  icon: Icons.credit_card,
                  hint: 'Enter card number',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              Expanded(child: _cardTypeDropdown()),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: _cardHolderCtrl,
            label: 'Card Holder Name',
            icon: Icons.person_outline,
            hint: 'Enter cardholder name',
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          buildTextField(
            context,
            controller: _totalPayingCtrl,
            label: 'Total Paying',
            icon: Icons.payments_outlined,
            hint: 'Enter amount paying',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      );
    }

    // ---------- GIFT CARD ----------
    if (method.contains('gift')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gift Card *',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: _giftCardCtrl,
            label: 'Gift Card',
            icon: Icons.card_giftcard,
            hint: 'Enter gift card code',
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          buildTextField(
            context,
            controller: _totalPayingCtrl,
            label: 'Total Paying',
            icon: Icons.payments_outlined,
            hint: 'Enter amount paying',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      );
    }

    // ---------- POINTS ----------
    if (method.contains('points')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Text(
          //   'Points',
          //   style: TextStyle(
          //     fontSize: ResponsiveUI.fontSize(context, 16),
          //     fontWeight: FontWeight.bold,
          //     color: AppColors.darkGray,
          //   ),
          // ),
          // SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: _totalPayingCtrl,
            label: 'Points Used',
            icon: Icons.star,
            hint: 'Enter points',
            keyboardType: TextInputType.number,
          ),
        ],
      );
    }

    // ---------- MULTIPLE PAYMENT ----------
    if (method.contains('multiple')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextField(
            context,
            controller: _totalPayingCtrl,
            label: 'Paying Amount *',
            icon: Icons.payments_outlined,
            hint: '0',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),

          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          DropdownButtonFormField<String>(
            value: 'Cash',
            decoration: InputDecoration(
              labelText: 'Paid By',
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: AppColors.primaryBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
              ),
            ),
            items: [
              'Cash',
              'Gift Card',
              'Credit Card',
              'Points',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (_) {},
          ),

          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: TextEditingController(),
            label: 'Cash Received',
            icon: Icons.money,
            hint: '0',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),

          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add, color: AppColors.white),
            label: Text(
              'More Payment',
              style: TextStyle(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ---------- DEFAULT (any other method) ----------
    return buildTextField(
      context,
      controller: _totalPayingCtrl,
      label: 'Total Paying',
      icon: Icons.payments_outlined,
      hint: 'Enter amount',
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _cardTypeDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Card Type',
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
      ),
      SizedBox(height: ResponsiveUI.spacing(context, 8)),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
        ),
        decoration: BoxDecoration(
          color: AppColors.lightBlueBackground,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 12),
          ),
          border: Border.all(color: AppColors.shadowGray.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCardType,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
            items: _cardTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCardType = v!),
          ),
        ),
      ),
    ],
  );

  Widget _taxDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Select Tax',
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
      ),
      SizedBox(height: ResponsiveUI.spacing(context, 8)),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
        ),
        decoration: BoxDecoration(
          color: AppColors.lightBlueBackground,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 12),
          ),
          border: Border.all(color: AppColors.shadowGray.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Tax>(
            value: _selectedTax,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
            items: _taxes
                .map(
                  (t) => DropdownMenuItem<Tax>(
                    value: t,
                    child: Text(
                      '${t.name} - ${(t.type == 'fixed') ? '${t.amount}EGP' : '${(t.amount * 100).toStringAsFixed(1)}%'}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedTax = v;
                _calc();
              });
            },
          ),
        ),
      ),
    ],
  );

  Widget _discountDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Select Discount',
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
      ),
      SizedBox(height: ResponsiveUI.spacing(context, 8)),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
        ),
        decoration: BoxDecoration(
          color: AppColors.lightBlueBackground,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 12),
          ),
          border: Border.all(color: AppColors.shadowGray.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DiscountModel>(
            value: _selectedDiscount,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
            items: _discounts
                .map(
                  (d) => DropdownMenuItem<DiscountModel>(
                    value: d,
                    child: Text(
                      '${d.name} - ${(d.type == 'fixed') ? '${d.amount}EGP' : '${(d.amount * 100).toStringAsFixed(1)}%'}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedDiscount = v;
                _calc();
              });
            },
          ),
        ),
      ),
    ],
  );

  // --------------------------------------------------------------
  //  SUBMIT
  // --------------------------------------------------------------
  void _submit() async {
    if (_due > 0 &&
        !widget.selectedPaymentMethod.name.toLowerCase().contains('cash')) {
      CustomSnackbar.showError(context, 'Please pay full amount');
      return;
    }

    double paidAmount = _totalPaying >= _due ? _totalPaying : _due;

    //paidAmount = paidAmount - ((_selectedTax != null) ? _selectedTax!.amount : 0);

    final posCubit = context.read<PosCubit>();
    final checkOutCubit = context.read<CheckoutCubit>();

    final success = await checkOutCubit.createSale(
      cartItems: widget.cartItems,
      totalAmount: _due,
      posCubit: posCubit,
      paymentNote: _paymentNoteCtrl.text.isEmpty ? null : _paymentNoteCtrl.text,
    );

    if (success && mounted) {
      //posCubit.updateCartWithEmptyList();
      // اعرض الإيصال
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          // final checkOutCubit = context.read<CheckoutCubit>();
          // final cartItems = checkOutCubit.cartItems;
          return POSReceiptDialog(
            recieptData: RecieptData(
              cartItems: widget.cartItems,
              totalAmount: widget.totalAmount, // Subtotal فقط
              taxAmount: currentTaxAmount,
              selectedTax: _selectedTax, // عشان يظهر اسم الضريبة
              discountAmount: currentDiscountAmount,
              selectedDiscount: _selectedDiscount, // عشان يظهر اسم الخصم
              paidAmount: paidAmount,
              change: _change,
              reference: context.read<CheckoutCubit>().reference ?? '',
              pointsEarned: context.read<CheckoutCubit>().pointsEarned ?? 0,
              paymentMethod: widget.selectedPaymentMethod,
            ),
          );
        },
      );
    }
  }
}
