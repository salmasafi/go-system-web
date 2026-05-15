import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:GoSystem/features/pos/history/model/due_payment_receipt_data.dart';

class DuePaymentReceiptWidget extends StatelessWidget {
  final DuePaymentReceiptData data;

  const DuePaymentReceiptWidget({super.key, required this.data});

  String get _formattedDate =>
      DateFormat('yyyy-MM-dd HH:mm', 'en_US').format(data.date);

  TextStyle get _titleStyle => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      );

  TextStyle get _subStyle =>
      const TextStyle(fontSize: 10, color: Colors.black87);

  TextStyle get _labelStyle =>
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w300);

  TextStyle get _valueStyle =>
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);

  TextStyle get _boldStyle =>
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w800);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          _header(),
          const SizedBox(height: 14),
          _divider(),
          const SizedBox(height: 12),
          _infoSection(),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          _customerSection(),
          const SizedBox(height: 12),
          _thickDivider(),
          const SizedBox(height: 14),
          _totalsSection(),
          const SizedBox(height: 14),
          _thickDivider(),
          const SizedBox(height: 14),
          _paidNowSection(),
          const SizedBox(height: 14),
          _thickDivider(),
          const SizedBox(height: 14),
          _remainingSection(),
          const SizedBox(height: 14),
          _divider(),
          const SizedBox(height: 18),
          _footer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _header() => Column(
        children: [
          Text(
            'PAYMENT RECEIPT',
            style: _titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'إيصال سداد دين',
            style: _subStyle,
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _infoSection() => Column(
        children: [
          _row('Date:', _formattedDate),
          const SizedBox(height: 4),
          _row('Ref:', data.saleReference),
        ],
      );

  Widget _customerSection() => Column(
        children: [
          _row('Customer:', data.customerName),
          if (data.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            _row('Phone:', data.phone),
          ],
        ],
      );

  Widget _totalsSection() => Column(
        children: [
          _row(
            'Grand Total:',
            '${data.grandTotal.toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: 6),
          _row(
            'Previously Paid:',
            '${data.previouslyPaid.toStringAsFixed(2)} EGP',
          ),
        ],
      );

  Widget _paidNowSection() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('PAID NOW:', style: _boldStyle),
          Text('${data.paidNow.toStringAsFixed(2)} EGP', style: _boldStyle),
        ],
      );

  Widget _remainingSection() => Column(
        children: [
          _row(
            'Remaining:',
            '${data.remainingAfter.toStringAsFixed(2)} EGP',
            bold: data.remainingAfter > 0,
          ),
          if (data.paymentAccount.isNotEmpty) ...[
            const SizedBox(height: 4),
            _row('Account:', data.paymentAccount),
          ],
        ],
      );

  Widget _footer() => Column(
        children: [
          Text('Thank You!', style: _boldStyle, textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(
            'Powered by GoSystem POS',
            style: _subStyle,
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _divider() => Container(color: Colors.grey[400], height: 1);
  Widget _thickDivider() => Container(color: Colors.black, height: 2);

  Widget _row(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? _boldStyle : _labelStyle),
          Text(value, style: bold ? _boldStyle : _valueStyle),
        ],
      );
}
