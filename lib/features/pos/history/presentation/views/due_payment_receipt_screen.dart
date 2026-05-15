import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/features/pos/checkout/cubit/printer_cubit/printer_cubit.dart';
import 'package:GoSystem/features/pos/history/model/due_payment_receipt_data.dart';
import 'package:GoSystem/features/pos/history/presentation/widgets/due_payment_receipt_widget.dart';

class DuePaymentReceiptScreen extends StatefulWidget {
  final DuePaymentReceiptData receiptData;

  const DuePaymentReceiptScreen({super.key, required this.receiptData});

  @override
  State<DuePaymentReceiptScreen> createState() =>
      _DuePaymentReceiptScreenState();
}

class _DuePaymentReceiptScreenState extends State<DuePaymentReceiptScreen> {
  final PrinterCubit _printerCubit = PrinterCubit();
  final GlobalKey _boundaryKey = GlobalKey();

  bool _printerFound = false;
  bool _printing = false;
  String _status =
      'Searching for your printer...\nMake sure your Bluetooth is on';

  @override
  void initState() {
    super.initState();
    _findPrinter();
  }

  @override
  void dispose() {
    _printerCubit.disconnect();
    super.dispose();
  }

  Future<void> _findPrinter() async {
    final device = await _printerCubit.findPrinter();
    if (mounted) {
      setState(() {
        _printerFound = device != null;
        _status = device != null
            ? 'Printer found! Press to print'
            : 'Printer not connected';
      });
    }
  }

  Future<void> _print() async {
    if (_printing) return;
    setState(() => _printing = true);

    final success =
        await _printerCubit.printFromBoundary(context, _boundaryKey);

    if (mounted) {
      setState(() {
        _printing = false;
        _status =
            success ? 'Receipt printed successfully!' : 'Printing failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(context, title: LocaleKeys.print_receipt.tr()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: Column(
          children: [
            RepaintBoundary(
              key: _boundaryKey,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 8),
                  vertical: ResponsiveUI.padding(context, 12),
                ),
                child: DuePaymentReceiptWidget(data: widget.receiptData),
              ),
            ),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            Text(
              _status,
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 16)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUI.value(context, 16)),
            CustomElevatedButton(
              onPressed: (!_printing && _printerFound) ? _print : null,
              text: _printing ? 'Printing...' : 'Print Receipt',
            ),
            SizedBox(height: ResponsiveUI.value(context, 12)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.back.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
