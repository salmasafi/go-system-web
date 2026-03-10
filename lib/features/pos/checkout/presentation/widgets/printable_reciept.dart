import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:systego/features/POS/checkout/model/reciept_data.dart';

class PrintableReceipt extends StatelessWidget {
  final RecieptData recieptData;

  const PrintableReceipt({super.key, required this.recieptData});

  String _dt() => DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  // حساب الإجمالي النهائي (يجب أن يتطابق مع ما تم حسابه في Checkout Dialog)
  // المعادلة: (Subtotal - Discount) + Tax
  // أو Subtotal + Tax - Discount (حسب ترتيبك المفضل، الكود الحالي يفترض الطرح ثم الجمع)
  double get grandTotal =>
      (recieptData.totalAmount - recieptData.discountAmount) +
      recieptData.taxAmount;

  // --- BIGGER FONTS CONFIGURATION ---
  TextStyle get _headerTitleStyle => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    height: 0.8,
  );
  TextStyle get _headerSubStyle =>
      const TextStyle(fontSize: 11, color: Colors.black87);
  TextStyle get _columnHeaderStyle =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
  TextStyle get _itemStyle =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  TextStyle get _totalLabelStyle =>
      const TextStyle(fontSize: 9, fontWeight: FontWeight.bold);
  TextStyle get _grandTotalNumStyle =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w900);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          _header(),
          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 15),
          _info(),
          const SizedBox(height: 15),
          _divider(),
          const SizedBox(height: 15),
          _itemsHeader(),
          const SizedBox(height: 10),
          _thickDivider(),
          const SizedBox(height: 5),
          _itemsList(),
          const SizedBox(height: 5),
          _thickDivider(),
          const SizedBox(height: 15),
          _totals(), // تم تحديث هذا الجزء
          const SizedBox(height: 15),
          _grandTotal(),
          if (recieptData.paidAmount > 0) ...[
            const SizedBox(height: 15),
            _divider(),
            const SizedBox(height: 15),
            _cashSection(),
          ],
          // if (recieptData.pointsEarned > 0) ...[
          //   const SizedBox(height: 12),
          //   _loyalty(),
          // ],
          const SizedBox(height: 15),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Text("SYSTEGO", style: _headerTitleStyle),
        const SizedBox(height: 8),
        Text("Point of Sale System", style: _headerSubStyle),
      ],
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row("Date:", _dt()),
        const SizedBox(height: 4),
        _row("Ref:", recieptData.reference),
        // const SizedBox(height: 4),
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
        // حساب السعر الفعلي (مع الأخذ في الاعتبار الاختلافات)
        final unitPrice = item.selectedVariation?.price ?? item.product.price;
        final total = unitPrice * item.quantity;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                width: 45,
                child: Text(
                  "${item.quantity}",
                  style: _itemStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  unitPrice.toStringAsFixed(2),
                  style: _itemStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 85,
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
          const SizedBox(height: 6),
          _row(_getTaxLabel(), '+${recieptData.taxAmount.toStringAsFixed(2)}'),
        ],

        // --- قسم الخصم (Discount) ---
        if (recieptData.discountAmount > 0) ...[
          const SizedBox(height: 6),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 2.5, color: Colors.black), // Thicker border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("GRAND TOTAL:  ", style: _totalLabelStyle),
          const SizedBox(height: 6),
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
        const SizedBox(height: 6),
        if (recieptData.change > 0)
          _row("Change Due", recieptData.change.toStringAsFixed(2), bold: true),
      ],
    );
  }

  // Widget _loyalty() {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(border: Border.all(color: Colors.black)),
  //     child: Center(
  //       child: Text(
  //         "Points Earned: ${recieptData.pointsEarned}",
  //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
  //       ),
  //     ),
  //   );
  // }

  Widget _footer() {
    return const Column(
      children: [
        Text(
          "Thank You!",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2),
        Text("Powered by SYSTEGO POS", style: TextStyle(fontSize: 10)),
        Text("www.systego.com", style: TextStyle(fontSize: 9)),
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
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            fontSize: 11,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
