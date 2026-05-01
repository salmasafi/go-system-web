import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/features/pos/checkout/model/reciept_data.dart';
import 'dart:async';
import '../../cubit/printer_cubit/printer_cubit.dart';
import '../widgets/printable_reciept.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final RecieptData recieptData;
  const ReceiptPreviewScreen({super.key, required this.recieptData});

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  final PrinterCubit printerCubit = PrinterCubit();
  String status =
      'Searching for your printer....\nMake sure your Bluetouth is on';
  bool printing = false;
  BluetoothDevice? device;
  final GlobalKey _receiptBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _findPrinter();
  }

  @override
  void dispose() {
    printerCubit.disconnect();
    super.dispose();
  }

  void _findPrinter() async {
    device = await printerCubit.findPrinter();
    setState(
      () => status = device != null
          ? 'Your printer is found! Press now'
          : "Your printer is not connected",
    );
  }

  Future<void> _print() async {
    if (printing) return;
    setState(() => printing = true);

    final success = await printerCubit.printReceipt(
      context,
      receipt: widget.recieptData,
      //  receiptRepaintKey: _receiptBoundaryKey,
    );

    setState(() {
      printing = false;
      status = success ? "Reciept is printed successfully!" : "Printing failed";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(context, title: 'Reciept Preview'),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _receiptBoundaryKey,
                child: Container(
                  padding: EdgeInsets.only(
                    left: ResponsiveUI.padding(context, 20),
                    right: ResponsiveUI.padding(context, 40),
                    top: ResponsiveUI.padding(context, 20),
                    bottom: ResponsiveUI.padding(context, 20),
                  ),
                  color: Colors.white,
                  child: PrintableReceipt(recieptData: widget.recieptData),
                ),
              ),
              SizedBox(height: ResponsiveUI.value(context, 10)),
              Text(
                status,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 20)),
              ),
              SizedBox(height: ResponsiveUI.value(context, 10)),
              // CustomElevatedButton(
              //   onPressed: _findPrinter,
              //   // icon: Icon(Icons.print, size: ResponsiveUI.iconSize(context, 30)),
              //   text: status.contains('Searching....') ? ' Searching' : "Retry",
              // ),
              // SizedBox(height: ResponsiveUI.value(context, 10)),
              CustomElevatedButton(
                onPressed: (printing || device == null) ? null : _print,
                // icon: Icon(Icons.print, size: ResponsiveUI.iconSize(context, 30)),
                text: "Print Reciept",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
