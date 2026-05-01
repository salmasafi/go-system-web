import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:systego/features/pos/checkout/model/reciept_data.dart';

class PrintableReceipt extends StatelessWidget {
  final RecieptData recieptData;

  const PrintableReceipt({super.key, required this.recieptData});

  String _dt() =>
      DateFormat('yyyy-MM-dd HH:mm', 'en_US').format(DateTime.now());

  // حساب الإجمالي النهائي (يجب أن يتطابق مع ما تم حسابه في Checkout Dialog)
  // المعادلة: (Subtotal - Discount) + Tax
  // أو Subtotal + Tax - Discount (حسب ترتيبك المفضل، الكود الحالي يفترض الطرح ثم الجمع)
  double get grandTotal =>
      (recieptData.totalAmount - recieptData.discountAmount) +
      recieptData.taxAmount;

  // --- BIGGER FONTS CONFIGURATION ---
  TextStyle get _headerTitleStyle => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 0.8,
  );
  TextStyle get _headerSubStyle =>
      TextStyle(fontSize: 10, color: Colors.black87);
  TextStyle get _columnHeaderStyle =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w300);
  TextStyle get _itemStyle =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w200);
  TextStyle get _totalLabelStyle =>
      TextStyle(fontSize: 8, fontWeight: FontWeight.w300);
  TextStyle get _grandTotalNumStyle =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: ResponsiveUI.value(context, 30)),
            _header(),
            SizedBox(height: ResponsiveUI.value(context, 16)),
            _divider(),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            _info(),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            _divider(),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            _itemsHeader(),
            SizedBox(height: ResponsiveUI.value(context, 18)),
            _thickDivider(),
            SizedBox(height: ResponsiveUI.value(context, 14)),
            _itemsList(),
            SizedBox(height: ResponsiveUI.value(context, 4)),
            _thickDivider(),
            SizedBox(height: ResponsiveUI.value(context, 22)),
            _totals(), // تم تحديث هذا الجزء
            SizedBox(height: ResponsiveUI.value(context, 20)),
            _grandTotal(),
            if (recieptData.paidAmount > 0) ...[
              SizedBox(height: ResponsiveUI.value(context, 20)),
              _divider(),
              SizedBox(height: ResponsiveUI.value(context, 20)),
              _cashSection(),
            ],
            // if (recieptData.pointsEarned > 0) ...[
            //   SizedBox(height: ResponsiveUI.value(context, 12)),
            //   _loyalty(),
            // ],
            SizedBox(height: ResponsiveUI.value(context, 20)),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Text("SYSTEGO", style: _headerTitleStyle),
        SizedBox(height: 8),
        Text("Point of Sale System", style: _headerSubStyle),
      ],
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row("Date:", _dt()),
        SizedBox(height: 4),
        _row("Ref:", recieptData.reference),
        // SizedBox(height: ResponsiveUI.value(context, 4)),
        // _row("Payment:", recieptData.paymentMethod.name),
      ],
    );
  }

  Widget _itemsHeader() {
    return Row(
      children: [
        Expanded(flex: 4, child: Text("Product", style: _columnHeaderStyle)),
        SizedBox(
          width: 45,
          child: Text(
            "Qty",
            style: _columnHeaderStyle,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            "Price",
            style: _columnHeaderStyle,
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(
          width: 85,
          child: Text(
            "Total",
            style: _columnHeaderStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _itemsList() {
    return Column(
      children: recieptData.cartItems.map((item) {
        final unitPrice = item.selectedVariation?.price ?? item.product.price;
        final total = unitPrice * item.quantity;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  item.product.name,
                  style: _itemStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  "${item.quantity}",
                  style: _itemStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  unitPrice.toStringAsFixed(2),
                  style: _itemStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  total.toStringAsFixed(2),
                  style: _itemStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _totals() {
    return Column(
      children: [
        _row(
          "Subtotal",
          recieptData.totalAmount.toStringAsFixed(2),
          bold: true,
        ),

        // --- قسم الضريبة (Tax) ---
        if (recieptData.taxAmount > 0) ...[
          SizedBox(height: 6),
          _row(_getTaxLabel(), '+${recieptData.taxAmount.toStringAsFixed(2)}'),
        ],

        // --- قسم الخصم (Discount) ---
        if (recieptData.discountAmount > 0) ...[
          SizedBox(height: 6),
          _row(
            _getDiscountLabel(),
            "-${recieptData.discountAmount.toStringAsFixed(2)}",
          ),
        ],
      ],
    );
  }

  // دالة مساعدة لتنسيق اسم الضريبة
  String _getTaxLabel() {
    if (recieptData.selectedTax != null) {
      final taxName = recieptData.selectedTax!.name;
      if (recieptData.selectedTax!.type == 'percentage') {
        // معالجة القيم الصغيرة أو الصحيحة (مثلاً 14.00% -> 14%)
        final rate = recieptData.selectedTax!.amount * 100;
        final rateStr = rate.truncateToDouble() == rate
            ? rate.toStringAsFixed(0)
            : rate.toStringAsFixed(1);
        return "$taxName ($rateStr%)";
      }
      return taxName;
    }
    return "Tax";
  }

  // دالة مساعدة لتنسيق اسم الخصم
  String _getDiscountLabel() {
    if (recieptData.selectedDiscount != null) {
      final discountName = recieptData.selectedDiscount!.name;
      if (recieptData.selectedDiscount!.type == 'percentage') {
        final rate = recieptData.selectedDiscount!.amount * 100;
        final rateStr = rate.truncateToDouble() == rate
            ? rate.toStringAsFixed(0)
            : rate.toStringAsFixed(1);
        return "$discountName ($rateStr%)";
      }
      return discountName;
    }
    return "Discount";
  }

  Widget _grandTotal() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 2.5, color: Colors.black), // Thicker border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("GRAND TOTAL:  ", style: _totalLabelStyle),
          SizedBox(height: 6),
          Text(
            "${grandTotal.toStringAsFixed(2)} EGP",
            style: _grandTotalNumStyle,
          ),
        ],
      ),
    );
  }

  Widget _cashSection() {
    return Column(
      children: [
        _row(
          "Amount Paid",
          recieptData.paidAmount.toStringAsFixed(2),
          bold: true,
        ),
        SizedBox(height: 6),
        if (recieptData.change > 0)
          _row("Change Due", recieptData.change.toStringAsFixed(2), bold: true),
      ],
    );
  }

  // Widget _loyalty() {
  //   return Container(
  //     padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
  //     decoration: BoxDecoration(border: Border.all(color: Colors.black)),
  //     child: Center(
  //       child: Text(
  //         "Points Earned: ${recieptData.pointsEarned}",
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveUI.fontSize(context, 9)),
  //       ),
  //     ),
  //   );
  // }

  Widget _footer() {
    return Column(
      children: [
        Text(
          "Thank You!",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 2),
        Text("Powered by SYSTEGO POS", style: TextStyle(fontSize: 9)),
        Text("www.systego.com", style: TextStyle(fontSize: 8)),
      ],
    );
  }

  Widget _divider() => Container(color: Colors.grey[400], height: 1);
  Widget _thickDivider() => Container(color: Colors.black, height: 2);

  Widget _row(String left, String right, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w500 : FontWeight.w300,
            fontSize: 11,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w500 : FontWeight.w300,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
